import "stdlib/builtins_string.ny"
import "stdlib/vec_str.ny"

fn main() {
    let parts = String_split("a,b", ",")
    print(Vec_str_len(parts))
}
