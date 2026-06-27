const DB_PATH = ":memory:"

fn SQLiteClone_demo() {
    let db = Sqlite_open(DB_PATH)
    let mut rc = db.exec("CREATE TABLE users (id INTEGER, name TEXT);")
    if rc != 0 {
        print("CREATE failed")
        db.close()
        return
    }
    rc = db.exec("INSERT INTO users VALUES (1, 'alice');")
    rc = db.exec("INSERT INTO users VALUES (2, 'bob');")
    if rc != 0 {
        print("INSERT failed")
        db.close()
        return
    }
    let rs = db.query_rows("SELECT id, name FROM users ORDER BY id;")
    let rows = rs.rows()
    let cols = rs.cols()
    print(`query_rows: ${rows} rows x ${cols} cols`)
    let mut i = 0
    while i < rows {
        print(`  row ${i}: id=${rs.at(i, 0)} name=${rs.at(i, 1)}`)
        i = i + 1
    }
    let first = db.query("SELECT name FROM users WHERE id = 1;")
    print(`query() first cell: ${first}`)
    rs.free()
    db.close()
}
