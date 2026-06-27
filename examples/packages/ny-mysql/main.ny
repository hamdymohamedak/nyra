import "mysql.ny"

extern fn os_getenv(name: string) -> string
extern fn strlen(s: string) -> i32
extern fn ptr_is_null(p: ptr) -> i32

fn main() {
    let spec = os_getenv("MYSQL_SPEC")
    if strlen(spec) == 0 {
        print("SKIP: MYSQL_SPEC not set (host;port;dbname;user;pass)")
        return
    }
    let conn = Mysql_connect(spec)
    if ptr_is_null(conn) == 1 {
        print("SKIP: mysql not available")
        return
    }
    let version = Mysql_query_scalar(conn, "SELECT VERSION()")
    if strlen(version) == 0 {
        print("FAIL: mysql query")
        Mysql_close(conn)
        return
    }
    Mysql_free_string(version)
    Mysql_close(conn)
    print("PASS: ny-mysql smoke")
}
