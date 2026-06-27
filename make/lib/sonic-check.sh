#!/usr/bin/env bash
# Sonic framework conformance (CONF-ENT-*, CONF-MSVC-*).
# Language Core tests: make test-all
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
export NYRA_TEST_STATS_FILE="${NYRA_TEST_STATS_FILE:-$ROOT/target/.nyra-test-all-stats}"
# shellcheck source=test-stats.sh
source "$ROOT/make/lib/test-stats.sh"
echo "sonic-check: Sonic framework + enterprise workspace smoke" >&2

run_sonic_cargo_test() {
  local out=""
  local ec=0
  out="$(cargo test -p compiler "$@" 2>&1)" || ec=$?
  printf '%s\n' "$out"
  nyra_stats_add_cargo_test_results "$out"
  return "$ec"
}

run_sonic_cargo_test --test conformance conf_ent -- --nocapture
run_sonic_cargo_test --test conformance conf_msvc -- --nocapture
run_sonic_cargo_test --test integration compiles_enterprise_platform -- --nocapture
run_sonic_cargo_test --test integration compiles_microservice_async_smoke -- --nocapture
run_sonic_cargo_test --test integration compiles_graph_arc_smoke -- --nocapture
run_sonic_cargo_test --test integration compiles_monolith_struct_smoke -- --nocapture
nyra_stats_check examples/projects/enterprise_platform/main.ny
nyra_stats_check examples/projects/team_api/main.ny
