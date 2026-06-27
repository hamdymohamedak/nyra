#!/usr/bin/env bash
# Seed libFuzzer corpora from real Nyra sources (run before long fuzz sessions).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CORPUS_GEN="$ROOT/fuzz/corpus/fuzz_gen"
CORPUS_COMPILE="$ROOT/fuzz/corpus/fuzz_compile"
CORPUS_CODEGEN="$ROOT/fuzz/corpus/fuzz_codegen"

mkdir -p "$CORPUS_GEN" "$CORPUS_COMPILE" "$CORPUS_CODEGEN"

copy_seed() {
  local src="$1"
  local dest_dir="$2"
  local name="$3"
  if [[ -f "$src" ]]; then
    cp "$src" "$dest_dir/$name"
  fi
}

# Examples
copy_seed "$ROOT/examples/syntax/hello.ny" "$CORPUS_GEN" "hello.ny"
copy_seed "$ROOT/examples/syntax/for_in.ny" "$CORPUS_GEN" "for_in.ny"
copy_seed "$ROOT/examples/syntax/math.ny" "$CORPUS_GEN" "math.ny"
copy_seed "$ROOT/examples/syntax/hello.ny" "$CORPUS_CODEGEN" "hello.ny"
copy_seed "$ROOT/examples/syntax/math.ny" "$CORPUS_CODEGEN" "math.ny"

# Fuzz regression guards (known crash shapes)
for f in "$ROOT/tests/suite/fail/regression/fuzz"/fuzz_{unbalanced_if,repeated_let,keyword_soup,int_overflow,bad_char}.ny; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f")"
  copy_seed "$f" "$CORPUS_GEN" "$base"
  copy_seed "$f" "$CORPUS_COMPILE" "$base"
done

# Raw compile seeds (minimal valid + broken)
cat > "$CORPUS_COMPILE/valid_main.ny" <<'NY'
fn main() {
    let x = 1
    print(x)
}
NY

cat > "$CORPUS_COMPILE/broken_main.ny" <<'NY'
fn main() { if (((({
NY

echo "sync-fuzz-corpus: ok ($(find "$ROOT/fuzz/corpus" -type f | wc -l | tr -d ' ') seeds)"
