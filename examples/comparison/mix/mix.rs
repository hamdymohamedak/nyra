fn main() {
    let n: i64 = 270_000_000;
    let m: i64 = 1_000_000_007;
    let mut acc: i64 = 0;
    let mut i: i64 = 0;
    while i < n {
        let t = (i % 997) * 31;
        acc = (acc + t + (acc % 4099)).rem_euclid(m);
        i += 1;
    }
    println!("{}", acc);
}
