// Call libc `strlen` through FFI (libSystem / libc linked by default).
extern fn strlen(s: string) -> i32

fn main() {
    let msg = "hello"
    let n = strlen(msg)
    print(n)
}
