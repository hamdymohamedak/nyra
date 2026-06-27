# Rust bridge: uuid

Bind the [uuid](https://crates.io/crates/uuid) crate and generate a v4 UUID from Nyra.

## Setup

From the Nyra repo root (or any project with `nyra.mod`):

```bash
nyra add rust::uuid@^1.0.0
# or manually:
nyra bind rust uuid
# then add to nyra.mod:
#   require rust::uuid ^1.0
#   link-crate uuid
```

## Run

```bash
nyra run examples/rust-bridge/uuid/main.ny
```

Expected: a UUID string like `550e8400-e29b-41d4-a716-446655440000`.

## How it works

1. `nyra bind rust uuid` fetches the crate version from crates.io.
2. A static Rust wrapper exports `uuid_new_v4` / `uuid_parse` as C symbols.
3. `nyra build` compiles the wrapper with Cargo and links the `.a` into your binary.
4. `import "rust/uuid"` loads `.nyra/cache/rust/uuid/bindings.ny`.

See [`docs/rfcs/0011-rust-crate-bridge.md`](../../../docs/rfcs/0011-rust-crate-bridge.md).
