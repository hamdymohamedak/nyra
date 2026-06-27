import "rust/regex"

fn main() {
    let re = Regex_new("^[a-z]+$")
    let ok = Regex_is_match(re, "hello")
    print(ok)
    Regex_free(re)
}
