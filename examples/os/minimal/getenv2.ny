extern fn os_getenv(name: string) -> string

fn main() {
    print(os_getenv("HOME"))
}
