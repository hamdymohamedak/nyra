
fn Grep_line_matches(line, needle, ignore_case, use_regex) {
    if use_regex == 1 {
        let re = Regex_new(needle)
        let hit = re.matches(line)
        Regex_free(re)
        return hit
    }
    if ignore_case == 1 {
        let hay = String_toLowerCase(line)
        let ndl = String_toLowerCase(needle)
        if strstr_pos(hay, ndl) >= 0 {
            return 1
        }
        return 0
    }
    if strstr_pos(line, needle) >= 0 {
        return 1
    }
    return 0
}

fn Grep_search_text(text, needle, ignore_case, use_regex, show_line, invert, label) {
    let mut hits = 0
    let mut line_no = 1
    let mut start = 0
    let n = strlen(text)
    let multi = if strlen(label) > 0 { 1 } else { 0 }
    while start <= n {
        let rest = substring(text, start, n - start)
        let nl = strstr_pos(rest, "\n")
        let line = if nl < 0 { rest } else { substring(rest, 0, nl) }
        let matched = Grep_line_matches(line, needle, ignore_case, use_regex)
        let show = if invert == 1 { 1 - matched } else { matched }
        if show == 1 {
            hits = hits + 1
            if multi == 1 && show_line == 1 {
                print(strcat(strcat(strcat(strcat(label, ":"), i32_to_string(line_no)), ":"), line))
            } else {
                if show_line == 1 {
                    print(strcat(strcat(i32_to_string(line_no), ":"), line))
                } else {
                    if multi == 1 {
                        print(strcat(strcat(label, ":"), line))
                    } else {
                        print(line)
                    }
                }
            }
        }
        if nl < 0 {
            break
        }
        start = start + nl + 1
        line_no = line_no + 1
    }
    return hits
}

fn Grep_run(args) {
    let ignore_case = Cli_has_flag(args, "-i")
    let show_line = Cli_has_flag(args, "-n")
    let invert = Cli_has_flag(args, "-v")
    let fixed = Cli_has_flag(args, "-F")
    let use_regex = if fixed == 1 { 0 } else { Cli_has_flag(args, "-E") }
    let files = Cli_strip_flags(args)
    let n = files.len()
    if n == 0 {
        Cli_usage("grep", " [-E|-F] [-inv] pattern [file ...]")
        return 2
    }
    let needle = files.get(0)
    if n == 1 {
        let data = stdin_read_bytes(0)
        let text = bytes_to_string(data)
        bytes_free(data)
        let hits = Grep_search_text(text, needle, ignore_case, use_regex, show_line, invert, "")
        if hits == 0 {
            return 1
        }
        return 0
    }
    let mut total = 0
    let mut i = 1
    while i < n {
        let path = files.get(i)
        if exists(path) == 0 {
            print(strcat(strcat("grep: ", path), ": No such file"))
        } else {
            let data = bytes_read_file(path)
            let text = bytes_to_string(data)
            bytes_free(data)
            let label = if n > 2 { path } else { "" }
            total = total + Grep_search_text(text, needle, ignore_case, use_regex, show_line, invert, label)
        }
        i = i + 1
    }
    if total == 0 {
        return 1
    }
    return 0
}
