# Benchmark results

After running the benchmark script:

- **[latest.html](latest.html)** — full visual report (opens automatically in your browser):
  - comparison matrix (every language × every suite)
  - language leaderboard (avg time/RAM, win counts)
  - per-suite tables, charts, and Nyra analysis
  - raw data table
- **[latest.txt](latest.txt)** — summary table plus **DETAILED RESULTS** per benchmark
- **`data.tsv`** — machine-readable `suite`, `language`, `ms_mean`, `peak_rss_kb`

```bash
# From repo root — runs benchmark, generates report, opens browser
./scripts/bench.sh
```

Optional environment variables:

- `BENCH_RUNS=10` — timed iterations (default `5`)
- `BENCH_WARMUP=3` — discarded warmup runs (default `1`)
- `BENCH_RELEASE=0` — debug `nyra` build
- `BENCH_SERVE=0` — open `file://` only (no local HTTP server)
- `BENCH_NO_OPEN=1` — skip opening the browser (CI)
- `BENCH_QUICK=1` — subset: hello, arithmetic, nested, cpu_bound (CI-friendly)
- `BENCH_UPDATE_README=0` — skip patching `README.md` benchmark section
- `BENCH_PORT=8766` — local server port (default `8766`)

`latest.txt`, `latest.html`, and `data.tsv` are regenerated on each run. Copy snapshots if you want to keep history.

Re-open the last report without re-running benchmarks:

```bash
BENCH_SERVE=1 BENCH_NO_OPEN=0 python3 -m http.server 8766 --bind 127.0.0.1 --directory examples/comparison/results
# → http://127.0.0.1:8766/latest.html
```
