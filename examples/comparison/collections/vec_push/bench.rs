fn main() {
    const MOD: i64 = 1000000007;
    let mut v: Vec<i32> = Vec::with_capacity(500000);
    let mut acc: i64 = 0;
    for i in 0..500000 {
        v.push((i % 997) as i32);
        acc = (acc + v.len() as i64).rem_euclid(MOD);
    }
    println!("{}", acc);
}
