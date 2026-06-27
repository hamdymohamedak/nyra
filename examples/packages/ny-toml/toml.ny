// NyraPkg ny-toml — clean TOML API over rust::toml.
import "rust/toml"

fn parse_toml(input: string) -> string {
    return parse(input)
}

fn stringify_toml(value: string) -> string {
    return stringify(value)
}

fn from_toml(input: string) -> string {
    return parse_toml(input)
}

fn to_toml(value: string) -> string {
    return stringify_toml(value)
}
