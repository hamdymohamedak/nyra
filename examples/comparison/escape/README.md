# Escape analysis micro-benchmark

Nyra-only suites that show **compile-time escape analysis** effects: **LocalChannel** vs runtime channels, **SROA** for local structs, and **NoEscape** string literals vs returning heap strings.

Pair each `*_small.ny` for smoke tests; full `.ny` files for timing.

## Files

| File | Escape path | N | Expected output |
|------|-------------|---|-----------------|
| `local_channel.ny` | LocalChannel (stack ring buffer) | 500 000 send/recv pairs | `999749132` |
| `spawn_channel.ny` | Runtime channel (`spawn` + mutex) | 500 000 | `999749132` |
| `local_channel_small.ny` | LocalChannel | 1 000 | `499500` |
| `spawn_channel_small.ny` | Runtime channel | 1 000 | `499500` |
| `point_sroa.ny` | `Point` NoEscape → SROA | 50 M field adds | `180000000` |
| `point_return.ny` | `Point` returned each iteration | 50 M | `180000000` |
| `string_local.ny` | struct + string literal NoEscape | 50 M | `80000000` |
| `string_return.ny` | `User` returned each iteration | 100 k | `100000` |

Checksum for channels: `(0 + 1 + … + (N−1)) mod 1 000 000 007`.

## Quick smoke test

```bash
cargo run --bin nyra -- run examples/comparison/escape/local_channel_small.ny
cargo run --bin nyra -- run examples/comparison/escape/spawn_channel_small.ny
```

## Full benchmark (release + timing)

```bash
chmod +x examples/comparison/escape/run.sh
./examples/comparison/escape/run.sh
```

Builds release binaries under `target/release/` next to the sources, prints escape reports with `--verbose`, then times each pair.

**Note:** `point_return.ny` and `string_return.ny` are intended for **`nyra build --release`** — debug runs may fail or be very slow on large N.

## See the optimizer

```bash
# Escape plan
cargo run --bin nyra -- build --verbose examples/comparison/escape/local_channel.ny

# LLVM IR (after release build — see target/release/*.ll)
cargo run --bin nyra -- build --release examples/comparison/escape/local_channel.ny -o local_channel_bench
# → examples/comparison/escape/target/release/local_channel_bench.ll
```

| IR signal | Local / optimized | Escaping |
|-----------|-------------------|----------|
| Channel | `alloca %NyraLocalChannel_i32`, no `@channel_send` | `call @channel_new`, mutex runtime |
| Point struct | no `alloca %Point` in `@main` | extra allocas / calls in hot path |
| String struct | no `@str_clone` in `@main` | `@str_clone` on return path |

## What to expect

- **local_channel** vs **spawn_channel** — same checksum; local is usually **much faster** (no mutex, no `rt_channel.c`).
- **point_sroa** vs **point_return** — same checksum; SROA keeps the struct in registers/stack slots.
- **string_local** vs **string_return** — local avoids per-iteration heap clones; return path stresses the allocator.

See also: [`Escape_Analysis.md`](../../../Escape_Analysis.md), [`webDocs/escape-analysis.html`](../../../webDocs/escape-analysis.html).
