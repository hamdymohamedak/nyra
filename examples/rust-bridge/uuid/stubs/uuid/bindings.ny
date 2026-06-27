// Compile-only stub for `import "rust/uuid"` (CI / check without `nyra bind`).
// Matches template from `nyra bind rust uuid` — do not edit by hand.
extern fn uuid_new_v4() -> string
extern fn uuid_parse(input: string) -> string

fn new_v4() -> string {
    return uuid_new_v4()
}

fn parse(input: string) -> string {
    return uuid_parse(input)
}
