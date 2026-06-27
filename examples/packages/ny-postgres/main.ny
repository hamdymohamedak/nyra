import "postgres.ny"

extern fn os_getenv(name: string) -> string
extern fn strlen(s: string) -> i32
extern fn strcat(a: string, b: string) -> string
extern fn ptr_is_null(p: ptr) -> i32

fn main() {
    let spec = os_getenv("DATABASE_URL")
    if strlen(spec) == 0 {
        print("SKIP: DATABASE_URL not set")
        return
    }
    let conn = Postgres_connect(spec)
    if ptr_is_null(conn) == 1 {
        print("SKIP: postgres not available")
        return
    }
    let version = Postgres_query_scalar(conn, "SELECT version()")
    if strlen(version) == 0 {
        print("FAIL: postgres query")
        Postgres_close(conn)
        return
    }
    Postgres_free_string(version)
    Postgres_close(conn)
    print("PASS: ny-postgres smoke")
}
