fn AstViz_indent(depth){
    let mut out = ""
    let mut i = 0
    while i < depth {
        out = strcat(out, "  ")
        i = i + 1
    }
    return out
}

fn AstViz_depth_of(line){
    let len = strlen(line)
    let mut depth = 0
    let mut i = 0
    while i < len {
        if char_at(line, i) == 62 {
            depth = depth + 1
        } else {
            break
        }
        i = i + 1
    }
    return depth
}

fn AstViz_label(line){
    let len = strlen(line)
    let mut i = 0
    while i < len {
        if char_at(line, i) == 62 {
            i = i + 1
        } else {
            if char_at(line, i) == 32 {
                i = i + 1
            } else {
                break
            }
        }
    }
    return substring(line, i, len - i)
}

fn AstViz_render(paths){
    let n = paths.len()
    let mut i = 0
    while i < n {
        let line = paths.get(i)
        let depth = AstViz_depth_of(line)
        let label = AstViz_label(line)
        let prefix = AstViz_indent(depth)
        if i + 1 < n {
            let next_depth = AstViz_depth_of(paths.get(i + 1))
            if next_depth > depth {
                print(strcat(strcat(prefix, "├─ "), label))
            } else {
                print(strcat(strcat(prefix, "└─ "), label))
            }
        } else {
            print(strcat(strcat(prefix, "└─ "), label))
        }
        i = i + 1
    }
}

fn AstViz_demo(){
    let mut tree = StrVec_new()
    tree = tree.push("Program")
    tree = tree.push("> FnDecl main")
    tree = tree.push(">> Block")
    tree = tree.push(">>> Return")
    tree = tree.push(">>>> BinaryExpr +")
    tree = tree.push(">>>>> Literal 1")
    tree = tree.push(">>>>> BinaryExpr *")
    tree = tree.push(">>>>>> Literal 2")
    tree = tree.push(">>>>>> Literal 3")
    print("=== AST Visualizer ===", color: bold)
    AstViz_render(tree)
}

fn AstViz_run(args){
    if args.len() == 0 {
        AstViz_demo()
        return 0
    }
    let path = args.get(0)
    if exists(path) == 0 {
        print(`astviz: ${path}: not found`)
        return 1
    }
    let lines = StrVec_from_lines(read_file(path))
    AstViz_render(lines)
    return 0
}
