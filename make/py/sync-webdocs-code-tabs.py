#!/usr/bin/env python3
"""Resync all webDocs code-tab pairs: zero-types easy panel + regenerated typed panel."""
from __future__ import annotations

import importlib.util
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WEB = ROOT / "webDocs"

_spec = importlib.util.spec_from_file_location(
    "snippet_types", ROOT / "make" / "py" / "snippet-types.py"
)
_st = importlib.util.module_from_spec(_spec)
assert _spec and _spec.loader
_spec.loader.exec_module(_st)

TAB_PAIR_RE = re.compile(
    r"(<!-- NYRA_SNIPPET_START -->\s*)?"
    r'<div class="code-tabs"[^>]*>\s*'
    r'<div class="code-tabs-bar"[^>]*>.*?</div>\s*'
    r'<div class="code-panel active" data-panel="easy"[^>]*><pre><code>(.*?)</code></pre></div>\s*'
    r'<div class="code-panel" data-panel="typed"[^>]*><pre><code>(.*?)</code></pre></div>\s*'
    r"</div>\s*"
    r"(<!-- NYRA_SNIPPET_END -->\s*)?",
    re.S,
)

SKIP = {"stdlib.html"}


def unescape(s: str) -> str:
    return (
        s.replace("&quot;", '"')
        .replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace("&amp;", "&")
    )


def escape(s: str) -> str:
    return (
        s.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )


def sync_pair(easy_raw: str) -> tuple[str, str]:
    easy = unescape(easy_raw)
    easy = _st.fix_doc_snippet_formatting(easy)
    easy = _st.strip_optional_types(easy)
    easy = _st.normalize_easy_snippet(easy)
    easy = _st.fix_struct_literal_commas(easy)
    typed = _st.add_explicit_types(easy)
    return easy.rstrip(), typed.rstrip()


def process_html(path: Path) -> int:
    html = path.read_text(encoding="utf-8")
    count = 0

    def repl(m: re.Match[str]) -> str:
        nonlocal count
        prefix, easy_raw, typed_raw, suffix = m.group(1) or "", m.group(2), m.group(3), m.group(4) or ""
        easy, typed = sync_pair(easy_raw)
        count += 1
        block = f"""<div class="code-tabs" data-code-tabs>
  <div class="code-tabs-bar" role="tablist">
    <button type="button" class="code-tab active" role="tab" data-tab="easy" aria-selected="true">Without types</button>
    <button type="button" class="code-tab" role="tab" data-tab="typed" aria-selected="false">With types</button>
  </div>
  <div class="code-panel active" data-panel="easy" role="tabpanel"><pre><code>{escape(easy)}</code></pre></div>
  <div class="code-panel" data-panel="typed" role="tabpanel" hidden><pre><code>{escape(typed)}</code></pre></div>
</div>"""
        return f"{prefix}{block}{suffix}"

    new_html = TAB_PAIR_RE.sub(repl, html)
    if count:
        path.write_text(new_html, encoding="utf-8")
    return count


def main() -> int:
    total = 0
    for path in sorted(WEB.glob("*.html")):
        if path.name in SKIP:
            continue
        n = process_html(path)
        if n:
            print(f"{path.name}: {n} tab(s)")
            total += n
    print(f"sync-webdocs-code-tabs: {total} tab pair(s) updated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
