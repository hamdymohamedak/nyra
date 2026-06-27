// Single-file micro-benchmark: skip auto-merged stdlib prelude for smaller/faster builds.
// Build: nyra build examples/toolchain/no_prelude.ny --release --no-prelude -o hello_slim
// Run:   ./target/release/hello_slim   (or path printed by `nyra build`)

fn main() {
    print("Hello from no-prelude build")
}
