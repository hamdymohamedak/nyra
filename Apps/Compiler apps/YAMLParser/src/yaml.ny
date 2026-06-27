struct YamlEntry {
    indent: i32
    key: string
    value: string
}

fn Yaml_count_indent(line){
    let len = strlen(line)
    let mut i = 0
    while i < len && char_at(line, i) == 32 {
        i = i + 1
    }
    return i
}

fn Yaml_trim(line){
    let len = strlen(line)
    let start = Yaml_count_indent(line)
    let mut end = len
    while end > start && char_at(line, end - 1) == 32 {
        end = end - 1
    }
    return substring(line, start, end - start)
}

fn Yaml_is_list_item(line){
    let trimmed = Yaml_trim(line)
    if strlen(trimmed) >= 2 && char_at(trimmed, 0) == 45 && char_at(trimmed, 1) == 32 {
        return 1
    }
    return 0
}

fn Yaml_list_value(line){
    let trimmed = Yaml_trim(line)
    return substring(trimmed, 2, strlen(trimmed) - 2)
}

fn Yaml_parse_kv(line){
    let trimmed = Yaml_trim(line)
    let colon = strstr_pos(trimmed, ":")
    if colon < 0 {
        return ""
    }
    let key = substring(trimmed, 0, colon)
    let rest = substring(trimmed, colon + 1, strlen(trimmed) - colon - 1)
    let rest_len = strlen(rest)
    let mut value = rest
    if rest_len > 1 && char_at(value, 0) == 32 {
        value = substring(value, 1, rest_len - 1)
    }
    return strcat(strcat(strcat(i32_to_string(Yaml_count_indent(line)), "|"), strcat(key, "|")), value)
}

fn Yaml_parse(text){
    let lines = StrVec_from_lines(text)
    let mut out = StrVec_new()
    let n = lines.len()
    let mut i = 0
    while i < n {
        let line = lines.get(i)
        if strlen(Yaml_trim(line)) > 0 {
            if Yaml_is_list_item(line) == 1 {
                let item = Yaml_list_value(line)
                let indent = Yaml_count_indent(line)
                out = out.push(strcat(strcat(i32_to_string(indent), " - "), item))
            } else {
                let entry = Yaml_parse_kv(line)
                if strlen(entry) > 0 {
                    let p1 = strstr_pos(entry, "|")
                    let indent = substring(entry, 0, p1)
                    let entry_len = strlen(entry)
                    let tail_start = p1 + 1
                    let tail_len = entry_len - tail_start
                    let tail = substring(entry, tail_start, tail_len)
                    let tail2 = tail.clone()
                    let p2 = strstr_pos(tail, "|")
                    let key = substring(tail, 0, p2)
                    let value = substring(tail2, p2 + 1, tail_len - p2 - 1)
                    out = out.push(strcat(strcat(strcat(indent, " "), strcat(key, ":")), strcat(" ", value)))
                }
            }
        }
        i = i + 1
    }
    return out
}

fn Yaml_print(entries){
    let n = entries.len()
    let mut i = 0
    while i < n {
        print(entries.get(i))
        i = i + 1
    }
}

fn Yaml_usage(){
    print("usage: yamlparse <file.yaml>")
}

fn Yaml_run(args){
    if args.len() != 1 {
        Yaml_usage()
        return 1
    }
    let path = args.get(0)
    if exists(path) == 0 {
        print(`yamlparse: ${path}: not found`)
        return 1
    }
    Yaml_print(Yaml_parse(read_file(path)))
    return 0
}
