import "stdlib/db/redis_server.ny"

fn RedisClone_run() {
    print("Redis RESP wire demo")
    let mut db = RedisDb_new()
    print(Redis_wire(db, Resp_decode_array("*1\r\n$4\r\nPING\r\n", 0)))
    db = Redis_apply(db, Resp_decode_array("*3\r\n$3\r\nSET\r\n$8\r\ngreeting\r\n$5\r\nhello\r\n", 0))
    print(Redis_wire(db, Resp_decode_array("*2\r\n$3\r\nGET\r\n$8\r\ngreeting\r\n", 0)))
    print("redis TCP ready — call RedisServer_serve(host, port, db, max) to accept connections")
    db = RedisServer_serve("127.0.0.1", 16379, db, 0)
    print(`final GET greeting = ${RedisDb_get(db, "greeting")}`)
}
