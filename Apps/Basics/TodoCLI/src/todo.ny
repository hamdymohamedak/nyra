const TODO_FILE = "todos.txt"

struct TaskList {
    items: StrVec
    next_id: i32
}

fn TaskList_split_lines(text){
    return StrVec_from_lines(text)
}

fn TaskList_max_id(lines){
    let n = lines.len()
    let mut max = 0
    let mut i = 0
    while i < n {
        let line = lines.get(i)
        let sep = strstr_pos(line, "|")
        if sep > 0 {
            let id = str_to_i32(substring(line, 0, sep))
            if id > max {
                max = id
            }
        }
        i = i + 1
    }
    return max
}

fn TaskList_load(){
    if exists(TODO_FILE) == 0 {
        return TaskList { items: StrVec_new(), next_id: 1 }
    }
    let text = read_file(TODO_FILE)
    let lines = TaskList_split_lines(text)
    return TaskList { items: lines, next_id: TaskList_max_id(lines) + 1 }
}

fn TaskList_save(list){
    write_file(TODO_FILE, StrVec_join_lines(list.items))
}

fn TaskList_add(list, title){
    let id = i32_to_string(list.next_id)
    let line = `${id}|pending|${title}`
    return TaskList {
        items: list.items.push(line),
        next_id: list.next_id + 1,
    }
}

fn TaskList_list(list){
    let n = list.items.len()
    if n == 0 {
        print("(no todos)")
        return
    }
    let mut i = 0
    while i < n {
        let raw = list.items.get(i)
        let raw_len = strlen(raw)
        let p1 = strstr_pos(raw, "|")
        let id = substring(raw, 0, p1)
        let tail = substring(raw, p1 + 1, raw_len - p1 - 1)
        let p2 = strstr_pos(tail, "|")
        let status = substring(tail, 0, p2)
        let raw2 = list.items.get(i)
        let raw2_len = strlen(raw2)
        let p1b = strstr_pos(raw2, "|")
        let tail2 = substring(raw2, p1b + 1, raw2_len - p1b - 1)
        let p2b = strstr_pos(tail2, "|")
        let tail2_len = strlen(tail2)
        let title = substring(tail2, p2b + 1, tail2_len - p2b - 1)
        let mark = if strcmp(status, "done") == 0 { "[x]" } else { "[ ]" }
        print(`${mark} #${id} ${title}`)
        i = i + 1
    }
}

fn TaskList_done(list, id){
    return TaskList_set_status(list, id, "done")
}

fn TaskList_set_status(list, id, status){
    let n = list.items.len()
    let mut v = StrVec_new()
    let id_str = i32_to_string(id)
    let mut i = 0
    while i < n {
        let line = list.items.get(i)
        let p1 = strstr_pos(line, "|")
        let cur_id = substring(line, 0, p1)
        if strcmp(cur_id, id_str) == 0 {
            let line_len = strlen(line)
            let tail = substring(line, p1 + 1, line_len - p1 - 1)
            let tail_len = strlen(tail)
            let p2 = strstr_pos(tail, "|")
            let title = substring(tail, p2 + 1, tail_len - p2 - 1)
            v = v.push(`${cur_id}|${status}|${title}`)
        } else {
            v = v.push(line)
        }
        i = i + 1
    }
    return TaskList { items: v, next_id: list.next_id }
}

fn TaskList_del(list, id){
    let n = list.items.len()
    let mut v = StrVec_new()
    let id_str = i32_to_string(id)
    let mut i = 0
    while i < n {
        let line = list.items.get(i)
        let p1 = strstr_pos(line, "|")
        let cur_id = substring(line, 0, p1)
        if strcmp(cur_id, id_str) != 0 {
            v = v.push(line)
        }
        i = i + 1
    }
    return TaskList { items: v, next_id: list.next_id }
}

fn TodoCLI_help(){
    print("Commands: list | add <title> | done <id> | del <id> | quit")
}

fn TodoCLI_run(){
    let mut list = TaskList_load()
    print(`Todo file: ${TODO_FILE}`)
    TodoCLI_help()
    let mut running = 1
    while running == 1 {
        let cmd = input("todo> ")
        if strcmp(cmd, "quit") == 0 || strcmp(cmd, "q") == 0 {
            TaskList_save(list)
            running = 0
        } else {
            if strcmp(cmd, "list") == 0 || strcmp(cmd, "ls") == 0 {
                TaskList_list(list)
            } else {
                if strstr_pos(cmd, "add ") == 0 {
                    let title = substring(cmd, 4, strlen(cmd) - 4)
                    list = TaskList_add(list, title)
                    TaskList_save(list)
                } else {
                    if strstr_pos(cmd, "done ") == 0 {
                        let id = str_to_i32(substring(cmd, 5, strlen(cmd) - 5))
                        list = TaskList_done(list, id)
                        TaskList_save(list)
                    } else {
                        if strstr_pos(cmd, "del ") == 0 {
                            let id = str_to_i32(substring(cmd, 4, strlen(cmd) - 4))
                            list = TaskList_del(list, id)
                            TaskList_save(list)
                        } else {
                            if strcmp(cmd, "help") == 0 {
                                TodoCLI_help()
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
