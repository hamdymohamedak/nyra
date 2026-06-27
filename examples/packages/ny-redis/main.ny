import "redis.ny"

extern fn os_getenv(name: string) -> string
extern fn strlen(s: string) -> i32
extern fn ptr_is_null(p: ptr) -> i32

fn main() {
    let mut host = os_getenv("REDIS_HOST")
    if strlen(host) == 0 {
        host = "127.0.0.1"
    }
    let conn = Redis_connect(host, 6379)
    if ptr_is_null(conn) == 1 {
        print("SKIP: redis not available")
        return
    }
    if Redis_ping(conn) != 0 {
        print("FAIL: redis ping")
        Redis_close(conn)
        return
    }
    if Redis_set(conn, "ny-redis:smoke", "ok", 60) != 0 {
        print("FAIL: redis set")
        Redis_close(conn)
        return
    }
    let value = Redis_get(conn, "ny-redis:smoke")
    if strlen(value) == 0 {
        print("FAIL: redis get empty")
        Redis_close(conn)
        return
    }
    Redis_del(conn, "ny-redis:smoke")
    Redis_close(conn)
    print("PASS: ny-redis smoke")
}
