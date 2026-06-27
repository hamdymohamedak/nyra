fn main() {
    let mut sb = StringBuilder_new()
    sb = StringBuilder_push(sb, "Nyra ")
    sb = StringBuilder_push_char(sb, 71)
    sb = StringBuilder_push(sb, "UI")
    print(StringBuilder_build(sb))
    let entries = list_dir_entries(".")
    print(entries.len())
    print(char_from_code(33))
}
