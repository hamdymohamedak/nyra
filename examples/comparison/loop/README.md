# Loop benchmark (sum 0 .. N-1)

| File | Purpose |
|------|---------|
| `sum_loop.ny` | Full benchmark (N = 10_000_000) |
| `sum_loop_small.ny` | Fast tests (N = 1000) |
| `sum_loop.js` / `sum_loop.go` | Same algorithm as full `.ny` |

```bash
cargo run -- run examples/comparison/loop/sum_loop.ny
cargo run -- run examples/comparison/loop/sum_loop_small.ny
node sum_loop.js
go run sum_loop.go
```

Nyra supports `mut x = expr`, `let mut`, and `x = expr` (mutable variables only).

`sum_loop.js` / `sum_loop.go` print the result **once after** the loop (I/O not inside the hot loop).
