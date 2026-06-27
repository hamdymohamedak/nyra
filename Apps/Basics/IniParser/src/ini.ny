struct IniDoc {
    entries: StrVec
}

fn Ini_trim_line(line){
    let len = strlen(line)
    let mut start = 0
    while start < len && char_at(line, start) == 32 {
        start = start + 1
    }
    let mut end = len
    while end > start && char_at(line, end - 1) == 32 {
        end = end - 1
    }
    return substring(line, start, end - start)
}

fn Ini_parse_line(line, section){
    let trimmed = Ini_trim_line(line)
    if strlen(trimmed) == 0 {
        return ""
    }
    if char_at(trimmed, 0) == 59 {
        return ""
    }
    if char_at(trimmed, 0) == 91 {
        return trimmed
    }
    let eq = strstr_pos(trimmed, "=")
    if eq < 0 {
        return ""
    }
    let key = Ini_trim_line(substring(trimmed, 0, eq))
    let value = Ini_trim_line(substring(trimmed, eq + 1, strlen(trimmed) - eq - 1))
    return strcat(strcat(strcat(strcat(section, "|"), key), "|"), value)
}

fn Ini_section_name(line){
    let len = strlen(line)
    return substring(line, 1, len - 2)
}

fn Ini_parse(text){
    let lines = StrVec_from_lines(text)
    let mut entries = StrVec_new()
    let mut section = ""
    let n = lines.len()
    let mut i = 0
    while i < n {
        let line = lines.get(i)
        let trimmed = Ini_trim_line(line)
        if strlen(trimmed) > 0 && char_at(trimmed, 0) != 59 {
            if char_at(trimmed, 0) == 91 {
                section = Ini_section_name(trimmed)
            } else {
                let entry = Ini_parse_line(line, section)
                if strlen(entry) > 0 {
                    entries = entries.push(entry)
                }
            }
        }
        i = i + 1
    }
    return IniDoc { entries: entries }
}

fn Ini_print(doc){
    let n = doc.entries.len()
    let mut i = 0
    while i < n {
        let raw = doc.entries.get(i)
        let p1 = strstr_pos(raw, "|")
        let section = substring(raw, 0, p1)
        let tail = substring(raw, p1 + 1, strlen(raw) - p1 - 1)
        let p2 = strstr_pos(tail, "|")
        let key = substring(tail, 0, p2)
        let raw2 = doc.entries.get(i)
        let raw2_len = strlen(raw2)
        let p1b = strstr_pos(raw2, "|")
        let tail2 = substring(raw2, p1b + 1, raw2_len - p1b - 1)
        let p2b = strstr_pos(tail2, "|")
        let value = substring(tail2, p2b + 1, strlen(tail2) - p2b - 1)
        print(`[${section}] ${key} = ${value}`)
        i = i + 1
    }
}

fn Ini_usage(){
    print("usage: iniparse <file.ini>")
}

fn Ini_run(args){
    if args.len() != 1 {
        Ini_usage()
        return 1
    }
    let path = args.get(0)
    if exists(path) == 0 {
        print(`iniparse: ${path}: not found`)
        return 1
    }
    let doc = Ini_parse(read_file(path))
    Ini_print(doc)
    return 0
}
