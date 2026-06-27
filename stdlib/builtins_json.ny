import "json/mod.ny"

// MVP JSON helpers: single-field encode/decode.
fn JSON_stringify(key: string, value: string) -> string {
    return encode_field(key, value)
}

fn JSON_parse(json: string, key: string) -> string {
    return decode_string(json, key)
}
