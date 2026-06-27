// continue — skip to the next loop iteration (while / for).
// nyra run examples/control_continue.ny

fn sum_odd(n: i32) -> i32 {
    let mut i = 0
    let mut acc = 0
    while i < n {
        i = i + 1
        if i % 2 == 0 {
            continue
        }
        acc = acc + i
    }
    return acc
}

fn main() {
    print(sum_odd(10))
}
