#!/usr/bin/env bash
# Count file-based suite tests under tests/suite/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SUITE="$ROOT/tests/suite"

count_ny() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    echo 0
    return
  fi
  find "$dir" -name '*.ny' -type f | while read -r p; do
    rel="${p#"$SUITE"/}"
    if [[ "$rel" == projects/* && "$(basename "$p")" != "main.ny" ]]; then
      continue
    fi
    echo 1
  done | wc -l | tr -d ' '
}

pass="$(count_ny "$SUITE/pass")"
pass_projects="$(count_ny "$SUITE/projects/pass")"
fail="$(count_ny "$SUITE/fail")"
fail_projects="$(count_ny "$SUITE/projects/fail")"
run="$(count_ny "$SUITE/run")"
run_projects="$(count_ny "$SUITE/projects/run")"
total=$((pass + pass_projects + fail + fail_projects + run + run_projects))

echo "nyra suite tests: total=$total pass=$((pass + pass_projects)) fail=$((fail + fail_projects)) run=$((run + run_projects))"

baseline="$SUITE/.count-baseline"
if [[ -f "$baseline" ]]; then
  read -r min_total <"$baseline"
  if [[ "$total" -lt "$min_total" ]]; then
    echo "ERROR: suite count regressed ($total < $min_total)" >&2
    exit 1
  fi
fi
