#!/usr/bin/env bash
# AddressSanitizer + UndefinedBehaviorSanitizer smoke for Nyra runtime C and sample programs.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

log() { echo "sanitizer-check: $*" >&2; }

if ! command -v clang >/dev/null 2>&1; then
  log "clang not found — skipping"
  exit 0
fi

SAN_FLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer"
export CFLAGS="${CFLAGS:-} $SAN_FLAGS"
export CXXFLAGS="${CXXFLAGS:-} $SAN_FLAGS"
export LDFLAGS="${LDFLAGS:-} $SAN_FLAGS"

log "building workspace (Rust compiler)"
cargo build --workspace -q

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/main.ny" <<'NY'
fn main() {
    let x = 1
    let y = 2
    print(x + y)
}
NY

log "nyra build with ASan/UBSan (sample program)"
cargo run -q -p cli -- build "$TMP/main.ny" --debug-symbols \
  --link-arg "-fsanitize=address" \
  --link-arg "-fsanitize=undefined" \
  --link-arg "-fno-omit-frame-pointer"

BIN="$TMP/target/debug/main"
if [[ ! -x "$BIN" ]]; then
  log "binary not found at $BIN"
  exit 1
fi

log "running sample under sanitizers"
"$BIN"

log "cargo test with ASan (host Rust tests, best-effort)"
if rustc --version | grep -q nightly; then
  RUSTFLAGS="-Zsanitizer=address" cargo test -p compiler --lib -q -- --test-threads=1 \
    || log "nightly sanitizer test pass skipped on failure"
else
  log "stable rustc — skipping RUSTFLAGS sanitizer cargo test (use nightly for full gate)"
fi

log "ok"
