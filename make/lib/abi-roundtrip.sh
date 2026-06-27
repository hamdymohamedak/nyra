#!/usr/bin/env bash
# ABI header + FFI roundtrip only. Full suite: make test-all
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo "note: for the full Nyra test suite run: make test-all" >&2

python3 "$ROOT/make/py/gen-abi-header.py"
cargo run --quiet -p cli -- build \
  "$ROOT/examples/ffi/export_greet/main.ny" \
  -o libnyra_greet \
  --cdylib
cargo run --quiet --manifest-path "$ROOT/examples/ffi/export_greet/rust_host/Cargo.toml"
