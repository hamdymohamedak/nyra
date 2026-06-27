import "stdlib/text/template/mod.ny"
import "stdlib/html/template/mod.ny"
import "stdlib/slog/mod.ny"
import "stdlib/encoding/xml.ny"
import "stdlib/compress/flate.ny"
import "stdlib/unicode/utf8.ny"
import "stdlib/net/rpc.ny"
import "stdlib/testing/quick.ny"

fn main() {
    print(template_execute("Hello {{name}}", "name", "Nyra"))
    print(html_template_execute("<p>{{x}}</p>", "x", "a<b>"))
    print(xml_element("title", "test"))
    print(utf8_valid("hello"))
    slog_info_kv("started", "app", "smoke")

    let req = RpcRequest_new("ping", "[]", "1")
    print(rpc_encode(req))

    let packed = flate_compress("abc")
    print(flate_decompress(packed))

    quick_check_eq_i32(2 + 2, 4)
}
