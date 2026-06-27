extern fn mysql_connect(spec: string) -> ptr
extern fn mysql_exec(conn: ptr, sql: string) -> i32
extern fn mysql_query_scalar(conn: ptr, sql: string) -> string
extern fn mysql_close(conn: ptr) -> void
extern fn mysql_free_string(value: string) -> void

fn Mysql_connect(spec: string) -> ptr {
    return mysql_connect(spec)
}

fn Mysql_exec(conn: ptr, sql: string) -> i32 {
    return mysql_exec(conn, sql)
}

fn Mysql_query_scalar(conn: ptr, sql: string) -> string {
    return mysql_query_scalar(conn, sql)
}

fn Mysql_close(conn: ptr) -> void {
    mysql_close(conn)
}

fn Mysql_free_string(value: string) -> void {
    mysql_free_string(value)
}
