fn main() {
    let line = "  hello,nyra,world  "
    print(line.trim())
    print(line.contains("nyra"))
    print(line.starts_with("  hello"))
    print(line.ends_with("world  "))

    let parts = line.trim().split(",")
    for part in parts {
        print(part)
    }

    print("foo-bar".replace("bar", "baz"))
    print("Nyra".to_upper())
    print("Nyra".to_lower())
}
