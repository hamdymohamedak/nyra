import "../../../stdlib/strings.ny"

export fn greet(name: string) -> string {
    return strcat("Hello, ", name)
}

export fn add(a: i32, b: i32) -> i32 {
    return a + b
}
