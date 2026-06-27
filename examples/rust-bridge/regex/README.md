# Rust bridge: regex (bindgen)

Uses **syn bindgen** — no hand-written template.

## Setup

```bash
nyra bind rust regex --export Regex::new --export Regex::is_match
# or:
nyra add rust::regex@^1.0.0
```

## Run

```bash
nyra run examples/rust-bridge/regex
```

Expected output: `1` (pattern `^[a-z]+$` matches `hello`).

See [`docs/rfcs/0011-rust-crate-bridge.md`](../../../docs/rfcs/0011-rust-crate-bridge.md).
