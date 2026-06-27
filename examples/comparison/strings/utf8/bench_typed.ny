extern fn char_at(s: string, i: i32) -> i32
extern fn strlen(s: string) -> i32

extern fn blackbox_i32(x: i32) -> i32

fn main() -> void {
    let mut acc: i32 = 0
    let s: string = "Nyra_utf8_bench_mix"
    let mut i: i32 = 0
    while i < 100000 {
        let n = strlen(s)
        let mut j: i32 = 0
        while j < n {
            acc = (acc + char_at(s, j)) % 1000000007
            j = j + 1
        }
        i = i + 1
    }

    print(blackbox_i32(acc))
}
