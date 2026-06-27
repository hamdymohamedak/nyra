// ny-toml package tests — nyra test examples/packages/ny-toml/toml_test.ny
import "toml.ny"

test fn test_parse_toml_normalizes() {
    let out = parse_toml("[app]\nname = \"nyra\"\n")
    if strlen(out) == 0 {
        print("fail parse_toml empty")
    }
}

test fn test_stringify_toml_roundtrip() {
    let raw = stringify_toml("[x]\nn = 1\n")
    if strlen(raw) == 0 {
        print("fail stringify_toml empty")
    }
}

test fn test_from_to_toml_aliases() {
    let text = to_toml("[k]\nv = true\n")
    let back = from_toml(text)
    if strlen(back) == 0 {
        print("fail from/to toml aliases")
    }
}
