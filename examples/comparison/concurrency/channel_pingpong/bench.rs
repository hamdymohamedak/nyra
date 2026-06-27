fn main() {
    use std::sync::mpsc;
    const N: i64 = 500000;
    const MOD: i64 = 1000000007;
    let (tx, rx) = mpsc::channel();
    std::thread::spawn(move || {
        for j in 0..N { let _ = tx.send(j); }
    });
    let mut acc: i64 = 0;
    for _ in 0..N {
        acc = (acc + rx.recv().unwrap()).rem_euclid(MOD);
    }
    println!("{}", acc);
}
