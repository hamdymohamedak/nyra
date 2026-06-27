#!/usr/bin/env python3
"""Strip Nyra type annotations from Apps/*.ny (keep extern fn, struct fields, array params)."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APPS = ROOT / "Apps"

SKIP_SUBPATH = "vendor/bindings/"


def should_process(path: Path) -> bool:
    s = path.as_posix()
    return s.endswith(".ny") and SKIP_SUBPATH not in s


def strip_fn_line(line: str) -> str:
    stripped = line.lstrip()
    if stripped.startswith("extern fn"):
        return line
    if not re.match(r"fn\s", stripped):
        return line

    # fn Name<T>(...) -> remove generic header
    line = re.sub(r"(fn\s+\w+)<[^>]+>", r"\1", line)

    # Remove return type before '{'
    line = re.sub(r"\s*->\s*[^({]+(?=\s*\{)", "", line)

    # Strip parameter types inside parentheses (keep array types like [i32; 8])
    def strip_params(match: re.Match[str]) -> str:
        inner = match.group(1)
        parts: list[str] = []
        depth = 0
        cur = ""
        for ch in inner:
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
            elif ch == "," and depth == 0:
                parts.append(cur)
                cur = ""
                continue
            cur += ch
        if cur:
            parts.append(cur)

        out: list[str] = []
        for part in parts:
            p = part.strip()
            if not p:
                continue
            if re.search(r":\s*\[", p):
                out.append(p)
            else:
                p = re.sub(r"(\b(?:mut\s+)?[_\w]+)\s*:\s*[^,=()]+", r"\1", p)
                out.append(p.strip())
        return "(" + ", ".join(out) + ")"

    return re.sub(r"\(([^()]*)\)", strip_params, line)


def strip_let_line(line: str) -> str:
    if "print(" in line and "color:" in line:
        return line
    if not re.search(r"\blet\s", line):
        return line
    # Keep array-typed lets: let a: [i32; 8] = ...
    if re.search(r"\blet\s+(?:mut\s+)?[_\w]+\s*:\s*\[", line):
        return line
    return re.sub(r"(\blet\s+(?:mut\s+)?[_\w]+)\s*:\s*[^=]+(?==)", r"\1", line)


def process_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)
    changed = False
    out: list[str] = []
    for line in lines:
        new = strip_fn_line(line)
        new = strip_let_line(new)
        if new != line:
            changed = True
        out.append(new)
    if changed:
        path.write_text("".join(out), encoding="utf-8")
    return changed


def main() -> int:
    changed_files = 0
    for path in sorted(APPS.rglob("*.ny")):
        if not should_process(path):
            continue
        if process_file(path):
            changed_files += 1
            print(path.relative_to(ROOT))
    print(f"updated {changed_files} files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
