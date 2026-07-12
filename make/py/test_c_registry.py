#!/usr/bin/env python3
"""Validate every registry/c entry and optionally live-bind installed packages.

Modes:
  default          schema + brew formula existence + wire check
  --resolve        also verify headers resolve for installed (or git) libs
  --bind           also run `nyra bind <name> --no-install` for resolvable libs
  --install-bind   brew install missing formulae, then bind everything host supports

Exit non-zero if any hard failure (schema / missing brew formula / bind error).
Linux-only entries are skipped on macOS (reported as skip, not fail).
"""
from __future__ import annotations

import argparse
import os
import platform
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

_MAKE_PY = Path(__file__).resolve().parent
_ROOT = _MAKE_PY.parent.parent
if str(_MAKE_PY) not in sys.path:
    sys.path.insert(0, str(_MAKE_PY))

from contrib_dev.c_registry_catalog import ENTRIES, by_name  # noqa: E402
from contrib_dev.paths import C_REGISTRY, C_REGISTRY_RS  # noqa: E402
from contrib_dev.spec import CLibRegistrySpec  # noqa: E402


def _host() -> str:
    s = platform.system().lower()
    if s == "darwin":
        return "macos"
    if s == "linux":
        return "linux"
    if s.startswith("win"):
        return "windows"
    return s


def _nyra_bin() -> str:
    env = os.environ.get("NYRA_BIN")
    if env:
        p = Path(env).expanduser()
        if not p.is_absolute():
            p = (Path.cwd() / p).resolve()
        if p.is_file():
            return str(p)
    candidates = [
        _ROOT / "target" / "debug" / "nyra",
        _ROOT / "target" / "release" / "nyra",
        Path.home() / ".nyra" / "bin" / "nyra",
        Path(shutil.which("nyra") or ""),
    ]
    for c in candidates:
        if c and Path(c).is_file():
            return str(Path(c).resolve())
    raise SystemExit("nyra binary not found — build with `cargo build -p cli`")


def _brew_formulae() -> set[str]:
    out = subprocess.check_output(["brew", "formulae"], text=True)
    return set(out.split())


def _brew_installed_opts() -> set[str]:
    opt = Path("/opt/homebrew/opt")
    if not opt.is_dir():
        opt = Path("/usr/local/opt")
    if not opt.is_dir():
        return set()
    return {p.name for p in opt.iterdir() if p.exists()}


def _is_installed(entry: dict, installed_opts: set[str]) -> bool:
    if entry.get("git") and not entry.get("brew"):
        return True  # clone on demand
    brew = entry.get("brew")
    if not brew:
        return False
    cands = {brew, brew.split("@")[0], entry["name"]}
    return bool(cands & installed_opts)


def _supports_host(entry: dict, host: str) -> bool:
    plats = entry.get("platforms") or []
    if not plats:
        return True
    return host in {p.lower() for p in plats}


def check_schema() -> list[str]:
    errs: list[str] = []
    seen: set[str] = set()
    for raw in ENTRIES:
        try:
            spec = CLibRegistrySpec(
                name=raw["name"],
                description=raw.get("description") or "",
                headers=list(raw["headers"]),
                libs=list(raw["libs"]),
                pkg_config=raw.get("pkg_config"),
                brew=raw.get("brew"),
                apt=raw.get("apt"),
                pacman=raw.get("pacman"),
                dnf=raw.get("dnf"),
                aliases=list(raw.get("aliases") or []),
                git=raw.get("git"),
                depends=list(raw.get("depends") or []),
                impl_define=raw.get("impl_define"),
                platforms=list(raw.get("platforms") or []),
                defines=list(raw.get("defines") or []),
                force_include=list(raw.get("force_include") or []),
                cxx=bool(raw.get("cxx") or False),
            )
        except Exception as e:  # noqa: BLE001
            errs.append(f"{raw.get('name', '?')}: spec invalid: {e}")
            continue
        if spec.name in seen:
            errs.append(f"{spec.name}: duplicate catalog entry")
        seen.add(spec.name)
        if not (spec.pkg_config or spec.git or spec.brew or spec.apt):
            errs.append(f"{spec.name}: need pkg_config, brew, apt, or git")
        if not (spec.brew or spec.git or spec.apt):
            errs.append(f"{spec.name}: need brew, apt, or git")
    return errs


def check_files_wired() -> list[str]:
    errs: list[str] = []
    catalog = by_name()
    tomls = {p.stem for p in C_REGISTRY.glob("*.toml")}
    if tomls != set(catalog):
        missing = sorted(set(catalog) - tomls)
        extra = sorted(tomls - set(catalog))
        if missing:
            errs.append(f"toml missing for catalog: {missing[:12]}")
        if extra:
            errs.append(f"toml not in catalog: {extra[:12]}")
    rs = C_REGISTRY_RS.read_text(encoding="utf-8")
    for name in sorted(catalog):
        if f'("{name}", include_str!' not in rs:
            errs.append(f"c_registry.rs missing BUILTIN for {name}")
    return errs


def check_brew_formulae(formulae: set[str], host: str) -> list[str]:
    if host != "macos" or not shutil.which("brew"):
        return []
    errs: list[str] = []
    for e in ENTRIES:
        if not _supports_host(e, host):
            continue
        brew = e.get("brew")
        if not brew:
            continue
        if brew not in formulae:
            errs.append(f"{e['name']}: brew formula {brew!r} not found")
    return errs


def resolve_header(entry: dict) -> tuple[bool, str]:
    """Return (ok, detail). On macOS prefer an installed Homebrew keg."""
    if entry.get("git") and not entry.get("brew"):
        return True, f"git:{entry['git']}"
    brew = entry.get("brew")
    if brew and shutil.which("brew"):
        for base in (Path("/opt/homebrew/opt"), Path("/usr/local/opt")):
            opt = base / brew
            if opt.exists() and ((opt / "include").is_dir() or (opt / "lib").is_dir()):
                # Header may live in a dependency keg (vulkan-loader → vulkan-headers).
                if (opt / "include").is_dir():
                    return True, f"brew {opt}"
                for dep in entry.get("depends") or []:
                    for b2 in (base / dep,):
                        if (b2 / "include").is_dir():
                            return True, f"brew {opt} (+{dep} headers)"
                # Still installed — bind may resolve via depends
                if entry.get("depends"):
                    return True, f"brew {opt} (loader)"
                return False, f"brew {brew} has no include/"
        return False, f"brew {brew} not installed"
    pc = entry.get("pkg_config")
    if pc:
        r = subprocess.run(
            ["pkg-config", "--exists", pc],
            capture_output=True,
            text=True,
        )
        if r.returncode == 0:
            return True, f"pkg-config {pc}"
    return False, "not installed"


def run_bind(nyra: str, name: str, *, install: bool) -> tuple[bool, str]:
    with tempfile.TemporaryDirectory(prefix=f"nyra-bind-{name}-") as td:
        root = Path(td)
        (root / "nyra.mod").write_text(
            'name = "c-registry-smoke"\nversion = "0.0.0"\n',
            encoding="utf-8",
        )
        (root / "main.ny").write_text("fn main() {}\n", encoding="utf-8")
        cmd = [nyra, "bind", name, "-y"]
        if not install:
            cmd.append("--no-install")
        env = os.environ.copy()
        p = subprocess.run(
            cmd,
            cwd=str(root),
            capture_output=True,
            text=True,
            env=env,
            timeout=180,
        )
        out = (p.stdout or "") + (p.stderr or "")
        if p.returncode != 0:
            low = out.lower()
            if not install and (
                "not installed" in low
                or "run: brew install" in low
                or "run:\n    brew install" in low
                or "aborted — install" in low
            ):
                return False, "SKIP_NOT_INSTALLED"
            lines = [ln for ln in out.splitlines() if ln.strip()][-12:]
            return False, "\n".join(lines) or f"exit {p.returncode}"
        return True, "ok"


def brew_install(formulae: list[str]) -> list[str]:
    if not formulae:
        return []
    errs: list[str] = []
    # Install in chunks to avoid huge argv / long single failures
    chunk = 20
    for i in range(0, len(formulae), chunk):
        batch = formulae[i : i + chunk]
        print(f"  brew install ({i+1}-{i+len(batch)}/{len(formulae)}): {' '.join(batch)}")
        p = subprocess.run(
            ["brew", "install", *batch],
            capture_output=True,
            text=True,
        )
        if p.returncode != 0:
            # retry one-by-one
            for f in batch:
                q = subprocess.run(
                    ["brew", "install", f], capture_output=True, text=True
                )
                if q.returncode != 0:
                    tail = (q.stderr or q.stdout or "")[-400:]
                    errs.append(f"brew install {f}: {tail}")
    return errs


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--resolve", action="store_true")
    ap.add_argument("--bind", action="store_true")
    ap.add_argument("--install-bind", action="store_true")
    ap.add_argument("--only", help="comma-separated names to test")
    ap.add_argument("-q", "--quiet", action="store_true")
    args = ap.parse_args()
    if args.install_bind:
        args.bind = True
        args.resolve = True

    host = _host()
    only = {x.strip() for x in (args.only or "").split(",") if x.strip()} or None

    print(f"C-REGISTRY-TEST host={host} entries={len(ENTRIES)}")
    hard: list[str] = []
    skips: list[str] = []

    hard.extend(check_schema())
    hard.extend(check_files_wired())

    formulae: set[str] = set()
    if host == "macos" and shutil.which("brew"):
        formulae = _brew_formulae()
        hard.extend(check_brew_formulae(formulae, host))

    if hard:
        print(f"FAIL schema/wire/brew ({len(hard)})")
        for e in hard[:40]:
            print(" ", e)
        return 1
    print("  ok — schema + files + brew formulae")

    entries = [e for e in ENTRIES if only is None or e["name"] in only]
    supported = [e for e in entries if _supports_host(e, host)]
    for e in entries:
        if e not in supported:
            skips.append(f"{e['name']}: platform {e.get('platforms')}")

    installed_opts = _brew_installed_opts() if host == "macos" else set()

    if args.install_bind and host == "macos":
        need = []
        for e in supported:
            brew = e.get("brew")
            if brew and brew in formulae and not _is_installed(e, installed_opts):
                need.append(brew)
        # unique preserve order
        seen: set[str] = set()
        uniq = []
        for f in need:
            if f not in seen:
                seen.add(f)
                uniq.append(f)
        print(f"  installing {len(uniq)} brew formulae…")
        inst_errs = brew_install(uniq)
        if inst_errs:
            print(f"  WARN brew install failures: {len(inst_errs)}")
            for e in inst_errs[:20]:
                print("   ", e[:200])
        installed_opts = _brew_installed_opts()

    resolve_ok = resolve_fail = 0
    if args.resolve or args.bind:
        for e in supported:
            ok, detail = resolve_header(e)
            if ok:
                resolve_ok += 1
                if not args.quiet:
                    print(f"  resolve ok  {e['name']}: {detail}")
            else:
                resolve_fail += 1
                if args.install_bind:
                    hard.append(f"{e['name']}: resolve failed after install: {detail}")
                elif not args.quiet:
                    print(f"  resolve skip {e['name']}: {detail}")
        print(f"  resolve: ok={resolve_ok} unresolved={resolve_fail}")

    bind_ok = bind_fail = bind_skip = 0
    if args.bind:
        nyra = _nyra_bin()
        print(f"  binding with {nyra}")
        for e in supported:
            name = e["name"]
            ok, detail = resolve_header(e)
            if not ok and not (e.get("git") and args.install_bind):
                # git without brew: still try bind (clones)
                if not e.get("git"):
                    bind_skip += 1
                    continue
            okb, msg = run_bind(nyra, name, install=bool(args.install_bind))
            if okb:
                bind_ok += 1
                if not args.quiet:
                    print(f"  bind ok    {name}")
            elif msg == "SKIP_NOT_INSTALLED":
                bind_skip += 1
            else:
                bind_fail += 1
                hard.append(f"{name}: bind failed:\n{msg}")
                print(f"  bind FAIL  {name}")
        print(f"  bind: ok={bind_ok} fail={bind_fail} skip={bind_skip}")

    print(f"  skips (other OS): {len(skips)}")
    if hard:
        print(f"C-REGISTRY-TEST FAIL ({len(hard)} errors)")
        for e in hard[:50]:
            print("---")
            print(e)
        return 1
    print("C-REGISTRY-TEST: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
