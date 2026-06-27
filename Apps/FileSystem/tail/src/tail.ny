
fn Tail_count_lines(text) {
    let n = strlen(text)
    if n == 0 {
        return 0
    }
    let mut lines = 1
    let mut i = 0
    while i < n {
        if char_at(text, i) == 10 {
            lines = lines + 1
        }
        i = i + 1
    }
    return lines
}

fn Tail_print_lines(text, count) {
    let total = Tail_count_lines(text)
    let skip = if total > count { total - count } else { 0 }
    let mut line_no = 0
    let mut start = 0
    let n = strlen(text)
    while start <= n {
        let rest = substring(text, start, n - start)
        let nl = strstr_pos(rest, "\n")
        let line = if nl < 0 { rest } else { substring(rest, 0, nl) }
        if line_no >= skip {
            print(line)
        }
        line_no = line_no + 1
        if nl < 0 {
            break
        }
        start = start + nl + 1
    }
}

fn Tail_run(args) {
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    let count = 10
    if n == 0 {
        let data = stdin_read_bytes(0)
        let text = bytes_to_string(data)
        bytes_free(data)
        Tail_print_lines(text, count)
        return 0
    }
    let mut i = 0
    while i < n {
        let path = paths.get(i)
        if exists(path) == 0 {
            print(strcat(strcat("tail: ", path), ": No such file"))
            return 1
        }
        let text = read_file(path)
        Tail_print_lines(text, count)
        i = i + 1
    }
    return 0
}
