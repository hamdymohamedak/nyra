import "stdlib/db/resp.ny"

fn main() {
    let wire = "*2\r\n$3\r\nGET\r\n$3\r\nkey\r\n"
    let args = Resp_decode_array(wire, 0)
    print(Resp_cmd_name(args))
    print(args.get(1))
    print(Resp_encode_bulk("value"))
}
