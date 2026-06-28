// Typed variant of comptime_tables.ny — same compile-time evaluation.

comptime

fn hash_step(n: i32) -> i32 {
    return (n * 2654435761) % 2147483647
}

fn sum_to(n: i32) -> i32 {
    let mut acc: i32 = 0
    for i in 0..n {
        acc = acc + hash_step(i)
    }
    return acc
}

pub const SEED: i32 = hash_step(42)
pub const SUM_FIVE: i32 = sum_to(5)
