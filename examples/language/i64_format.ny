extern fn instant_now() -> i64

fn main() {
    let ts = instant_now()
    print(strcat("timestamp=", i64_to_string(ts)))
}
