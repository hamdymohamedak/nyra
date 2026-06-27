
fn Tree_print_entries(dir, prefix, depth, max_depth) {
    if max_depth >= 0 && depth > max_depth {
        return
    }
    let entries = StrVec_from_lines(list_dir(dir))
    let n = entries.len()
    let mut i = 0
    while i < n {
        let name = entries.get(i)
        let full = strcat(strcat(dir, "/"), name)
        let last = if i + 1 == n { 1 } else { 0 }
        let branch = if last == 1 { "└── " } else { "├── " }
        let label = if is_dir(full) == 1 { strcat(name, "/") } else { name }
        print(strcat(strcat(prefix, branch), label))
        if is_dir(full) == 1 {
            let child_prefix = if last == 1 {
                strcat(prefix, "    ")
            } else {
                strcat(prefix, "│   ")
            }
            Tree_print_entries(full, child_prefix, depth + 1, max_depth)
        }
        i = i + 1
    }
}

fn Tree_run(args) {
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    let root = if n == 0 { "." } else { paths.get(0) }
    if exists(root) == 0 {
        print(strcat(strcat("tree: ", root), ": No such directory"))
        return 1
    }
    let label = if is_dir(root) == 1 { strcat(root, "/") } else { root }
    print(label)
    if is_dir(root) == 1 {
        Tree_print_entries(root, "", 1, -1)
    }
    return 0
}
