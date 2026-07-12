#!/usr/bin/env python3
"""Smoke checks for make/lib/install.sh defaults (bundled toolchain)."""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
INSTALL_SH = ROOT / "make" / "lib" / "install.sh"


def _fail(msg: str) -> None:
    print(f"INSTALL-SH FAILED: {msg}", file=sys.stderr)
    raise SystemExit(1)


def _ok(msg: str) -> None:
    print(f"  ok — {msg}")


def main() -> int:
    text = INSTALL_SH.read_text(encoding="utf-8")
    if not re.search(r"^WITH_TOOLCHAIN=1\s*$", text, re.M):
        _fail("WITH_TOOLCHAIN must default to 1 (bundled LLVM)")
    if "--no-toolchain" not in text:
        _fail("missing --no-toolchain opt-out")
    if "toolchain install --download" not in text:
        _fail("install.sh should fall back to toolchain install --download")
    if "brew install llvm && nyra toolchain install" in text and "You do NOT need" not in text:
        _fail("install next-steps still push manual brew llvm as required")

    # Help text parses
    rc = subprocess.call(
        ["sh", str(INSTALL_SH), "--help"],
        cwd=str(ROOT),
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if rc != 0:
        _fail("--help exited non-zero")

    # Unknown flag still fails
    rc = subprocess.call(
        ["sh", str(INSTALL_SH), "--not-a-real-flag"],
        cwd=str(ROOT),
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if rc == 0:
        _fail("unknown flag should fail")

    _ok("install.sh defaults + help + flag parsing")
    print("INSTALL-SH: all checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
