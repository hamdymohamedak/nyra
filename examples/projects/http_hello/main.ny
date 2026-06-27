import "../../../stdlib/http.ny"

fn main() {
    let body = fetch("http://example.com/")
    if body != "" {
        print(1)
    } else {
        print(0)
    }
}
