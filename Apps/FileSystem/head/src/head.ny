
fn Head_print_lines(text, count) {
    let mut printed = 0
    let mut start = 0
    let n = strlen(text)
    while start <= n && printed < count {
        let rest = substring(text, start, n - start)
        let nl = strstr_pos(rest, "\n")
        let line = if nl < 0 { rest } else { substring(rest, 0, nl) }
        print(line)
        printed = printed + 1
        if nl < 0 {
            break
        }
        start = start + nl + 1
    }
}

fn Head_run(args) {
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    let count = 10
    if n == 0 {
        let data = stdin_read_bytes(0)
        let text = bytes_to_string(data)
        bytes_free(data)
        Head_print_lines(text, count)
        return 0
    }
    let mut i = 0
    while i < n {
        let path = paths.get(i)
        if exists(path) == 0 {
            print(strcat(strcat("head: ", path), ": No such file"))
            return 1
        }
        let text = read_file(path)
        Head_print_lines(text, count)
        i = i + 1
    }
    return 0
}
