# Nested loop (2D accumulate)

Double loop: sum `i * j` for `i, j` in `0 .. 199` (N = 200).

| Language | File |
|----------|------|
| Nyra | `nested.ny` |
| Go | `nested.go` |
| Rust | `nested.rs` |
| Node | `nested.js` |
| Python | `nested.py` |
| Java | `Nested.java` |

**Expected stdout:** `396010000`

Stress-tests nested `for` / `while` and multiply-add in the inner hot loop (different shape than `loop/`).

```bash
cargo run --bin nyra -- run examples/comparison/nested/nested.ny
go run examples/comparison/nested/nested.go
rustc -O examples/comparison/nested/nested.rs -o /tmp/nested_rs && /tmp/nested_rs
node examples/comparison/nested/nested.js
python3 examples/comparison/nested/nested.py
javac examples/comparison/nested/Nested.java && java -cp examples/comparison/nested Nested
```
