
fn Wc_count_lines(text) {
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

fn Wc_count_words(text) {
    let n = strlen(text)
    if n == 0 {
        return 0
    }
    let mut words = 0
    let mut in_word = 0
    let mut i = 0
    while i < n {
        let c = char_at(text, i)
        let space = if c == 32 || c == 9 || c == 10 || c == 13 { 1 } else { 0 }
        if space == 0 && in_word == 0 {
            words = words + 1
            in_word = 1
        }
        if space == 1 {
            in_word = 0
        }
        i = i + 1
    }
    return words
}

fn Wc_count_file(path, show_lines, show_words, show_chars) {
    if exists(path) == 0 {
        print(strcat(strcat("wc: ", path), ": No such file"))
        return 1
    }
    let text = read_file(path)
    let lines = Wc_count_lines(text)
    let words = Wc_count_words(text)
    let chars = strlen(text)
    let mut out = ""
    if show_lines == 1 {
        out = strcat(out, strcat(i32_to_string(lines), " "))
    }
    if show_words == 1 {
        out = strcat(out, strcat(i32_to_string(words), " "))
    }
    if show_chars == 1 {
        out = strcat(out, strcat(i32_to_string(chars), " "))
    }
    print(strcat(strcat(out, path), ""))
    return 0
}

fn Wc_run(args) {
    let show_lines = Cli_has_flag(args, "-l")
    let show_words = Cli_has_flag(args, "-w")
    let show_chars = Cli_has_flag(args, "-c")
    let all = if show_lines == 0 && show_words == 0 && show_chars == 0 { 1 } else { 0 }
    let lines = if all == 1 { 1 } else { show_lines }
    let words = if all == 1 { 1 } else { show_words }
    let chars = if all == 1 { 1 } else { show_chars }
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if n == 0 {
        let data = stdin_read_bytes(0)
        let text = bytes_to_string(data)
        bytes_free(data)
        let mut out = ""
        if lines == 1 {
            out = strcat(out, strcat(i32_to_string(Wc_count_lines(text)), " "))
        }
        if words == 1 {
            out = strcat(out, strcat(i32_to_string(Wc_count_words(text)), " "))
        }
        if chars == 1 {
            out = strcat(out, strcat(i32_to_string(strlen(text)), " "))
        }
        print(out)
        return 0
    }
    let mut i = 0
    while i < n {
        let code = Wc_count_file(paths.get(i), lines, words, chars)
        if code != 0 {
            return code
        }
        i = i + 1
    }
    return 0
}
