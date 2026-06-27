fn main() -> i32 {
    let db = Sqlite_open(":memory:")
    let rc = db.exec("CREATE TABLE t (id INTEGER, name TEXT);")
    assert_eq(rc, 0)
    db.exec("INSERT INTO t VALUES (1, 'nyra');")
    db.exec("INSERT INTO t VALUES (2, 'sqlite');")

    let rs = db.query_rows("SELECT id, name FROM t ORDER BY id;")
    assert_eq(rs.rows(), 2)
    assert_eq(rs.cols(), 2)
    assert_eq(strcmp(rs.at(0, 1), "nyra"), 0)
    assert_eq(strcmp(rs.at(1, 0), "2"), 0)
    rs.free()

    let stmt = db.prepare("SELECT name FROM t WHERE id = ?")
    stmt.finalize()

    db.close()
    return 0
}
