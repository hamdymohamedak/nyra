extern fn substring(s: string, start: i32, len: i32) -> string
extern fn strlen(s: string) -> i32

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let base = "benchmark-substring-padding-value"
    let mut i = 0
    while i < 100000 {
        let part = substring(base, i % 10, 8)
        acc = (acc + strlen(part)) % 1000000007
        i = i + 1
    }

    print(blackbox_i32(acc))
}
