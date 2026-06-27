extern fn tar_create(archive: string, paths: ptr) -> i32
extern fn tar_extract(archive: string, out_dir: string) -> i32

fn tar_pack(archive: string, paths: StrVec) -> i32 {
    return tar_create(archive, StrVec_raw(paths))
}

fn tar_unpack(archive: string, out_dir: string) -> i32 {
    return tar_extract(archive, out_dir)
}
