// FFI surface for SQLite — link `-lsqlite3` or ship amalgamation in your package.
// This example documents the NyraPkg pattern; symbols are not in core stdlib.
extern fn sqlite_open(path: string) -> i32
extern fn sqlite_exec(db: i32, sql: string) -> i32
extern fn sqlite_close(db: i32) -> void
