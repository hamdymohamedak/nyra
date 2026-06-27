# Fibonacci loop (iterative)

Iterative Fibonacci: 35 swap steps starting from `a=0`, `b=1`.

| Language | File |
|----------|------|
| Nyra | `fib.ny` |
| Go | `fib.go` |
| Rust | `fib.rs` |
| Node | `fib.js` |
| Python | `fib.py` |
| Java | `Fib.java` |

**Expected stdout:** `14930352`

Exercises `while`, mutable locals, and integer arithmetic — a different hot path than the linear `loop/` sum benchmark.

```bash
cargo run --bin nyra -- run examples/comparison/fib/fib.ny
go run examples/comparison/fib/fib.go
rustc -O examples/comparison/fib/fib.rs -o /tmp/fib_rs && /tmp/fib_rs
node examples/comparison/fib/fib.js
python3 examples/comparison/fib/fib.py
javac examples/comparison/fib/Fib.java && java -cp examples/comparison/fib Fib
```
