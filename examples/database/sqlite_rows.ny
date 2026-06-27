// SQLite streaming cursor + materialized rowset.

fn main() {
    let db = Sqlite_open(":memory:")
    db.exec("CREATE TABLE kv (k TEXT, v TEXT);")
    db.exec("INSERT INTO kv VALUES ('a', '1');")
    db.exec("INSERT INTO kv VALUES ('b', '2');")

    let rs = db.query_rows("SELECT k, v FROM kv ORDER BY k;")
    print(rs.rows())
    print(rs.at(0, 0))
    print(rs.at(1, 1))
    rs.free()

    let stmt = db.prepare("SELECT v FROM kv WHERE k = 'b'")
    let mut count = 0
    while stmt.step() == 1 {
        print(stmt.col(0))
        count = count + 1
    }
    print(count)
    stmt.finalize()
    db.close()
}
