import "stdlib/builtins_string.ny"

fn main() {
    let s = "  Nyra Lang  "
    print(String_toUpperCase(clone s))
    print(String_toLowerCase(clone s))
    print(String_includes(clone s, "Lang"))
    let parts = "a,b,c".split(",")
    print(parts.length())
    print(String_replace("hello world", "world", "nyra"))
    print(trim(clone s))
}
