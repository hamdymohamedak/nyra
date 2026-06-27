extern fn char_at(s: string, i: i32) -> i32
extern fn strlen(s: string) -> i32

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let s = "Nyra_utf8_bench_mix"
    let mut i = 0
    while i < 100000 {
        let n = strlen(s)
        let mut j = 0
        while j < n {
            acc = (acc + char_at(s, j)) % 1000000007
            j = j + 1
        }
        i = i + 1
    }

    print(blackbox_i32(acc))
}
