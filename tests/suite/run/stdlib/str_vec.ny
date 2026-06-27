import "stdlib/vec_str.ny"

// run-stdout: 3

fn main() {
    let mut v = StrVec_from_lines("a\nb\nc")
    print(v.len())
}
