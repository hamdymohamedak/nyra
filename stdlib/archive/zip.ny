extern fn zip_create_file(archive: string, source: string, entry_name: string) -> i32
extern fn zip_extract_file(archive: string, dest: string) -> i32

fn zip_create(archive_path: string, source_path: string) -> i32 {
    let name = source_path
    return zip_create_file(archive_path, source_path, name)
}

fn zip_extract(archive_path: string, dest_path: string) -> i32 {
    return zip_extract_file(archive_path, dest_path)
}

fn zip_pack(archive_path: string, source_path: string, entry_name: string) -> i32 {
    return zip_create_file(archive_path, source_path, entry_name)
}

fn zip_unpack(archive_path: string, dest_path: string) -> i32 {
    return zip_extract_file(archive_path, dest_path)
}
