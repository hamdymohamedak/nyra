fn main() -> i32 {
    let n = StrVec_from_argv(1).len()
    print(strcat("argc tail = ", i32_to_string(n)))
    return 0
}
