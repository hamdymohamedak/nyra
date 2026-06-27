// ny-serde demo — full project: examples/serde_json_pkg/
// nyra bind rust serde_json --template --project examples/serde_json_pkg
// nyra run examples/serde_json_pkg/main.ny
import "../packages/ny-serde/serde.ny"

fn main() {
    let parsed = parse_json("{\"lang\":\"nyra\",\"version\":1}")
    let out = stringify_json(parsed)
    print(out)
}
