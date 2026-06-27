#!/usr/bin/env bash
# Remove compiletest run artifacts under tests/suite/ (target/, .nyra-cache/).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SUITE="$ROOT/tests/suite"
if [[ ! -d "$SUITE" ]]; then
  exit 0
fi
removed=0
while IFS= read -r -d '' d; do
  rm -rf "$d"
  removed=$((removed + 1))
done < <(find "$SUITE" -type d \( -name target -o -name .nyra-cache \) -print0 2>/dev/null || true)
if [[ "${NYRA_SUITE_CLEAN_VERBOSE:-0}" == "1" ]]; then
  echo "suite-clean: removed $removed artifact dir(s) under tests/suite" >&2
fi
