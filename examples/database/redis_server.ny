fn main() {
    let mut db = RedisDb_new()
    db = Redis_dispatch(db, Resp_decode_array("*3\r\n$3\r\nSET\r\n$3\r\nkey\r\n$3\r\nval\r\n", 0)).db
    print(Redis_dispatch(db, Resp_decode_array("*2\r\n$3\r\nGET\r\n$3\r\nkey\r\n", 0)).wire)
}
