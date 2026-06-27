extern fn regex_compile(pattern: string) -> ptr
extern fn regex_is_match(handle: ptr, text: string) -> i32
extern fn regex_free(handle: ptr) -> void

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let re = regex_compile("bench_[0-9]+")
    let text = "prefix bench_12345 suffix"
    let mut i = 0
    while i < 100000 {
        acc = (acc + regex_is_match(re, text)) % 1000000007
        i = i + 1
    }
    regex_free(re)

    print(blackbox_i32(acc))
}
