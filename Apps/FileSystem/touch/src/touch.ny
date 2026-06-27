
fn Touch_run(args) {
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if n == 0 {
        Cli_usage("touch", " file [file...]")
        return 1
    }
    let mut i = 0
    while i < n {
        let path = paths.get(i)
        if exists(path) == 0 {
            if write_file(path, "") != 0 {
                print(strcat(strcat("touch: cannot create '", path), "'"))
                return 1
            }
        } else {
            if is_dir(path) == 1 {
                print(strcat(strcat("touch: ", path), ": is a directory"))
                return 1
            }
            let data = read_file(path)
            if write_file(path, data) != 0 {
                print(strcat(strcat("touch: cannot update '", path), "'"))
                return 1
            }
        }
        i = i + 1
    }
    return 0
}
