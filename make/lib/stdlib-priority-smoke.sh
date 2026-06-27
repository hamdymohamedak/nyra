#!/usr/bin/env bash
# Smoke-test high-priority stdlib modules (strconv, flag, bufio, context, sync, csv, mime).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
# shellcheck source=nyra-bin.sh
source "$ROOT/make/lib/nyra-bin.sh"
if [[ -z "${NYRA_BIN:-}" ]]; then nyra_export_cli; fi
NYRA="${NYRA:-$NYRA_BIN}"

EXAMPLE="$ROOT/examples/stdlib_priority_smoke.ny"
log() { echo "stdlib-priority-smoke: $*" >&2; }

log "check $EXAMPLE"
$NYRA check "$EXAMPLE"

log "run"
out="$($NYRA run "$EXAMPLE" 2>&1)"
echo "$out"

echo "$out" | grep -q "42" || { log "missing atoi output"; exit 1; }
echo "$out" | grep -q "99" || { log "missing itoa output"; exit 1; }

log "ok"
