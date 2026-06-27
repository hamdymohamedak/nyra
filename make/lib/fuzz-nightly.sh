#!/usr/bin/env bash
# Nightly fuzz gate — longer than fuzz-smoke.sh (5 min per target).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

if ! command -v cargo-fuzz >/dev/null 2>&1; then
  echo "fuzz-nightly: cargo-fuzz not installed — skipping"
  exit 0
fi

bash "$ROOT/make/lib/sync-fuzz-corpus.sh"

fuzz_sanitizer() {
  local mode="${NYRA_FUZZ_SANITIZER:-auto}"
  if [[ "$mode" != "auto" ]]; then
    echo "$mode"
    return
  fi
  if rustup run nightly rustc -V >/dev/null 2>&1; then
    echo "address"
  else
    echo "none"
  fi
}

fuzz_extra_args() {
  local target="$1"
  local -a args=()
  local dict="$ROOT/fuzz/dictionaries/nyra.dict"
  if [[ -f "$dict" ]]; then
    args+=(-dict="$dict")
  fi
  args+=(-max_len=65536)
  if [[ "$target" == "fuzz_codegen" ]]; then
    args+=(-max_total_time=300 -rss_limit_mb=8192)
  else
    args+=(-max_total_time=300 -rss_limit_mb=4096)
  fi
  printf '%s\n' "${args[@]}"
}

SAN="$(fuzz_sanitizer)"
if [[ "$SAN" == "none" ]]; then
  echo "fuzz-nightly: nightly unavailable — using --sanitizer none"
fi

fuzz_cargo() {
  if [[ "$SAN" == "none" ]]; then
    cargo fuzz "$@"
  else
    cargo +nightly fuzz "$@"
  fi
}

cd "$ROOT/fuzz"
for target in fuzz_lexer fuzz_parser fuzz_compile fuzz_gen fuzz_codegen; do
  echo "fuzz-nightly: $target (sanitizer=$SAN)"
  # shellcheck disable=SC2046
  fuzz_cargo run "$target" --sanitizer "$SAN" -- $(fuzz_extra_args "$target")
done
echo "fuzz-nightly: ok"
