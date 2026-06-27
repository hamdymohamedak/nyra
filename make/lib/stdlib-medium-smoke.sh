#!/usr/bin/env bash
# Smoke-test medium-priority stdlib modules.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
# shellcheck source=nyra-bin.sh
source "$ROOT/make/lib/nyra-bin.sh"
if [[ -z "${NYRA_BIN:-}" ]]; then nyra_export_cli; fi
NYRA="${NYRA:-$NYRA_BIN}"

EXAMPLE="$ROOT/examples/stdlib_medium_smoke.ny"
log() { echo "stdlib-medium-smoke: $*" >&2; }

log "check $EXAMPLE"
$NYRA check "$EXAMPLE"

log "run"
out="$($NYRA run "$EXAMPLE" 2>&1)"
echo "$out"

echo "$out" | grep -q "Hello Nyra" || { log "missing template output"; exit 1; }
echo "$out" | grep -q "ping" || { log "missing rpc output"; exit 1; }

log "ok"
