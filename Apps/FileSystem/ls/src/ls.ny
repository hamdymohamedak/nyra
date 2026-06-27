
fn Ls_format_name(name, dir_path) {
    let full = strcat(strcat(dir_path, "/"), name)
    if is_dir(full) == 1 {
        return strcat(name, "/")
    }
    return name
}

fn Ls_print_dir(path, long_fmt) {
    if exists(path) == 0 {
        print(strcat(strcat("ls: ", path), ": No such file or directory"))
        return
    }
    if is_dir(path) == 0 {
        print(path)
        return
    }
    let entries = StrVec_from_lines(list_dir(path))
    let n = entries.len()
    let mut i = 0
    while i < n {
        let name = entries.get(i)
        if long_fmt == 1 {
            let full = strcat(strcat(path, "/"), name)
            let sz = file_size(full)
            print(strcat(strcat(strcat(i32_to_string(sz as i32), "  "), path), strcat("/", name)))
        } else {
            print(Ls_format_name(name, path))
        }
        i = i + 1
    }
}

fn Ls_run(args) {
    let long_fmt = Cli_has_flag(args, "-l")
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if n == 0 {
        Ls_print_dir(".", long_fmt)
        return 0
    }
    let mut i = 0
    while i < n {
        Ls_print_dir(paths.get(i), long_fmt)
        i = i + 1
    }
    return 0
}
