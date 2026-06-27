#!/usr/bin/env bash
# Micro-benchmark: escape-analysis optimizations (LocalChannel vs runtime channel, SROA, strings).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
DIR="$(cd "$(dirname "$0")" && pwd)"
NYRA=(cargo run --quiet --manifest-path "$ROOT/Cargo.toml" --bin nyra --)

log() { echo "$@" >&2; }

build_release() {
  local src="$1"
  local name="$2"
  log "build --release $src"
  "${NYRA[@]}" build --release "$src" -o "$name" >&2
  echo "$DIR/target/release/$name"
}

time_run() {
  local label="$1"
  local bin="$2"
  log "run $label"
  /usr/bin/time -p "$bin" 2>&1 | awk -v label="$label" '
    /^real / { printf "%-22s %s sec (checksum below)\n", label, $2 }
  '
}

show_escape() {
  local src="$1"
  log "escape report: $src"
  "${NYRA[@]}" build --verbose "$src" -o /dev/null 2>&1 | grep -E "escape analysis|escape:|local channel|no_escape" || true
  echo >&2
}

main() {
  log "=== Escape analysis micro-benchmark ==="
  log "Release builds (use BENCH_RELEASE=0 for debug — some suites need release)."
  echo

  show_escape "$DIR/local_channel_small.ny"
  show_escape "$DIR/spawn_channel_small.ny"
  show_escape "$DIR/point_sroa.ny"
  show_escape "$DIR/string_local.ny"

  local local_bin spawn_bin sroa_bin ret_bin str_local str_ret
  local_bin="$(build_release "$DIR/local_channel.ny" "local_channel_bench")"
  spawn_bin="$(build_release "$DIR/spawn_channel.ny" "spawn_channel_bench")"
  sroa_bin="$(build_release "$DIR/point_sroa.ny" "point_sroa_bench")"
  ret_bin="$(build_release "$DIR/point_return.ny" "point_return_bench")"
  str_local="$(build_release "$DIR/string_local.ny" "string_local_bench")"
  str_ret="$(build_release "$DIR/string_return.ny" "string_return_bench")"

  echo "=== Channel (N=500000, expected checksum 999749132) ==="
  echo -n "local (LocalChannel):  "; "$local_bin"
  time_run "local_channel" "$local_bin"
  echo -n "spawn (runtime/mutex): "; "$spawn_bin"
  time_run "spawn_channel" "$spawn_bin"

  echo
  echo "=== Point struct (expected 150000000) ==="
  echo -n "SROA (NoEscape):       "; "$sroa_bin"
  time_run "point_sroa" "$sroa_bin"
  echo -n "return each iter:      "; "$ret_bin"
  time_run "point_return" "$ret_bin"

  echo
  echo "=== String in struct ==="
  echo -n "local literal:         "; "$str_local"
  time_run "string_local" "$str_local"
  echo -n "return each iter:      "; "$str_ret"
  time_run "string_return" "$str_ret"

  echo
  echo "Tip: nyra build --verbose FILE.ny — escape plan"
  echo "Tip: inspect @main in LLVM IR for nyra_channel_* / str_clone / alloca %Point"
}

main "$@"
