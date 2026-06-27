
fn Diff_compare_files(left, right) {
    if exists(left) == 0 {
        print(strcat(strcat("diff: ", left), ": No such file"))
        return 2
    }
    if exists(right) == 0 {
        print(strcat(strcat("diff: ", right), ": No such file"))
        return 2
    }
    let a = read_file(left)
    let b = read_file(right)
    let lines_a = StrVec_from_lines(a)
    let lines_b = StrVec_from_lines(b)
    let na = lines_a.len()
    let nb = lines_b.len()
    let max = if na > nb { na } else { nb }
    let mut diffs = 0
    let mut i = 0
    while i < max {
        let la = if i < na { lines_a.get(i) } else { "" }
        let lb = if i < nb { lines_b.get(i) } else { "" }
        if strcmp(la, lb) != 0 {
            diffs = diffs + 1
            let num = i32_to_string(i + 1)
            print(strcat(strcat(strcat(strcat("< ", left), " "), num), strcat(": ", la)))
            print(strcat(strcat(strcat(strcat("> ", right), " "), num), strcat(": ", lb)))
        }
        i = i + 1
    }
    if diffs == 0 {
        return 0
    }
    return 1
}

fn Diff_run(args) {
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if n < 2 {
        Cli_usage("diff", " file1 file2")
        return 2
    }
    return Diff_compare_files(paths.get(0), paths.get(1))
}
