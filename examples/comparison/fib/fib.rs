fn main() {
    let steps: i64 = 375_000_000;
    let m: i64 = 1_000_000_007;
    let mut a: i64 = 0;
    let mut b: i64 = 1;
    let mut i: i64 = 0;
    while i < steps {
        let t = (a + b).rem_euclid(m);
        a = b;
        b = t;
        i += 1;
    }
    println!("{}", b);
}
