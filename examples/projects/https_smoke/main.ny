import "stdlib/http/mod.ny"
import "stdlib/tls.ny"

fn main() {
    if tls_available() == 0 {
        print("skip: no TLS")
        return
    }
    let body = get("https://example.com")
    if strlen(body) > 0 {
        print(1)
    } else {
        print(0)
    }
}
