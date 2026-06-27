#!/usr/bin/env bash
# Example corpus only. Full suite: make test-all
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
echo "note: for the full Nyra test suite run: make test-all" >&2
cargo test -p compiler --test examples_corpus -- --nocapture
