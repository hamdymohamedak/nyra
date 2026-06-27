fn Cli_has_flag(args, flag) {
    let n = args.len()
    let mut i = 0
    while i < n {
        if strcmp(args.get(i), flag) == 0 {
            return 1
        }
        i = i + 1
    }
    return 0
}

fn Cli_strip_flags(args) {
    let n = args.len()
    let mut v = StrVec_new()
    let mut i = 0
    while i < n {
        let a = args.get(i)
        if strlen(a) == 0 || char_at(a, 0) != 45 {
            v = v.push(a)
        }
        i = i + 1
    }
    return v
}

fn Cli_usage(tool, text) {
    print(strcat(strcat("usage: ", tool), text))
}
