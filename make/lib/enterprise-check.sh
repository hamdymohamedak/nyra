#!/usr/bin/env bash
# Deprecated: use `make smoke-enterprise` (alias for smoke-sonic).
exec "$(dirname "$0")/sonic-check.sh" "$@"
