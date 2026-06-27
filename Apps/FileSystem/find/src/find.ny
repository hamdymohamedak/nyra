
fn Find_name_matches(name, pattern) {
    if strstr_pos(name, pattern) >= 0 {
        return 1
    }
    return 0
}

fn Find_walk(dir, pattern) {
    if exists(dir) == 0 {
        return
    }
    let entries = StrVec_from_lines(list_dir(dir))
    let n = entries.len()
    let mut i = 0
    while i < n {
        let name = entries.get(i)
        let full = strcat(strcat(dir, "/"), name)
        if Find_name_matches(name, pattern) == 1 {
            print(full)
        }
        if is_dir(full) == 1 {
            Find_walk(full, pattern)
        }
        i = i + 1
    }
}

fn Find_run(args) {
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if n < 2 {
        Cli_usage("find", " directory pattern")
        return 1
    }
    let root = paths.get(0)
    let pattern = paths.get(1)
    if exists(root) == 0 {
        print(strcat(strcat("find: ", root), ": No such directory"))
        return 1
    }
    if is_dir(root) == 0 {
        print(strcat(strcat("find: ", root), ": not a directory"))
        return 1
    }
    Find_walk(root, pattern)
    return 0
}
