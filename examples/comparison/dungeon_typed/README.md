# Dungeon Steps benchmark

Same **Dungeon Steps** app as `App/NyraApp`: multi-file Nyra (`.ny`), single-file **Go**, **Rust**, **Node**, **Python**, and **Java**.

Expected output:

```
Dungeon Steps
65
0
3
```

## Smoke test

```bash
# Nyra (project dir)
cargo run -- run examples/comparison/dungeon

# JavaScript
node examples/comparison/dungeon/dungeon.js

# Go
go run examples/comparison/dungeon/dungeon.go

# Rust
rustc -O examples/comparison/dungeon/dungeon.rs -o /tmp/dungeon_rs && /tmp/dungeon_rs

# Python
python3 examples/comparison/dungeon/dungeon.py

# Java
javac examples/comparison/dungeon/Dungeon.java && java -cp examples/comparison/dungeon Dungeon
```

## Benchmark (time + peak RAM)

From repo root:

```bash
./scripts/bench.sh
```

Includes suite **`dungeon`** in `examples/comparison/results/latest.txt`.

Release Nyra is the default. For debug: `BENCH_RELEASE=0 ./scripts/bench.sh`
