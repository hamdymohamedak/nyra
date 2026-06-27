fn Xml_find_close(xml, pos){
    let len = strlen(xml)
    let mut i = pos
    while i < len {
        if char_at(xml, i) == 62 {
            return i
        }
        i = i + 1
    }
    return -1
}

fn Xml_read_name(xml, start, end){
    return substring(xml, start, end - start)
}

fn Xml_parse_open(xml, pos){
    let len = strlen(xml)
    if pos >= len || char_at(xml, pos) != 60 {
        return ""
    }
    if pos + 1 < len && char_at(xml, pos + 1) == 47 {
        return ""
    }
    let start = pos + 1
    let close = Xml_find_close(xml, pos)
    if close < 0 {
        return ""
    }
    let mut end = start
    while end < close {
        let c = char_at(xml, end)
        if c == 32 || c == 47 {
            break
        }
        end = end + 1
    }
    return strcat(strcat("<", Xml_read_name(xml, start, end)), ">")
}

fn Xml_parse(xml){
    let mut out = StrVec_new()
    let len = strlen(xml)
    let mut i = 0
    while i < len {
        if char_at(xml, i) == 60 {
            let tag = Xml_parse_open(xml, i)
            if strlen(tag) > 0 {
                out = out.push(tag)
            }
            let close = Xml_find_close(xml, i)
            if close >= 0 {
                i = close + 1
            } else {
                i = i + 1
            }
        } else {
            i = i + 1
        }
    }
    return out
}

fn Xml_print(nodes){
    let n = nodes.len()
    let mut i = 0
    while i < n {
        print(nodes.get(i))
        i = i + 1
    }
}

fn Xml_usage(){
    print("usage: xmlparse <file.xml>")
}

fn Xml_run(args){
    if args.len() != 1 {
        Xml_usage()
        return 1
    }
    let path = args.get(0)
    if exists(path) == 0 {
        print(`xmlparse: ${path}: not found`)
        return 1
    }
    Xml_print(Xml_parse(read_file(path)))
    return 0
}
