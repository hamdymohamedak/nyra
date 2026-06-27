// Compile-only stub for `import "rust/serde_json"` (CI / check without `nyra bind`).
extern fn serde_json_parse(input: string) -> string
extern fn serde_json_stringify(input: string) -> string

fn parse(input: string) -> string {
    return serde_json_parse(input)
}

fn stringify(input: string) -> string {
    return serde_json_stringify(input)
}
