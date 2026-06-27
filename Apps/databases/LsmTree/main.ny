import "src/lsm.ny"

fn main() {
    print("=== LsmTree — memtable + append-only WAL ===", color: bold)
    LsmTree_run()
}
