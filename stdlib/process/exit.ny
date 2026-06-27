extern fn process_exit(code: i32) -> void

fn exit(code: i32) -> void {
    process_exit(code)
}
