# ny-sqlite (example NyraPkg)

Example package showing how to ship a **database driver outside core stdlib** with semver, C shims, and native linking.

## Layout

```
ny-sqlite/
  nyra.mod         # version, link sqlite3, link-source rt/sqlite.c
  sqlite.ny        # extern fn declarations
  rt/sqlite.c      # C shim (auto-linked on nyra build)
  main.ny          # smoke entry (stub)
```

## Install

```bash
nyra pkg init
nyra pkg install ny-sqlite@^0.1.0
```

This copies the package into `.nyra/cache/ny-sqlite/`, merges `link sqlite3` into your `nyra.mod`, and pins `0.1.0` in `nyra.lock`.

## Use

```ny
import "pkg/ny-sqlite/sqlite.ny"

fn main() {
    let db = sqlite_open("test.db")
    sqlite_exec(db, "CREATE TABLE t(id INTEGER)")
    sqlite_close(db)
}
```

`nyra build` compiles `rt/sqlite.c` automatically — no manual `clang` step.

## FFI surface

| Nyra | C shim | SQLite |
|------|--------|--------|
| `sqlite_open(path)` | `sqlite_open` | `sqlite3_open` |
| `sqlite_exec(db, sql)` | `sqlite_exec` | `sqlite3_exec` |
| `sqlite_close(db)` | `sqlite_close` | `sqlite3_close` |

## Publish (optional)

```bash
cargo run -p pkg-registry &
nyra pkg login --token nyra-dev-token
nyra pkg publish ny-sqlite 0.1.0 https://github.com/you/ny-sqlite
```

See [`docs/nyrapkg-v1.md`](../../../docs/nyrapkg-v1.md) and [`docs/bindings.md`](../../../docs/bindings.md).
