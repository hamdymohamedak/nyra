enum MdBlock {
    Empty
    Heading
    List
    Code
    Paragraph
}

struct MdAst {
    kind: string
    depth: i32
    text: string
}

fn Md_heading_depth(line){
    if strstr_pos(line, "### ") == 0 {
        return 3
    }
    if strstr_pos(line, "## ") == 0 {
        return 2
    }
    if strstr_pos(line, "# ") == 0 {
        return 1
    }
    return 0
}

fn Md_classify(line){
    if strlen(line) == 0 {
        return MdBlock.Empty
    }
    if Md_heading_depth(line) > 0 {
        return MdBlock.Heading
    }
    if strstr_pos(line, "- ") == 0 {
        return MdBlock.List
    }
    if strstr_pos(line, "```") == 0 {
        return MdBlock.Code
    }
    return MdBlock.Paragraph
}

fn Md_strip_heading(line, depth){
    return substring(line, depth + 1, strlen(line) - depth - 1)
}

fn Md_block_heading(line){
    let d = Md_heading_depth(line)
    return MdAst { kind: "heading", depth: d, text: Md_strip_heading(line, d) }
}

fn Md_block_ast(line){
    let kind = Md_classify(line)
    if kind == MdBlock.Empty {
        return MdAst { kind: "empty", depth: 0, text: "" }
    }
    if kind == MdBlock.Heading {
        return Md_block_heading(line)
    }
    if kind == MdBlock.List {
        return MdAst { kind: "list", depth: 0, text: substring(line, 2, strlen(line) - 2) }
    }
    if kind == MdBlock.Code {
        return MdAst { kind: "code_fence", depth: 0, text: line }
    }
    return MdAst { kind: "paragraph", depth: 0, text: line }
}

fn Md_inline_nodes(text){
    let mut out = StrVec_new()
    if strstr_pos(text, "**") >= 0 {
        out = out.push("bold")
    }
    if strstr_pos(text, "`") >= 0 {
        out = out.push("code")
    }
    if strstr_pos(text, "[") >= 0 && strstr_pos(text, "](") >= 0 {
        out = out.push("link")
    }
    if out.len() == 0 {
        out = out.push("text")
    }
    return out
}

fn Md_format(ast){
    if strcmp(ast.kind, "heading") == 0 {
        return strcat(strcat(strcat("H", i32_to_string(ast.depth)), ": "), ast.text)
    }
    return strcat(strcat(ast.kind, ": "), ast.text)
}

fn Md_parse(text){
    let lines = StrVec_from_lines(text)
    let mut out = StrVec_new()
    let n = lines.len()
    let mut i = 0
    while i < n {
        let ast = Md_block_ast(lines.get(i))
        if strcmp(ast.kind, "empty") != 0 {
            out = out.push(Md_format(ast))
            let inline = Md_inline_nodes(ast.text)
            let m = inline.len()
            let mut j = 0
            while j < m {
                out = out.push(strcat("  inline: ", inline.get(j)))
                j = j + 1
            }
        }
        i = i + 1
    }
    return out
}

fn Md_usage(){
    print("usage: mdparse <file.md>")
}

fn Md_run(args){
    if args.len() != 1 {
        Md_usage()
        return 1
    }
    let path = args.get(0)
    if exists(path) == 0 {
        print(`mdparse: ${path}: not found`)
        return 1
    }
    let nodes = Md_parse(read_file(path))
    let n = nodes.len()
    let mut i = 0
    while i < n {
        print(nodes.get(i))
        i = i + 1
    }
    return 0
}
