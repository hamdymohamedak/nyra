struct Editor {
    path: string
    lines: StrVec
    dirty: i32
}

fn Editor_load(path){
    let text = read_file(path)
    let lines = StrVec_from_lines(text)
    return Editor { path: path, lines: lines, dirty: 0 }
}

fn Editor_new(path){
    let mut lines = StrVec_new()
    lines = lines.push("")
    return Editor { path: path, lines: lines, dirty: 0 }
}

fn Editor_show(ed){
    let n = ed.lines.len()
    print(`--- ${ed.path} (${n} lines) ---`)
    let mut i = 0
    while i < n {
        let num = i32_to_string(i + 1)
        let pad = if i + 1 < 10 { strcat("  ", num) } else { strcat(" ", num) }
        print(strcat(strcat(pad, " | "), ed.lines.get(i)))
        i = i + 1
    }
}

fn Editor_save(ed){
    let body = StrVec_join_lines(ed.lines)
    let ok = write_file(ed.path, body)
    if ok == 0 {
        print("saved.")
        return Editor { path: ed.path, lines: ed.lines, dirty: 0 }
    }
    print("save failed.")
    return ed
}

fn Editor_set_line(ed, index, text){
    let n = ed.lines.len()
    if index < 1 || index > n {
        print("line out of range")
        return ed
    }
    let mut v = StrVec_new()
    let mut i = 0
    while i < n {
        if i + 1 == index {
            v = v.push(text)
        } else {
            v = v.push(ed.lines.get(i))
        }
        i = i + 1
    }
    return Editor { path: ed.path, lines: v, dirty: 1 }
}

fn Editor_append_line(ed, text){
    return Editor {
        path: ed.path,
        lines: ed.lines.push(text),
        dirty: 1,
    }
}

fn Editor_delete_line(ed, index){
    let n = ed.lines.len()
    if index < 1 || index > n {
        print("line out of range")
        return ed
    }
    if n == 1 {
        print("cannot delete last line")
        return ed
    }
    let mut v = StrVec_new()
    let mut i = 0
    while i < n {
        if i + 1 != index {
            v = v.push(ed.lines.get(i))
        }
        i = i + 1
    }
    return Editor { path: ed.path, lines: v, dirty: 1 }
}

fn Editor_help(){
    print("Commands: :list  :save  :quit  :append <text>  :edit <n> <text>  :del <n>  :help")
}

fn Editor_parse_index(cmd, prefix){
    let rest = substring(cmd, strlen(prefix), strlen(cmd) - strlen(prefix))
    let sp = strstr_pos(rest, " ")
    if sp < 0 {
        return -1
    }
    let num = substring(rest, 0, sp)
    let mut n = 0
    let len = strlen(num)
    let mut i = 0
    while i < len {
        let c = char_at(num, i)
        if c >= 48 && c <= 57 {
            n = n * 10 + (c - 48)
        }
        i = i + 1
    }
    if n <= 0 {
        return -1
    }
    return n
}

fn Editor_run(){
    let path = input("File path (new or existing): ")
    let mut ed = if exists(path) == 1 { Editor_load(path) } else { Editor_new(path) }
    Editor_help()
    let mut running = 1
    while running == 1 {
        let cmd = input("edit> ")
        if strcmp(cmd, ":quit") == 0 || strcmp(cmd, ":q") == 0 {
            let mut abort_quit = 0
            if ed.dirty == 1 {
                let ans = input("Unsaved changes — quit anyway? (y/N): ")
                if strcmp(ans, "y") != 0 && strcmp(ans, "Y") != 0 {
                    abort_quit = 1
                }
            }
            if abort_quit == 0 {
                running = 0
            }
        } else {
            if strcmp(cmd, ":list") == 0 || strcmp(cmd, ":l") == 0 {
                Editor_show(ed)
            } else {
                if strcmp(cmd, ":save") == 0 || strcmp(cmd, ":w") == 0 {
                    ed = Editor_save(ed)
                } else {
                    if strcmp(cmd, ":help") == 0 || strcmp(cmd, ":h") == 0 {
                        Editor_help()
                    } else {
                        if strstr_pos(cmd, ":append ") == 0 {
                            let text = substring(cmd, 8, strlen(cmd) - 8)
                            ed = Editor_append_line(ed, text)
                        } else {
                            if strstr_pos(cmd, ":edit ") == 0 {
                                let idx = Editor_parse_index(cmd, ":edit ")
                                let sp = strstr_pos(cmd, " ")
                                let sp2 = strstr_pos(substring(cmd, sp + 1, strlen(cmd) - sp - 1), " ")
                                if idx > 0 && sp2 >= 0 {
                                    let text = substring(cmd, sp + sp2 + 2, strlen(cmd) - sp - sp2 - 2)
                                    ed = Editor_set_line(ed, idx, text)
                                } else {
                                    print("usage: :edit <line> <text>")
                                }
                            } else {
                                if strstr_pos(cmd, ":del ") == 0 {
                                    let idx = Editor_parse_index(cmd, ":del ")
                                    if idx > 0 {
                                        ed = Editor_delete_line(ed, idx)
                                    } else {
                                        print("usage: :del <line>")
                                    }
                                } else {
                                    print("unknown command — :help")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
