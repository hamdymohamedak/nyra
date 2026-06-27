
fn DevWalk_ends_with(name, suffix) {
    let name_len = strlen(name)
    let suf_len = strlen(suffix)
    if suf_len > name_len {
        return 0
    }
    let start = name_len - suf_len
    let tail = substring(name, start, suf_len)
    if strcmp(tail, suffix) == 0 {
        return 1
    }
    return 0
}

struct DevFileList {
    files: StrVec
}

fn DevWalk_collect_ny(dir, out) {
    let mut files = out.files
    if exists(dir) == 0 || is_dir(dir) == 0 {
        return DevFileList { files: files }
    }
    let entries = StrVec_from_lines(list_dir(dir))
    let n = entries.len()
    let mut i = 0
    while i < n {
        let name = entries.get(i)
        if strcmp(name, ".") != 0 && strcmp(name, "..") != 0 {
            let full = strcat(strcat(dir, "/"), name)
            if is_dir(full) == 1 {
                let nested = DevWalk_collect_ny(full, DevFileList { files: files })
                files = nested.files
            } else {
                if DevWalk_ends_with(name, ".ny") == 1 {
                    files = files.push(full)
                }
            }
        }
        i = i + 1
    }
    return DevFileList { files: files }
}

fn DevFileList_len(list) {
    return list.files.len()
}

fn DevFileList_at(list, index) {
    return list.files.get(index)
}
