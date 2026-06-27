import "toml.ny"

fn main() {
    let raw = stringify_toml("[app]\nname = \"nyra\"\n")
    print(raw)
}
