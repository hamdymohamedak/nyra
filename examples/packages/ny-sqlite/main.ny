import "sqlite.ny"

fn main() {
    let _handle = sqlite_open("demo.db")
    // Demonstrates package layout — implement nyra_sqlite_* in rt/sqlite.c
    // and link with: nyra build . --link-arg -lsqlite3
    print(0)
}
