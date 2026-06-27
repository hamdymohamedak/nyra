#!/usr/bin/env bash
# Native Nyra test files (syntax, ownership, imports) via `nyra test`.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
export NYRA_TEST_STATS_FILE="${NYRA_TEST_STATS_FILE:-$ROOT/target/.nyra-test-all-stats}"
# shellcheck source=test-stats.sh
source "$ROOT/make/lib/test-stats.sh"

log() { echo "nyra-lang-tests: $*" >&2; }
fail() { log "FAILED: $*"; exit 1; }

# shellcheck source=nyra-bin.sh
source "$ROOT/make/lib/nyra-bin.sh"
nyra_export_cli
NYRA=("$NYRA_BIN")

log "nyra test tests/nyra"
if ! out="$("${NYRA[@]}" test tests/nyra 2>&1)"; then
  printf '%s\n' "$out" >&2
  fail "nyra test tests/nyra"
fi
printf '%s\n' "$out" >&2
if ! printf '%s\n' "$out" | grep -q 'tests passed'; then
  fail "nyra test tests/nyra (no tests passed line)"
fi
nyra_stats_pass

log "import_consts fixture (multi-file import + const)"
out="$("${NYRA[@]}" run "$ROOT/tests/fixtures/import_consts" 2>/dev/null)" || {
  fail "nyra run import_consts fixture"
}
if [[ "$out" != $'Hello\n42' ]]; then
  printf '%s\n' "$out" >&2
  fail "import_consts fixture expected Hello+42, got: $(printf %q "$out")"
fi
nyra_stats_pass

log "ok — nyra native language tests"
