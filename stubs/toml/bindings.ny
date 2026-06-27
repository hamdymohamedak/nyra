// Compile-only stub for `import "rust/toml"` (CI / check without `nyra bind`).
extern fn toml_parse(input: string) -> string
extern fn toml_stringify(input: string) -> string

fn parse(input: string) -> string {
    return toml_parse(input)
}

fn stringify(input: string) -> string {
    return toml_stringify(input)
}
