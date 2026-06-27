// Memory utilities — MVP scalars; full size_of/align_of for structs post-1.0.

fn size_of_i32() -> i32 {
    return 4
}

fn size_of_bool() -> i32 {
    return 4
}

fn size_of_ptr() -> i32 {
    return 8
}

fn align_of_i32() -> i32 {
    return 4
}

fn align_of_ptr() -> i32 {
    return 8
}

fn swap_i32(a: i32, _b: i32) -> i32 {
    return a
}

fn copy_i32(x: i32) -> i32 {
    return x
}
