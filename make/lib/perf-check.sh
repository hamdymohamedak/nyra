#!/usr/bin/env bash
# CI perf regression guard: release build + llvm opt + compare to benchmarks/ci-baseline.json
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BASELINE="$ROOT/benchmarks/ci-baseline.json"
NYRA="$ROOT/target/release/nyra"

if [[ ! -f "$BASELINE" ]]; then
  echo "perf-check: missing $BASELINE" >&2
  exit 1
fi

cd "$ROOT"
cargo build --release -q -p cli

measure_ms() {
  local bin="$1"
  python3 - "$bin" <<'PY'
import json, subprocess, sys, time

bin_path = sys.argv[1]
start = time.perf_counter()
out = subprocess.run([bin_path], capture_output=True, text=True, check=True)
elapsed_ms = (time.perf_counter() - start) * 1000
print(json.dumps({"ms": elapsed_ms, "stdout": out.stdout.strip()}))
PY
}

log() { echo "perf-check: $*" >&2; }

python3 - "$BASELINE" "$ROOT" "$NYRA" <<'PY'
import json, subprocess, sys, tempfile, os, time

baseline_path, root, nyra = sys.argv[1], sys.argv[2], sys.argv[3]
with open(baseline_path) as f:
    baseline = json.load(f)

errors = []
for name, suite in baseline["suites"].items():
    src = os.path.join(root, suite["path"])
    if not os.path.isfile(src):
        errors.append(f"{name}: missing source {suite['path']}")
        continue
    with tempfile.TemporaryDirectory(prefix="nyra_perf_") as td:
        out_bin = os.path.join(td, name)
        build = subprocess.run(
            [nyra, "build", src, "-o", out_bin, "--release"],
            capture_output=True,
            text=True,
        )
        if build.returncode != 0:
            errors.append(f"{name}: build failed\n{build.stderr}")
            continue
        built_line = next(
            (ln[7:] for ln in build.stdout.splitlines() if ln.startswith("built: ")),
            out_bin,
        )
        if not os.path.isfile(built_line) or not os.access(built_line, os.X_OK):
            errors.append(f"{name}: no executable (built: {built_line!r})")
            continue
        start = time.perf_counter()
        run = subprocess.run([built_line], capture_output=True, text=True, check=True)
        ms = (time.perf_counter() - start) * 1000
        stdout = run.stdout.strip()
        max_ms = float(suite["wall_ms_max"])
        print(f"{name}: {ms:.2f}ms (max {max_ms}ms), output={stdout!r}")
        expected = suite.get("expected_stdout")
        if expected is not None and stdout != expected:
            errors.append(f"{name}: stdout {stdout!r} != expected {expected!r}")
        if ms > max_ms:
            errors.append(f"{name}: wall time {ms:.2f}ms > ceiling {max_ms}ms")

if errors:
    for e in errors:
        print(f"REGRESSION: {e}", file=sys.stderr)
    sys.exit(1)
PY

log "ok"
