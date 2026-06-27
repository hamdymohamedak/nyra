extern fn str_replace(s: string, from: string, to: string) -> string
extern fn strlen(s: string) -> i32

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let mut s = "foo-bar-baz-"
    let mut i = 0
    while i < 100000 {
        s = str_replace(s, "bar", "qux")
        acc = (acc + strlen(s)) % 1000000007
        i = i + 1
    }

    print(blackbox_i32(acc))
}
