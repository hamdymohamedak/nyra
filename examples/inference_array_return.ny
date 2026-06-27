// Inferred return type for fixed-size arrays (no `-> [i32; 4]` needed).
fn copy4(src: [i32; 4], len) {
    let mut out = [0; 4]
    let mut i = 0
    while i < len {
        out[i] = src[i]
        i = i + 1
    }
    return out
}

fn main() {
    let a = [10, 20, 30, 40]
    let b = copy4(a, 4)
    print(b[0])
    print(b[3])
}
