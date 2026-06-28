// Comptime lookup table — evaluated at compile time, zero runtime cost for SEED.
// Check module: nyra check examples/toolchain/comptime_tables.ny
// Use from runtime: import this file and read `tables.SEED`.

comptime

fn hash_step(n) {
    return (n * 2654435761) % 2147483647
}

fn sum_to(n) {
    let mut acc = 0
    for i in 0..n {
        acc = acc + hash_step(i)
    }
    return acc
}

pub const SEED = hash_step(42)
pub const SUM_FIVE = sum_to(5)
