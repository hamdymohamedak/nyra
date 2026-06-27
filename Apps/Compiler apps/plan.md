# Compiler apps — Nyra language smoke tests

Parser, lexer, regex, and AST tooling that expose gaps in **string parsing**, **collections**, **recursion depth**, **error reporting**, and **stdlib serialization** before building a full Nyra compiler frontend.

Each directory is an independent **`nyra pkg init` project** (own `nyra.mod`, `main.ny`, `src/`). Apps use the **auto-prelude** stdlib and only import project-local files.

## Projects

| App | What it does | Run | Focus |
|-----|--------------|-----|-------|
| `JSONParser/` | Recursive-descent JSON value probe | `./target/debug/main sample.json` | strings, numbers, objects/arrays |
| `TOMLParser/` | Line-based TOML tables + key=value | `./target/debug/main sample.toml` | sections, quoted strings |
| `XMLParser/` | Tag + attribute scanner | `./target/debug/main sample.xml` | `<tag attr="val">` |
| `YAMLParser/` | Indent + list + `key: value` | `./target/debug/main sample.yaml` | nesting, list items |
| `RegexEngine/` | Pure-Nyra `.` `*` subset matcher | `nyra run .` or `./target/debug/main 'ab*c' abc` | backtracking |
| `MarkdownParser/` | Block + inline AST labels | `./target/debug/main sample.md` | headings, lists, inline |
| `Lexer/` | Generic tokenizer (ident, number, string, ops) | `nyra run .` or `./target/debug/main sample.ny` | `char` literals, `continue` |
| `Parser/` | Expression scan demo | `nyra run .` | recursive descent |
| `ASTVisualizer/` | ASCII tree from `>` depth paths | `nyra run .` or `./target/debug/main sample.ast` | tree layout |

Build all:

```bash
BASE="Apps/Compiler apps"
for d in JSONParser TOMLParser XMLParser YAMLParser RegexEngine MarkdownParser Lexer Parser ASTVisualizer; do
  (cd "$BASE/$d" && nyra build .) || exit 1
done
```

## Stdlib for parser authors (v1.17.0+)

| API | Module | Notes |
|-----|--------|-------|
| `SourceLoc`, `SourceLoc_format` | `stdlib/parser/sourceloc.ny` | file:line:col for diagnostics |
| `Comb_or_literal`, `Comb_or_take`, `Comb_many` | `stdlib/parser/combinator.ny` | cursor + `take_while` / `literal` / `or` / `many` |
| `Comb_or` | `stdlib/parser/combinator.ny` | alias for `Comb_or_literal` (v1.18.0) |
| `AstRow_*` | `stdlib/parser/ast_row.ny` | parallel kind/text rows for AST nodes |
| `utf8_codepoint_at`, `utf8_next_index`, `utf8_codepoint_count` | `stdlib/unicode/iter.ny` | UTF-8 codepoint iteration |
| `String_split_safe`, `String_split_quoted` | `stdlib/strings/split.ny` | index split; quote-aware split |
| `KvVec`, `KvVec_push` | `stdlib/collections/kv_vec.ny` | parallel key/value vectors (JSON object rows) |
| `Vec<T>` POD | `stdlib/collections/vec_pod.ny` | `Vec_Point_new/push/get/len` for Copy structs |
| `HashMap<K,V>` | `stdlib/map.ny` | generic syntax aliases to `HashMap_str_*` |
| `Option<T>`, `Result<T,E>`, `?` | `stdlib/option.ny` | error propagation |
| `substring` auto-clone | compiler expand | reuse source string after `substring()` |

## Gaps addressed (v1.17.0)

| Former gap | Resolution |
|------------|------------|
| No `Vec<T>` of structs | `Vec<T>` + `vec_bytes_*` runtime; synthesized `Vec_{Struct}_*` for Copy POD structs |
| No generic `HashMap<K,V>` | `HashMap<string,i32>` → `HashMap_str_i32` monomorph alias |
| `continue` + multiple `mut` loop vars | `sync_loop_latch_regs` + latch regs on `while` loops |
| Struct return across fn boundaries | Copy struct → `ptr` coercion for extern/POD vec; struct helpers return fields intact |
| JSON/TOML/YAML/XML probes only | JSON object + **array** summaries; combinator `or`/`many`; `AstRow` |
| No parser-combinator `or`/`many` | `Comb_or_literal`, `Comb_or_take`, `Comb_many` in `combinator.ny` |

## Remaining gaps

| Gap | Notes |
|-----|-------|
| Move-struct `Vec<T>` | **Fixed** v1.27 — `Vec_LabelRow_*` / `Vec_NestedRow_*` via parallel columns (`vec_reloc` expand) |
| `Vec<Vec<i32>>` | **Fixed** v1.25 — `stdlib/collections/nested_vec.ny` + synthesized `Vec_Vec_i32_*` |
| Deep JSON/TOML/YAML/XML | Pass `.clone()` to string helpers when walking one buffer in a loop |
| Generic `HashMap` beyond str keys | Add `map_str_i32`-style monomorphs as needed |

## Related

- `tests/nyra/parser_gaps_test.ny`, `tests/nyra/parser_gaps.typed.ny` — regression suite (zero-types + typed)
- `examples/parser/combinators.ny` — combinator + quoted split demo
