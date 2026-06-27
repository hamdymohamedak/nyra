
fn Rm_remove_tree(path) {
    if exists(path) == 0 {
        print(strcat(strcat("rm: ", path), ": No such file"))
        return 1
    }
    if is_dir(path) == 1 {
        let entries = StrVec_from_lines(list_dir(path))
        let n = entries.len()
        let mut i = 0
        while i < n {
            let child = strcat(strcat(path, "/"), entries.get(i))
            let code = Rm_remove_tree(child)
            if code != 0 {
                return code
            }
            i = i + 1
        }
        if remove_dir(path) != 0 {
            print(strcat(strcat("rm: cannot remove '", path), "'"))
            return 1
        }
        return 0
    }
    if remove_file(path) != 0 {
        print(strcat(strcat("rm: cannot remove '", path), "'"))
        return 1
    }
    return 0
}

fn Rm_run(args) {
    let recursive = Cli_has_flag(args, "-r")
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if n == 0 {
        Cli_usage("rm", " [-r] file [file...]")
        return 1
    }
    let mut i = 0
    while i < n {
        let path = paths.get(i)
        let mut code = 0
        if recursive == 1 {
            code = Rm_remove_tree(path)
        } else {
            if is_dir(path) == 1 {
                print(strcat(strcat("rm: ", path), ": is a directory"))
                return 1
            }
            if remove_file(path) != 0 {
                print(strcat(strcat("rm: cannot remove '", path), "'"))
                return 1
            }
        }
        if code != 0 {
            return code
        }
        i = i + 1
    }
    return 0
}
