extern fn strcat(a: string, b: string) -> string

fn main() {
    let prefix = "hello"
    let greet = (name: string) => strcat(prefix, name)
    print(greet(" world"))
}
