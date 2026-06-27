extern fn pq_connect(spec: string) -> ptr
extern fn pq_exec(conn: ptr, sql: string) -> i32
extern fn pq_query_scalar(conn: ptr, sql: string) -> string
extern fn pq_close(conn: ptr) -> void
extern fn pq_free_string(value: string) -> void

fn Postgres_connect(spec: string) -> ptr {
    return pq_connect(spec)
}

fn Postgres_exec(conn: ptr, sql: string) -> i32 {
    return pq_exec(conn, sql)
}

fn Postgres_query_scalar(conn: ptr, sql: string) -> string {
    return pq_query_scalar(conn, sql)
}

fn Postgres_close(conn: ptr) -> void {
    pq_close(conn)
}

fn Postgres_free_string(value: string) -> void {
    pq_free_string(value)
}
