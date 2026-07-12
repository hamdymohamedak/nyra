#!/usr/bin/env python3
"""Write registry/c/*.toml from c_registry_catalog and refresh cli BUILTIN."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

_MAKE_PY = Path(__file__).resolve().parents[1]
if str(_MAKE_PY) not in sys.path:
    sys.path.insert(0, str(_MAKE_PY))

from contrib_dev.c_registry_catalog import ENTRIES, by_name, count  # noqa: E402
from contrib_dev.paths import C_REGISTRY, C_REGISTRY_RS  # noqa: E402
from contrib_dev.recipes import c_lib_registry as recipe  # noqa: E402
from contrib_dev.spec import CLibRegistrySpec  # noqa: E402


def _render_toml(entry: dict) -> str:
    spec = CLibRegistrySpec(
        name=entry["name"],
        description=entry.get("description") or "",
        headers=list(entry["headers"]),
        libs=list(entry["libs"]),
        pkg_config=entry.get("pkg_config"),
        brew=entry.get("brew"),
        apt=entry.get("apt"),
        pacman=entry.get("pacman"),
        dnf=entry.get("dnf"),
        aliases=list(entry.get("aliases") or []),
        git=entry.get("git"),
        depends=list(entry.get("depends") or []),
        impl_define=entry.get("impl_define"),
        platforms=list(entry.get("platforms") or []),
        defines=list(entry.get("defines") or []),
        force_include=list(entry.get("force_include") or []),
        cxx=bool(entry.get("cxx") or False),
    )
    # Plain toml (no contrib markers) — matches existing registry style.
    return recipe.render_toml(spec)


def _write_tomls(*, prune: bool) -> tuple[int, int, list[str]]:
    C_REGISTRY.mkdir(parents=True, exist_ok=True)
    written = 0
    catalog_names = set(by_name())
    for entry in ENTRIES:
        path = C_REGISTRY / f"{entry['name']}.toml"
        body = _render_toml(entry)
        prev = path.read_text(encoding="utf-8") if path.is_file() else None
        if prev != body:
            path.write_text(body, encoding="utf-8")
            written += 1
    pruned: list[str] = []
    if prune:
        for path in sorted(C_REGISTRY.glob("*.toml")):
            if path.stem not in catalog_names:
                path.unlink()
                pruned.append(path.stem)
    return written, len(ENTRIES), pruned


def _refresh_builtin() -> bool:
    names = sorted(p.stem for p in C_REGISTRY.glob("*.toml"))
    lines = ["const BUILTIN: &[(&str, &str)] = &["]
    for name in names:
        lines.append(f'    ("{name}", include_str!("../../registry/c/{name}.toml")),')
    lines.append("];")
    block = "\n".join(lines)

    text = C_REGISTRY_RS.read_text(encoding="utf-8")
    pattern = re.compile(
        r"const BUILTIN: &\[\(&str, &str\)\] = &\[.*?\];",
        re.DOTALL,
    )
    if not pattern.search(text):
        raise SystemExit("BUILTIN table not found in c_registry.rs")
    new_text = pattern.sub(block, text, count=1)
    if new_text == text:
        return False
    C_REGISTRY_RS.write_text(new_text, encoding="utf-8")
    return True


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--prune",
        action="store_true",
        help="Delete registry/c/*.toml not present in the catalog",
    )
    ap.add_argument("--check", action="store_true", help="Validate only; do not write")
    args = ap.parse_args()

    # Validate specs early.
    for entry in ENTRIES:
        CLibRegistrySpec(
            name=entry["name"],
            description=entry.get("description") or "",
            headers=list(entry["headers"]),
            libs=list(entry["libs"]),
            pkg_config=entry.get("pkg_config"),
            brew=entry.get("brew"),
            apt=entry.get("apt"),
            pacman=entry.get("pacman"),
            dnf=entry.get("dnf"),
            aliases=list(entry.get("aliases") or []),
            git=entry.get("git"),
            depends=list(entry.get("depends") or []),
            impl_define=entry.get("impl_define"),
            platforms=list(entry.get("platforms") or []),
            defines=list(entry.get("defines") or []),
            force_include=list(entry.get("force_include") or []),
            cxx=bool(entry.get("cxx") or False),
        )

    print(f"catalog entries: {count()}")
    if args.check:
        print("ok (check only)")
        return 0

    written, total, pruned = _write_tomls(prune=args.prune)
    refreshed = _refresh_builtin()
    print(f"toml updated: {written}/{total}")
    if pruned:
        print(f"pruned: {', '.join(pruned)}")
    print(f"c_registry.rs BUILTIN refreshed: {refreshed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
