// ny-serde package tests — nyra test examples/packages/ny-serde/serde_test.ny
import "serde.ny"

test fn test_parse_json_normalizes() {
    let out = parse_json("{\"a\":1,\"b\":2}")
    if strlen(out) == 0 {
        print("fail parse_json empty")
    }
}

test fn test_stringify_json_roundtrip() {
    let raw = stringify_json("{\"x\":true,\"y\":null}")
    if strlen(raw) == 0 {
        print("fail stringify_json empty")
    }
}

test fn test_from_to_json_aliases() {
    let text = to_json("{\"k\":\"v\"}")
    let back = from_json(text)
    if strlen(back) == 0 {
        print("fail from/to json aliases")
    }
}
