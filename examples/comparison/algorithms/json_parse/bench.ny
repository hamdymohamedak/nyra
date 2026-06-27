extern fn json_get_i32(json: string, key: string) -> i32

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let doc = "{\"id\": 42, \"value\": 997, \"nested\": {\"x\": 7}}"
    let mut i = 0
    while i < 100000 {
        acc = (acc + json_get_i32(doc, "value")) % 1000000007
        acc = (acc + json_get_i32(doc, "id")) % 1000000007
        i = i + 1
    }

    print(blackbox_i32(acc))
}
