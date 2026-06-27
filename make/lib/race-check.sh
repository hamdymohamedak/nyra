#!/usr/bin/env bash
# ThreadSanitizer link smoke: `nyra build --race` compiles and runs a spawn program.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

log() { echo "race-check: $*" >&2; }

if ! command -v clang >/dev/null 2>&1; then
  log "clang not found — skipping"
  exit 0
fi

if ! clang -fsanitize=thread -x c - -o /dev/null 2>/dev/null <<<'int main(){return 0;}' ; then
  log "clang TSan not supported on this host — skipping"
  exit 0
fi

log "building workspace"
cargo build --workspace -q

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/main.ny" <<'NY'
import "stdlib/async_v1.ny"

fn main() {
    let h = async_sleep_ms(1)
    print(await h)
}
NY

log "nyra build --race"
cargo run -q -p cli -- build "$TMP/main.ny" --debug-symbols --race -o "$TMP/main_bin"

log "running under TSan"
"$TMP/main_bin"

log "ok"
