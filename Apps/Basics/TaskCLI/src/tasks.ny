const TASK_FILE = "tasks.nyra.txt"

struct TaskStore {
    lines: StrVec
    next_id: i32
}

fn TaskStore_split(text){
    let mut v = StrVec_new()
    let n = strlen(text)
    if n == 0 {
        return v
    }
    let mut start = 0
    while start < n {
        let rest = substring(text, start, n - start)
        let nl = strstr_pos(rest, "\n")
        if nl < 0 {
            if strlen(rest) > 0 {
                v = v.push(rest)
            }
            break
        }
        let line = substring(rest, 0, nl)
        if strlen(line) > 0 {
            v = v.push(line)
        }
        start = start + nl + 1
    }
    return v
}

fn TaskStore_max_id(lines){
    let n = lines.len()
    let mut max = 0
    let mut i = 0
    while i < n {
        let line = lines.get(i)
        let sep = strstr_pos(line, "|")
        if sep > 0 {
            let id_str = substring(line, 0, sep)
            let mut id = 0
            let mut j = 0
            while j < strlen(id_str) {
                let c = char_at(id_str, j)
                if c >= 48 && c <= 57 {
                    id = id * 10 + (c - 48)
                }
                j = j + 1
            }
            if id > max {
                max = id
            }
        }
        i = i + 1
    }
    return max
}

fn TaskStore_load(){
    if exists(TASK_FILE) == 0 {
        return TaskStore { lines: StrVec_new(), next_id: 1 }
    }
    let text = read_file(TASK_FILE)
    let lines = TaskStore_split(text)
    let max = TaskStore_max_id(lines)
    return TaskStore { lines: lines, next_id: max + 1 }
}

fn TaskStore_save(store){
    let body = StrVec_join_lines(store.lines)
    write_file(TASK_FILE, body)
}

fn TaskStore_list(store){
    let n = store.lines.len()
    if n == 0 {
        print("(no tasks)")
        return
    }
    let mut i = 0
    while i < n {
        let raw = store.lines.get(i)
        let p1 = strstr_pos(raw, "|")
        let id = substring(raw, 0, p1)
        let raw2 = store.lines.get(i)
        let n2 = strlen(raw2)
        let p1b = strstr_pos(raw2, "|")
        let tail = substring(raw2, p1b + 1, n2 - p1b - 1)
        let p2 = strstr_pos(tail, "|")
        let status = substring(tail, 0, p2)
        let raw3 = store.lines.get(i)
        let n3 = strlen(raw3)
        let p1c = strstr_pos(raw3, "|")
        let tail2 = substring(raw3, p1c + 1, n3 - p1c - 1)
        let p2c = strstr_pos(tail2, "|")
        let tail2_len = strlen(tail2)
        let title = substring(tail2, p2c + 1, tail2_len - p2c - 1)
        let mark = if strcmp(status, "done") == 0 { "[x]" } else { "[ ]" }
        print(strcat(strcat(strcat(mark, " #"), id), strcat(" ", title)))
        i = i + 1
    }
}

fn TaskStore_add(store, title){
    let id = i32_to_string(store.next_id)
    let line = strcat(strcat(strcat(id, "|todo|"), title), "")
    return TaskStore {
        lines: store.lines.push(line),
        next_id: store.next_id + 1,
    }
}

fn TaskStore_mark(store, id, status){
    let n = store.lines.len()
    let mut v = StrVec_new()
    let id_str = i32_to_string(id)
    let mut i = 0
    while i < n {
        let line = store.lines.get(i)
        let p1 = strstr_pos(line, "|")
        let cur_id = substring(line, 0, p1)
        if strcmp(cur_id, id_str) == 0 {
            let line2 = store.lines.get(i)
            let line2_len = strlen(line2)
            let p1b = strstr_pos(line2, "|")
            let rest = substring(line2, p1b + 1, line2_len - p1b - 1)
            let rest_len = strlen(rest)
            let p2 = strstr_pos(rest, "|")
            let title = substring(rest, p2 + 1, rest_len - p2 - 1)
            let new_line = strcat(
                strcat(strcat(strcat(cur_id, "|"), status), "|"),
                title
            )
            v = v.push(new_line)
        } else {
            v = v.push(store.lines.get(i))
        }
        i = i + 1
    }
    return TaskStore { lines: v, next_id: store.next_id }
}

fn TaskStore_remove(store, id){
    let n = store.lines.len()
    let mut v = StrVec_new()
    let id_str = i32_to_string(id)
    let mut i = 0
    while i < n {
        let line = store.lines.get(i)
        let p1 = strstr_pos(line, "|")
        let cur_id = substring(line, 0, p1)
        if strcmp(cur_id, id_str) != 0 {
            v = v.push(line)
        }
        i = i + 1
    }
    return TaskStore { lines: v, next_id: store.next_id }
}

fn TaskCLI_parse_id(text){
    let mut n = 0
    let len = strlen(text)
    let mut i = 0
    while i < len {
        let c = char_at(text, i)
        if c >= 48 && c <= 57 {
            n = n * 10 + (c - 48)
        }
        i = i + 1
    }
    return n
}

fn TaskCLI_help(){
    print("Commands: list | add <title> | done <id> | undo <id> | del <id> | save | quit")
}

fn TaskCLI_run(){
    let mut store = TaskStore_load()
    print(`Tasks file: ${TASK_FILE}`)
    TaskCLI_help()
    let mut running = 1
    while running == 1 {
        let cmd = input("task> ")
        if strcmp(cmd, "quit") == 0 || strcmp(cmd, "q") == 0 {
            TaskStore_save(store)
            running = 0
        } else {
            if strcmp(cmd, "list") == 0 || strcmp(cmd, "ls") == 0 {
                TaskStore_list(store)
            } else {
                if strcmp(cmd, "save") == 0 {
                    TaskStore_save(store)
                    print("saved.")
                } else {
                    if strstr_pos(cmd, "add ") == 0 {
                        let title = substring(cmd, 4, strlen(cmd) - 4)
                        store = TaskStore_add(store, title)
                        TaskStore_save(store)
                    } else {
                        if strstr_pos(cmd, "done ") == 0 {
                            let id = TaskCLI_parse_id(substring(cmd, 5, strlen(cmd) - 5))
                            store = TaskStore_mark(store, id, "done")
                            TaskStore_save(store)
                        } else {
                            if strstr_pos(cmd, "undo ") == 0 {
                                let id = TaskCLI_parse_id(substring(cmd, 5, strlen(cmd) - 5))
                                store = TaskStore_mark(store, id, "todo")
                                TaskStore_save(store)
                            } else {
                                if strstr_pos(cmd, "del ") == 0 {
                                    let id = TaskCLI_parse_id(substring(cmd, 4, strlen(cmd) - 4))
                                    store = TaskStore_remove(store, id)
                                    TaskStore_save(store)
                                } else {
                                    if strcmp(cmd, "help") == 0 {
                                        TaskCLI_help()
                                    } else {
                                        print("unknown — type help")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
