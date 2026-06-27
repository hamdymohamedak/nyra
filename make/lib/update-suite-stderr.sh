#!/usr/bin/env bash
# Refresh `.stderr` golden files for fail tests under tests/suite/fail/generated/stderr_full/
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
export NYRA_SUITE_UPDATE=1
exec cargo test -p compiler suite_fail_generated_stderr_full -- --test-threads=1 "$@"
