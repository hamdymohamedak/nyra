
fn Mv_move_one(src, dst) {
    if exists(src) == 0 {
        print(strcat(strcat("mv: ", src), ": No such file"))
        return 1
    }
    let copied = copy_file(src, dst)
    if copied < 0 {
        print(strcat(strcat("mv: cannot move '", src), "'"))
        return 1
    }
    if is_dir(src) == 1 {
        if remove_dir(src) != 0 {
            print(strcat(strcat("mv: cannot remove source dir '", src), "'"))
            return 1
        }
    } else {
        if remove_file(src) != 0 {
            print(strcat(strcat("mv: cannot remove source '", src), "'"))
            return 1
        }
    }
    return 0
}

fn Mv_run(args) {
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if n < 2 {
        Cli_usage("mv", " source dest")
        return 1
    }
    let dst = paths.get(n - 1)
    if n == 2 {
        return Mv_move_one(paths.get(0), dst)
    }
    if is_dir(dst) == 0 {
        print("mv: destination is not a directory")
        return 1
    }
    let mut i = 0
    while i < n - 1 {
        let src = paths.get(i)
        let target = strcat(strcat(dst, "/"), basename_str(src))
        let code = Mv_move_one(src, target)
        if code != 0 {
            return code
        }
        i = i + 1
    }
    return 0
}
