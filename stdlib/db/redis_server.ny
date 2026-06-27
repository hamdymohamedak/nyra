// Redis TCP server — blocking RESP2 loop over stdlib/net/tcp.ny.
import "resp.ny"
import "../net/tcp.ny"

struct RedisDb {
    strings: HashMap_str_str
}

fn RedisDb_new() {
    return RedisDb { strings: HashMap_str_str_new() }
}

fn RedisDb_set(db, key: string, value: string) {
    return RedisDb { strings: db.strings.insert(key, value) }
}

fn RedisDb_get(db, key: string) {
    if db.strings.contains(key) == 0 {
        return "(nil)"
    }
    return db.strings.get(key)
}

struct RedisReply {
    db: RedisDb
    wire: string
}

fn Redis_dispatch(db, args) {
    let cmd = Resp_cmd_name(args)
    if cmd == "PING" {
        return RedisReply { db: db, wire: Resp_encode_pong() }
    }
    if cmd == "SET" {
        if args.len() < 3 {
            return RedisReply { db: db, wire: Resp_encode_error("ERR wrong number of arguments for 'set'") }
        }
        let key = args.get(1)
        let val = args.get(2)
        let next = RedisDb_set(db, key, val)
        return RedisReply { db: next, wire: Resp_encode_simple("OK") }
    }
    if cmd == "GET" {
        if args.len() < 2 {
            return RedisReply { db: db, wire: Resp_encode_error("ERR wrong number of arguments for 'get'") }
        }
        let key = args.get(1)
        if db.strings.contains(key) == 0 {
            return RedisReply { db: db, wire: Resp_encode_nil() }
        }
        return RedisReply { db: db, wire: Resp_encode_bulk(db.strings.get(key)) }
    }
    return RedisReply { db: db, wire: Resp_encode_error("ERR unknown command") }
}

fn Redis_apply(db, args) {
    let cmd = Resp_cmd_name(args)
    if cmd == "SET" {
        if args.len() < 3 {
            return db
        }
        return RedisDb_set(db, args.get(1), args.get(2))
    }
    return db
}

fn Redis_wire(db, args) {
    let cmd = Resp_cmd_name(args)
    if cmd == "PING" {
        return Resp_encode_pong()
    }
    if cmd == "SET" {
        if args.len() < 3 {
            return Resp_encode_error("ERR wrong number of arguments for 'set'")
        }
        return Resp_encode_simple("OK")
    }
    if cmd == "GET" {
        if args.len() < 2 {
            return Resp_encode_error("ERR wrong number of arguments for 'get'")
        }
        let key = args.get(1)
        if db.strings.contains(key) == 0 {
            return Resp_encode_nil()
        }
        return Resp_encode_bulk(db.strings.get(key))
    }
    return Resp_encode_error("ERR unknown command")
}

fn RedisServer_handle_stream(db, stream) {
    let raw = tcp_read(stream, 65536)
    if strlen(raw) == 0 {
        return db
    }
    let args = Resp_decode_array(raw, 0)
    let wire = Redis_wire(db, args)
    let next = Redis_apply(db, args)
    if strlen(wire) > 0 {
        tcp_write(stream, wire)
    }
    return next
}

fn RedisServer_serve(host, port, db, max_requests) {
    let listener = tcp_listen(host, port)
    if listener.fd < 0 {
        print("redis: failed to bind")
        return db
    }
    print(strcat(strcat("redis listening on ", host), strcat(":", i32_to_string(port))))
    let mut state = db
    let mut count = 0
    while count < max_requests {
        let stream = tcp_accept_wait(listener, 120000)
        if stream.fd < 0 {
            break
        }
        state = RedisServer_handle_stream(state, stream)
        tcp_close_stream(stream)
        count = count + 1
    }
    tcp_close_listener(listener)
    return state
}

fn RedisServer_serve_forever(host, port, db) {
    return RedisServer_serve(host, port, db, 1000000)
}
