# Database apps — Nyra language smoke tests

Small database/storage programs that expose gaps in **stdlib/db**, **collections**, **file I/O**, **string parsing**, and **memory ownership** before building real engines.

Each directory is an independent **`nyra pkg init` project** (own `nyra.mod`, `main.ny`, `src/`). Apps use the **auto-prelude** stdlib and only import project-local files.

## Projects

| App | What it does | Run | Stdlib used |
|-----|--------------|-----|-------------|
| `SQLiteClone/` | In-memory SQLite CREATE/INSERT/SELECT rows | `cd SQLiteClone && nyra run .` | `Sqlite_open`, `query_rows`, `link sqlite3` |
| `KeyValueDatabase/` | HashMap + line-delimited file persistence | `cd KeyValueDatabase && nyra run .` | `HashMap_str_str`, `read_file`, `write_file` |
| `RedisClone/` | RESP + TCP `RedisServer_serve` | `cd RedisClone && nyra run .` | `stdlib/db/redis_server.ny` |
| `LsmTree/` | Memtable + WAL + leveled SST compaction | `cd LsmTree && nyra run .` | `stdlib/db/lsm.ny` |
| `BTreeDatabase/` | Sorted key index via `BTreeMap_str_str` | `cd BTreeDatabase && nyra run .` | `stdlib/collections/btree_map.ny` |
| `QueryParser/` | `SELECT` / `INSERT` SQL subset parser | `cd QueryParser && nyra run .` | `stdlib/db/sql_parse.ny` |
| `CacheSystem/` | Fixed-capacity LRU-ish cache | `cd CacheSystem && nyra run .` | `HashMap_str_str`, `StrVec` |

Build all:

```bash
BASE="Apps/databases"
for d in SQLiteClone KeyValueDatabase RedisClone LsmTree BTreeDatabase QueryParser CacheSystem; do
  (cd "$BASE/$d" && nyra build .) || exit 1
done
```

## Resolved in v1.24.0

| Gap | Resolution |
|-----|------------|
| SQL UPDATE/DELETE | `SqlParse_parse` — `UPDATE … SET … WHERE` and `DELETE FROM … WHERE` |
| B-tree range scan | `BTreePaged_range`, `BTreePaged_keys` in `btree_pages.ny` |
| DB test script | `scripts/database-smoke.sh` wired into `test-all.sh` |

## Resolved in v1.21.0

| Gap | Resolution |
|-----|------------|
| Full LSM compaction | `stdlib/db/lsm.ny` — L0 flush, leveled merge, tombstones, WAL truncate |
| B-tree internal traversal | `btree_pages.ny` — internal descent + internal splits |
| Sparse SQL parser | `stdlib/db/sql_parse.ny` — INSERT, WHERE expressions |
| SQLite row cursor gaps | Streaming `SqliteStmt.step` + `SqlDb.query_rows` + smoke tests |

## Resolved in v1.19.0

| Gap | Resolution |
|-----|------------|
| Redis TCP listener | `stdlib/db/redis_server.ny` — `RedisServer_serve` / `serve_forever` |
| Real B-tree splits | `stdlib/collections/btree_pages.ny` — `BTreePaged_str_str` + leaf split |

## Resolved in v1.18.0

| Gap | Resolution |
|-----|------------|
| No `sqlite_step` / row cursor | `SqliteDb.query_rows()` + `SqliteRowset` (`rt_sqlite.c`) |
| `BTreeMap_str_i32` HashMap-backed | Sorted `BTreeMap_str_str` in `btree_map.ny` |
| No SSTable / fsync | `stdlib/db/sstable.ny` + `fsync_file()` |
| No RESP parser | `stdlib/db/resp.ny` RESP2 subset |
| `HashMap.remove` / `.keys()` | Already in `stdlib/map.ny` (v1.14+) |

## Remaining language gaps (not DB-specific)

| Gap | Notes |
|-----|-------|
| No `match` on strings | **Fixed** v1.17.0 — string literal arms in `match` |
