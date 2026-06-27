// Zero-types CLI pattern (no type annotations). See Apps/FileSystem/cat/.
import "stdlib/vec_str.ny"

fn strip_flags(args) {
    let n = args.len()
    let mut v = StrVec_new()
    let mut i = 0
    while i < n {
        let a = args.get(i)
        if strlen(a) == 0 {
            v = v.push(a)
        }
        i = i + 1
    }
    return v
}

fn run(args) {
    let files = strip_flags(args)
    return files.len()
}

fn main() {
    return run(StrVec_from_argv(1))
}
