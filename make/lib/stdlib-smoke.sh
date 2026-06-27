#!/usr/bin/env bash
# Compile-check every Nyra stdlib module. Full suite: make test-all
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
export NYRA_TEST_STATS_FILE="${NYRA_TEST_STATS_FILE:-$ROOT/target/.nyra-test-all-stats}"
# shellcheck source=test-stats.sh
source "$ROOT/make/lib/test-stats.sh"

log() { echo "stdlib-smoke: $*" >&2; }
fail() { log "FAILED: $*"; exit 1; }

count=0
while IFS= read -r -d '' path; do
  rel="${path#$ROOT/}"
  log "check $rel"
  if ! nyra_stats_check "$path"; then
    fail "check $rel"
  fi
  count=$((count + 1))
done < <(find "$ROOT/stdlib" -name '*.ny' -print0 | sort -z)

log "ok — $count stdlib modules"
