#!/usr/bin/env bash
# Native Nyra race runtime smoke: `nyra build --race-native` links rt_race.c.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

log() { echo "race-native-check: $*" >&2; }

if ! command -v clang >/dev/null 2>&1; then
  log "clang not found — skipping"
  exit 0
fi

log "building workspace"
cargo build --workspace -q

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/main.ny" <<'NY'
import "stdlib/race.ny"

fn main() {
    Race_init()
    print(Race_enabled())
}
NY

log "nyra build --race-native"
cargo run -q -p cli -- build "$TMP/main.ny" --debug-symbols --race-native

log "ok"
