enum MdLine {
    Empty
    Heading1
    Heading2
    Heading3
    ListItem
    Paragraph
}

fn Md_classify(line){
    if strlen(line) == 0 {
        return MdLine.Empty
    }
    if strstr_pos(line, "### ") == 0 {
        return MdLine.Heading3
    }
    if strstr_pos(line, "## ") == 0 {
        return MdLine.Heading2
    }
    if strstr_pos(line, "# ") == 0 {
        return MdLine.Heading1
    }
    if strstr_pos(line, "- ") == 0 {
        return MdLine.ListItem
    }
    return MdLine.Paragraph
}

fn Md_inline_bold(text){
    let mut out = text
    let pos = strstr_pos(out, "**")
    if pos >= 0 {
        let before = substring(out, 0, pos)
        let rest = substring(out, pos + 2, strlen(out) - pos - 2)
        let end = strstr_pos(rest, "**")
        if end >= 0 {
            let inner = substring(rest, 0, end)
            let out2 = out
            let pos2 = strstr_pos(out2, "**")
            let rest2 = substring(out2, pos2 + 2, strlen(out2) - pos2 - 2)
            let end2 = strstr_pos(rest2, "**")
            let after = substring(rest2, end2 + 2, strlen(rest2) - end2 - 2)
            out = strcat(strcat(strcat(strcat(strcat(before, "<strong>"), inner), "</strong>"), after), "")
        }
    }
    return out
}

fn Md_convert_line(line){
    let kind = Md_classify(line)
    return match kind {
        MdLine.Empty => ""
        MdLine.Heading1 => strcat("<h1>", strcat(substring(line, 2, strlen(line) - 2), "</h1>"))
        MdLine.Heading2 => strcat("<h2>", strcat(substring(line, 3, strlen(line) - 3), "</h2>"))
        MdLine.Heading3 => strcat("<h3>", strcat(substring(line, 4, strlen(line) - 4), "</h3>"))
        MdLine.ListItem => strcat("<li>", strcat(Md_inline_bold(substring(line, 2, strlen(line) - 2)), "</li>"))
        MdLine.Paragraph => strcat("<p>", strcat(Md_inline_bold(line), "</p>"))
    }
}

fn Md_convert(text){
    let lines = StrVec_from_lines(text)
    let n = lines.len()
    let mut out = ""
    let mut i = 0
    while i < n {
        let html = Md_convert_line(lines.get(i))
        if strlen(html) > 0 {
            out = strcat(out, html)
            out = strcat(out, "\n")
        }
        i = i + 1
    }
    return out
}

fn Md_usage(){
    print("usage: md2html <file.md>")
}

fn Md_run(args){
    if args.len() != 1 {
        Md_usage()
        return 1
    }
    let path = args.get(0)
    if exists(path) == 0 {
        print(`md2html: ${path}: not found`)
        return 1
    }
    print(Md_convert(read_file(path)))
    return 0
}
