extern fn blackbox_i32(x: i32) -> i32

fn run(name: string) {
    blackbox_i32(name.length())
}

test fn test_progress_for_array() {
    let tests = ["a", "b", "c", "d", "e"]
    progress(label = "parser tests") for item in tests {
        run(item)
    }
}

test fn test_progress_for_range() {
    progress for i in 0..5 {
        blackbox_i32(i)
    }
}
