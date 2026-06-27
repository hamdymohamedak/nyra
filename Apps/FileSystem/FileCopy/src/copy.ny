fn FileCopy_run() {
    let src = input("Source file: ")
    if exists(src) == 0 {
        print("source not found")
        return
    }
    let dst = input("Destination file: ")
    let size = file_size(src)
    print(strcat(strcat("source size: ", i32_to_string(size as i32)), " bytes"))
    let copied = copy_file(src, dst)
    if copied < 0 {
        print("copy failed")
        return
    }
    print(strcat(strcat(strcat("copied ", i32_to_string(copied as i32)), " bytes -> "), dst))
    let dst_size = file_size(dst)
    if dst_size == size {
        print("verify OK — sizes match")
    } else {
        print("verify WARN — size mismatch")
    }
}
