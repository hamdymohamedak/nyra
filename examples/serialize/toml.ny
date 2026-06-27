import "stdlib/serialize/mod.ny"
import "stdlib/vec_str.ny"

fn main() -> i32 {
    let keys = Vec_str_new()
    let values = Vec_str_new()
    Vec_str_push(keys, "app")
    Vec_str_push(values, "nyra")
    Vec_str_push(keys, "version")
    Vec_str_push(values, "1.0")
    let toml = serialize(SerializeFormat.Toml, keys, values)
    print(toml)
    print(deserialize(SerializeFormat.Toml, toml, "app"))
    Vec_str_free(keys)
    Vec_str_free(values)
    return 0
}
