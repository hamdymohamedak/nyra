#!/usr/bin/env bash
# Fail if webDocs code-tab pairs are out of sync with make/py/sync-webdocs-code-tabs.py
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

for f in webDocs/*.html; do
  cp "$f" "$TMP/$(basename "$f")"
done

python3 "$ROOT/make/py/sync-webdocs-code-tabs.py" >/dev/null

drift=0
for f in webDocs/*.html; do
  base="$(basename "$f")"
  if ! diff -q "$f" "$TMP/$base" >/dev/null 2>&1; then
    echo "check-webdocs-code-tabs: drift in $base — run: make sync-webdocs-code-tabs" >&2
    drift=1
  fi
done

if [[ "$drift" -ne 0 ]]; then
  exit 1
fi

echo "check-webdocs-code-tabs: ok"
