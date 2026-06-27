
fn Explorer_print_file(path) {
    if exists(path) == 0 {
        print(strcat(strcat("cat: ", path), ": No such file"))
        return 1
    }
    let data = bytes_read_file(path)
    stdout_write_bytes(data)
    bytes_free(data)
    return 0
}

fn Explorer_list_dir(cwd) {
    print(strcat("=== ", cwd))
    if exists(cwd) == 0 {
        print("  (not found)")
        return
    }
    if is_dir(cwd) == 0 {
        let sz = file_size(cwd)
        print(strcat(strcat("  [file] ", i32_to_string(sz as i32)), " bytes"))
        return
    }
    let entries = StrVec_from_lines(list_dir(cwd))
    let n = entries.len()
    let mut i = 0
    while i < n {
        let name = entries.get(i)
        let full = strcat(strcat(cwd, "/"), name)
        if is_dir(full) == 1 {
            print(strcat("  [dir]  ", strcat(name, "/")))
        } else {
            let sz = file_size(full)
            print(strcat(strcat(strcat("  [file] ", name), " ("), strcat(strcat(i32_to_string(sz as i32), " bytes)"), "")))
        }
        i = i + 1
    }
}

fn Explorer_parent(cwd) {
    let slash = strstr_pos(cwd, "/")
    if slash < 0 {
        return cwd
    }
    let mut last = slash
    let n = strlen(cwd)
    let mut i = slash + 1
    while i < n {
        if char_at(cwd, i) == 47 {
            last = i
        }
        i = i + 1
    }
    if last == 0 {
        return "/"
    }
    return substring(cwd, 0, last)
}

fn Cli_starts_with(s, prefix) {
    let n = strlen(prefix)
    if strlen(s) < n {
        return 0
    }
    let head = substring(s, 0, n)
    if strcmp(head, prefix) == 0 {
        return 1
    }
    return 0
}

fn Explorer_resolve(cwd, name) {
    if strcmp(name, "..") == 0 {
        return Explorer_parent(cwd)
    }
    if strcmp(name, ".") == 0 {
        return cwd
    }
    if char_at(name, 0) == 47 {
        return name
    }
    return strcat(strcat(cwd, "/"), name)
}

fn Explorer_handle_line(cwd, line) {
    if strcmp(line, "quit") == 0 || strcmp(line, "q") == 0 {
        return ""
    }
    if strcmp(line, "pwd") == 0 {
        print(cwd)
        return cwd
    }
    if strcmp(line, "ls") == 0 {
        Explorer_list_dir(cwd)
        return cwd
    }
    if Cli_starts_with(line, "cd ") == 1 {
        let target = substring(line, 3, strlen(line) - 3)
        let next = Explorer_resolve(cwd, target)
        if exists(next) == 0 {
            print(strcat(strcat("cd: ", next), ": not found"))
            return cwd
        }
        if is_dir(next) == 0 {
            print(strcat(strcat("cd: ", next), ": not a directory"))
            return cwd
        }
        return next
    }
    if Cli_starts_with(line, "cat ") == 1 {
        let target = substring(line, 4, strlen(line) - 4)
        let path = Explorer_resolve(cwd, target)
        let _ = Explorer_print_file(path)
        return cwd
    }
    print("commands: ls, cd <dir>, cat <file>, pwd, quit")
    return cwd
}

fn Explorer_run(args) {
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    let mut cwd = if n == 0 { "." } else { paths.get(0) }
    print("Nyra File Explorer — type 'quit' to exit", color: bold)
    print("commands: ls | cd <dir> | cat <file> | pwd | quit")
    Explorer_list_dir(cwd)
    while 1 == 1 {
        let line = input(strcat(cwd, "> "))
        if strcmp(line, "quit") == 0 || strcmp(line, "q") == 0 {
            break
        }
        let next = Explorer_handle_line(cwd, line)
        if strlen(next) == 0 {
            break
        }
        cwd = next
    }
    return 0
}
