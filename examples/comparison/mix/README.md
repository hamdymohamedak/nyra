# Mix benchmark

Chained modular mixing: 180M iterations of `(acc + (i%997)*31 + (acc%4099)) % 1_000_000_007`.

Expected output: `473067162`

```bash
cargo run -- run examples/comparison/mix/mix.ny
node mix.js
python3 mix.py
```
