#!/usr/bin/env bash
# Smoke-test database stdlib: LSM, B-tree pages, SQL parser, SSTable (+ SQLite when available).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=nyra-bin.sh
source "$ROOT/make/lib/nyra-bin.sh"
if [[ -z "${NYRA_BIN:-}" ]]; then nyra_export_cli; fi
NYRA="${NYRA:-$NYRA_BIN}"

log() { echo "database-smoke: $*" >&2; }

log "stdlib gaps (zero-types)"
out="$("$NYRA" run "$ROOT/tests/nyra/stdlib_gaps.ny" 2>&1)" || { echo "$out"; exit 1; }
echo "$out"
echo "$out" | grep -q "stdlib_gaps ok" || { log "FAIL stdlib_gaps zero-types"; exit 1; }

log "stdlib gaps (typed)"
out="$("$NYRA" run "$ROOT/tests/nyra/stdlib_gaps.typed.ny" 2>&1)" || { echo "$out"; exit 1; }
echo "$out"
echo "$out" | grep -q "stdlib_gaps ok" || { log "FAIL stdlib_gaps typed"; exit 1; }

log "sqlite smoke (skip if libsqlite3 missing)"
bash "$ROOT/make/lib/sqlite-smoke.sh"

log "ok"
