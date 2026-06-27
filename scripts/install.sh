#!/usr/bin/env bash
# One-line installer entry point (curl | sh). Implementation: make/lib/install.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec bash "$ROOT/make/lib/install.sh" "$@"
