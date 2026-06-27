
fn Cp_copy_one(src, dst) {
    if exists(src) == 0 {
        print(strcat(strcat("cp: ", src), ": No such file"))
        return 1
    }
    let data = bytes_read_file(src)
    let ok = bytes_write_file(dst, data)
    bytes_free(data)
    if ok != 0 {
        print(strcat(strcat("cp: cannot copy '", src), "'"))
        return 1
    }
    return 0
}

fn Cp_run(args) {
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if n < 2 {
        Cli_usage("cp", " source dest")
        return 1
    }
    let dst = paths.get(n - 1)
    if n == 2 {
        return Cp_copy_one(paths.get(0), dst)
    }
    if is_dir(dst) == 0 {
        print("cp: destination is not a directory")
        return 1
    }
    let mut i = 0
    while i < n - 1 {
        let src = paths.get(i)
        let target = strcat(strcat(dst, "/"), basename_str(src))
        let code = Cp_copy_one(src, target)
        if code != 0 {
            return code
        }
        i = i + 1
    }
    return 0
}
