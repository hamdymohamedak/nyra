// Generic fn monomorphization — two specialized LLVM functions, no dynamic dispatch.
// Inspect IR: nyra build examples/toolchain/monomorph_static_dispatch.ny --release -o /tmp/mono
// Expect calls to id__i32 and id__string (or similar mangling), not a shared generic stub.

fn id<T>(x: T) -> T {
    return x
}

fn main() {
    let a = id(42)
    let b = id("nyra")
    if a == 42 {
        print(b)
    }
}
