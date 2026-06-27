struct TomlEntry {
    section: string
    key: string
    value: string
}

struct TomlDoc {
    entries: StrVec
}

fn Toml_trim(line){
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

fn Toml_is_comment(line){
    if strlen(line) == 0 {
        return 1
    }
    if char_at(line, 0) == 35 {
        return 1
    }
    return 0
}

fn Toml_is_table(line){
    if strlen(line) < 2 {
        return 0
    }
    if char_at(line, 0) == 91 && char_at(line, strlen(line) - 1) == 93 {
        return 1
    }
    return 0
}

fn Toml_table_name(line){
    return substring(line, 1, strlen(line) - 2)
}

fn Toml_parse_kv(line, section){
    let eq = strstr_pos(line, "=")
    if eq < 0 {
        return ""
    }
    let key = Toml_trim(substring(line, 0, eq))
    let value = Toml_trim(substring(line, eq + 1, strlen(line) - eq - 1))
    if strlen(key) == 0 {
        return ""
    }
    return strcat(strcat(strcat(strcat(section, "|"), key), "|"), value)
}

fn Toml_unquote(value){
    let len = strlen(value)
    if len >= 2 && char_at(value, 0) == 34 && char_at(value, len - 1) == 34 {
        return substring(value, 1, len - 2)
    }
    return value
}

fn Toml_parse(text){
    let lines = StrVec_from_lines(text)
    let mut entries = StrVec_new()
    let mut section = ""
    let n = lines.len()
    let mut i = 0
    while i < n {
        let trimmed = Toml_trim(lines.get(i))
        if Toml_is_comment(trimmed) == 0 {
            if Toml_is_table(trimmed) == 1 {
                section = Toml_table_name(trimmed)
            } else {
                let entry = Toml_parse_kv(trimmed, section)
                if strlen(entry) > 0 {
                    entries = entries.push(entry)
                }
            }
        }
        i = i + 1
    }
    return TomlDoc { entries: entries }
}

fn Toml_print(doc){
    let n = doc.entries.len()
    let mut i = 0
    while i < n {
        let raw = doc.entries.get(i)
        let p1 = strstr_pos(raw, "|")
        let section = substring(raw, 0, p1)
        let tail = substring(raw, p1 + 1, strlen(raw) - p1 - 1)
        let p2 = strstr_pos(tail, "|")
        let key = substring(tail, 0, p2)
        let value = Toml_unquote(substring(tail, p2 + 1, strlen(tail) - p2 - 1))
        if strlen(section) > 0 {
            print(`[${section}] ${key} = ${value}`)
        } else {
            print(`${key} = ${value}`)
        }
        i = i + 1
    }
}

fn Toml_usage(){
    print("usage: tomlparse <file.toml>")
}

fn Toml_run(args){
    if args.len() != 1 {
        Toml_usage()
        return 1
    }
    let path = args.get(0)
    if exists(path) == 0 {
        print(`tomlparse: ${path}: not found`)
        return 1
    }
    Toml_print(Toml_parse(read_file(path)))
    return 0
}
