extern fn hw_disk_total_bytes(path: string) -> i64
extern fn hw_disk_free_bytes(path: string) -> i64
extern fn hw_disk_fs_type(path: string) -> string

fn disk_total_bytes(path: string) -> i64 {
    return hw_disk_total_bytes(path)
}

fn disk_free_bytes(path: string) -> i64 {
    return hw_disk_free_bytes(path)
}

fn disk_fs_type(path: string) -> string {
    return hw_disk_fs_type(path)
}
