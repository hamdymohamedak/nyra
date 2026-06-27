import "stdlib/builtins_json.ny"

fn main() -> void {
    let raw: string = JSON_stringify("name", "hamdy")
    print(raw)
    print(JSON_parse(raw, "name"))
}
