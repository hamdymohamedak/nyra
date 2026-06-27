import "stdlib/builtins_json.ny"

fn main() {
    let raw = JSON_stringify("name", "hamdy")
    print(JSON_parse(raw, "name"))
}
