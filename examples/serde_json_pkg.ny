// JSON via rust::serde_json — same API surface as NyraPkg ny-serde.
// For packaged use: nyra pkg install ny-serde@^0.1.0
// Project demo: examples/serde_json_pkg/main.ny
import "rust/serde_json"

fn main() {
    let raw = stringify("{\"name\":\"nyra\",\"n\":1}")
    print(raw)
}
