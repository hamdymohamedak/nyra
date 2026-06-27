// NyraPkg ny-serde — clean JSON API over rust::serde_json.
import "rust/serde_json"

fn parse_json(input: string) -> string {
    return parse(input)
}

fn stringify_json(value: string) -> string {
    return stringify(value)
}

fn from_json(input: string) -> string {
    return parse_json(input)
}

fn to_json(value: string) -> string {
    return stringify_json(value)
}
