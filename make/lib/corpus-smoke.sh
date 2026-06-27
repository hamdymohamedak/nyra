#!/usr/bin/env bash
# nyra check on every examples/corpus manifest entry with expect_compile=true.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
export NYRA_TEST_STATS_FILE="${NYRA_TEST_STATS_FILE:-$ROOT/target/.nyra-test-all-stats}"
# shellcheck source=test-stats.sh
source "$ROOT/make/lib/test-stats.sh"

log() { echo "corpus-smoke: $*" >&2; }
fail() { log "FAILED: $*"; exit 1; }

paths="$(python3 - <<'PY'
import tomllib
from pathlib import Path

manifest = Path("tests/corpus/manifest.toml")
data = tomllib.loads(manifest.read_text())
for case in data.get("case", []):
    if case.get("expect_compile", True):
        print(case["path"])
PY
)"

count=0
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  log "check corpus: $path"
  if ! nyra_stats_check "$path"; then
    fail "corpus check $path"
  fi
  count=$((count + 1))
done <<<"$paths"

log "ok — $count corpus entries"
