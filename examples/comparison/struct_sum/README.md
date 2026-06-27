# Struct field sum (Copy semantics)

Create a small `Point` struct in a hot loop (N = 500_000) and accumulate `x + y` (always 3 per iteration).

| Language | File |
|----------|------|
| Nyra | `struct_sum.ny` |
| Go | `struct_sum.go` |
| Rust | `struct_sum.rs` |
| Node | `struct_sum.js` |
| Python | `struct_sum.py` |
| Java | `StructSum.java` |

**Expected stdout:** `1500000`

Targets Nyra **struct literals**, **field access**, and **Copy** struct semantics in the latest ownership model.

```bash
cargo run --bin nyra -- run examples/comparison/struct_sum/struct_sum.ny
go run examples/comparison/struct_sum/struct_sum.go
rustc -O examples/comparison/struct_sum/struct_sum.rs -o /tmp/struct_rs && /tmp/struct_rs
node examples/comparison/struct_sum/struct_sum.js
python3 examples/comparison/struct_sum/struct_sum.py
javac examples/comparison/struct_sum/StructSum.java && java -cp examples/comparison/struct_sum StructSum
```
