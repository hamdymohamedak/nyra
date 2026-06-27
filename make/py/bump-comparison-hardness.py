#!/usr/bin/env python3
"""Bump iteration counts in examples/comparison (all languages, same checksum)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
COMP = ROOT / "examples" / "comparison"

# Apply longest-first to avoid substring collisions (e.g. 50M inside 150M).
GLOBAL = sorted(
    [
        ("250_000_000", "375_000_000"),
        ("250000000", "375000000"),
        ("120_000_000", "180_000_000"),
        ("120000000", "180000000"),
        ("180_000_000", "270_000_000"),
        ("180000000", "270000000"),
        ("50_000_000", "80_000_000"),
        ("50000000", "80000000"),
    ],
    key=lambda p: len(p[0]),
    reverse=True,
)

NESTED_ONLY = [("4000", "4000"), ("3200", "4000")]  # idempotent second value

OLD_EXPECTED = sorted(
    [
        ("656250007", "320312507"),
        ("209556590", "751659594"),
        ("18376614", "3552224"),
        ("150000000", "240000000"),
        ("808", "415"),
        ("662195839", "473067162"),
    ],
    key=lambda p: len(p[0]),
    reverse=True,
)

EXT = {".ny", ".rs", ".go", ".c", ".cpp", ".js", ".py", ".java", ".md", ".html", ".txt", ".tsv"}


def patch_text(text: str, nested: bool) -> str:
    for old, new in GLOBAL:
        text = text.replace(old, new)
    if nested:
        for old, new in NESTED_ONLY:
            if old != new:
                text = text.replace(old, new)
    for old, new in OLD_EXPECTED:
        text = text.replace(old, new)
    return text


def main() -> None:
    for path in sorted(COMP.rglob("*")):
        if not path.is_file():
            continue
        if path.suffix not in EXT:
            continue
        if "target" in path.parts or "results" in path.parts:
            continue
        if "dungeon_typed" in path.parts:
            continue
        nested = "nested" in path.parts
        old = path.read_text(encoding="utf-8", errors="replace")
        new = patch_text(old, nested)
        if new != old:
            path.write_text(new, encoding="utf-8")
            print(path.relative_to(ROOT))


if __name__ == "__main__":
    main()
