import "comptime_tables.ny" as tables

fn main() {
    let seed = tables::SEED
    let sum5 = tables::SUM_FIVE
    if seed <= 0 || sum5 <= 0 {
        print("unexpected comptime values")
    }
}
