
fn DevCli_has_flag(args, flag) {
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

struct DevPathList {
    paths: StrVec
}

fn DevCli_paths(args) {
    let n = args.len()
    let mut pos = StrVec_new()
    let mut i = 0
    while i < n {
        let a = args.get(i)
        if strlen(a) == 0 || char_at(a, 0) != 45 {
            pos = pos.push(a)
        }
        i = i + 1
    }
    return DevPathList { paths: pos }
}

fn DevPathList_len(list) {
    return list.paths.len()
}

fn DevPathList_at(list, index) {
    return list.paths.get(index)
}

fn DevCli_usage(tool, text) {
    print(strcat(strcat("usage: ", tool), text))
}
