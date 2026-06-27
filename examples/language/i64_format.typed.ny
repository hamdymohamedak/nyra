extern fn instant_now() -> i64

fn main() -> void {
    let ts: i64 = instant_now()
    print(strcat("timestamp=", i64_to_string(ts)))
}
