#!/usr/bin/env bash
# Build Nyra VS Code extension (.vsix). Optionally bundle host nyra binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EXT="$ROOT/extensions/nyra"
BUNDLE="${BUNDLE_NYRA:-0}"

cd "$ROOT"
cargo build -q -p cli

if [[ "$BUNDLE" == "1" ]]; then
  PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)"
  mkdir -p "$EXT/bin"
  cp "$ROOT/target/debug/nyra" "$EXT/bin/nyra-$PLATFORM"
  echo "package-vscode: bundled nyra -> extensions/nyra/bin/nyra-$PLATFORM"
fi

cp "$ROOT/grammar/nyra.tmLanguage.json" "$EXT/syntaxes/nyra.tmLanguage.json"
cd "$EXT"
npm install --silent
npm run compile
npm run package
echo "package-vscode: $(ls -1 "$EXT"/*.vsix 2>/dev/null | tail -1)"
