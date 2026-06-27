import "../../../stdlib/uuid/mod.ny"
import "../../../stdlib/env/mod.ny"
import "../../../stdlib/strings/regex.ny"
import "../../../stdlib/url/mod.ny"
import "../../../stdlib/crypto/mod.ny"
import "../../../stdlib/iter/mod.ny"
import "../../../stdlib/terminal/console.ny"
import "../../../stdlib/vec.ny"

fn main() {
    print(UUID_v4())

    let port = env_get("PORT")
    print(port)

    let re = Regex_new(".+@.+")
    if regex_matches(re, "user@example.com") != 0 {
        console_green("email ok")
    }

    let u = Url_parse("http://localhost:8080/api")
    print(u.host)
    print(url_path("http://localhost:8080/api"))

    let mut nums = Vec_i32_new()
    nums = vec_push(nums, 1)
    nums = vec_push(nums, 5)
    nums = vec_push(nums, 3)
    let big = vec_filter_gt(nums, 2)
    print(vec_reduce_sum(big))

    print(random_bytes(8))
}
