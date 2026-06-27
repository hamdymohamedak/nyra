extern fn strstr_pos(hay: string, needle: string) -> i32
extern fn substring(s: string, start: i32, len: i32) -> string
extern fn strlen(s: string) -> i32

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let hay = "alpha,beta,gamma,delta,epsilon"
    let mut i = 0
    while i < 100000 {
        let pos = strstr_pos(hay, ",")
        let part = substring(hay, 0, pos)
        acc = (acc + strlen(part) + pos) % 1000000007
        i = i + 1
    }

    print(blackbox_i32(acc))
}
