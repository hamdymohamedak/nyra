#!/usr/bin/env bash
# Runtime smoke for ny-serde / ny-toml (rust::serde_json / rust::toml bridges).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
export NYRA_TEST_STATS_FILE="${NYRA_TEST_STATS_FILE:-$ROOT/target/.nyra-test-all-stats}"
# shellcheck source=test-stats.sh
source "$ROOT/make/lib/test-stats.sh"

log() { echo "serde-pkg-smoke: $*" >&2; }
fail() { log "FAILED: $*"; exit 1; }

# shellcheck source=nyra-bin.sh
source "$ROOT/make/lib/nyra-bin.sh"
nyra_export_cli
NYRA=("$NYRA_BIN")
SERDE_PKG="$ROOT/examples/packages/ny-serde"
TOML_PKG="$ROOT/examples/packages/ny-toml"
EXAMPLE_PROJ="$ROOT/examples/serde_json_pkg"

bind_and_test() {
  local crate="$1"
  local project="$2"
  local test_file="$3"
  log "bind rust $crate --template ($project)"
  if ! "${NYRA[@]}" bind rust "$crate" --template --project "$project" >/dev/null 2>&1; then
    fail "bind rust $crate --template"
  fi
  log "nyra test $test_file"
  if ! out="$("${NYRA[@]}" test "$test_file" 2>&1)"; then
    printf '%s\n' "$out" >&2
    fail "nyra test $test_file"
  fi
  printf '%s\n' "$out" >&2
  if ! printf '%s\n' "$out" | grep -q 'tests passed'; then
    fail "nyra test $test_file (no tests passed line)"
  fi
  nyra_stats_pass
}

bind_and_test serde_json "$SERDE_PKG" "$SERDE_PKG/serde_test.ny"
bind_and_test toml "$TOML_PKG" "$TOML_PKG/toml_test.ny"

log "bind serde_json for example project"
if ! "${NYRA[@]}" bind rust serde_json --template --project "$EXAMPLE_PROJ" >/dev/null 2>&1; then
  fail "bind serde_json for example project"
fi

log "nyra run examples/serde_json_pkg/main.ny"
out="$("${NYRA[@]}" run "$EXAMPLE_PROJ/main.ny" 2>&1 | grep -E '^\{' | tail -1 || true)"
if [[ "$out" != '{"lang":"nyra","version":1}' ]]; then
  printf '%s\n' "$out" >&2
  fail "serde_json_pkg example (expected compact JSON, got: $(printf %q "$out")"
fi
nyra_stats_pass

log "ok — serde package smoke"
