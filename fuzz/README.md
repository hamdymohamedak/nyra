# Nyra Fuzz Testing (libFuzzer)

Random and grammar-aware inputs to catch compiler panics — the same approach used by Rust (`rustc`, `cargo-fuzz`), Clang, and Go.

**Rule:** invalid input must produce diagnostics or a clean error — never a crash.

## Targets

| Target | What it exercises |
|--------|-------------------|
| `fuzz_lexer` | Lossy UTF-8 bytes → lexer |
| `fuzz_parser` | Lex → parse |
| `fuzz_compile` | `fuzz-gen` output → borrowck |
| `fuzz_gen` | Structured garbage → borrowck |
| `fuzz_codegen` | Structured garbage → **LLVM codegen** |

`fuzz_gen` generates programs like:

```ny
fn main() { if (((({
let let let let
import "stdlib/testing.ny"
fn main() { let s = "\n\x1b" }
```

## Quick start

```bash
# Install once
cargo install cargo-fuzz

# Refresh seed corpus from examples + regression tests
bash scripts/sync-fuzz-corpus.sh

# Stable toolchain (no ASAN)
cd fuzz && cargo fuzz run fuzz_codegen --sanitizer none -- \
  -dict=dictionaries/nyra.dict -max_total_time=60 -max_len=16384

# Nightly + AddressSanitizer (recommended for deep fuzzing)
rustup install nightly
cd fuzz && cargo +nightly fuzz run fuzz_gen -- \
  -dict=dictionaries/nyra.dict -max_total_time=300

# Full smoke (in test-all.sh)
./scripts/test-all.sh
```

## CI stress (no libFuzzer)

Every `cargo test` run includes:

| Test | Default iters | Stage |
|------|---------------|-------|
| `fuzz_stress_no_panics` | 2000 | borrowck |
| `fuzz_stress_codegen_no_panics` | 500 | codegen |

```bash
cargo test -p compiler fuzz_stress
NYRA_FUZZ_ITERS=50000 NYRA_FUZZ_CODEGEN_ITERS=2000 cargo test -p compiler fuzz_stress
```

## Dictionary & corpus

- `fuzz/dictionaries/nyra.dict` — keywords/tokens passed to `-dict=…`
- `fuzz/corpus/<target>/` — seed inputs; refresh with `scripts/sync-fuzz-corpus.sh`

## When libFuzzer finds a crash

1. Minimize: `cargo fuzz tmin fuzz_gen --sanitizer none artifacts/fuzz_gen/crash-…`
2. Add a regression under `tests/suite/fail/regression/fuzz/`
3. Re-run: `cargo test -p compiler suite_fail_fuzz_regression`

Weekly CI (`scripts/fuzz-nightly.sh`) runs 5 minutes per target (codegen gets 8GB RSS cap).

## Generator crate

`compiler/fuzz-gen/` — deterministic program generator (imports, string escapes, valid skeletons + chaos).
