import "stdlib/collections/kv_vec.ny"

struct JsonAst {
    kind: string
    text: string
}

fn Json_is_space(c){
    if c == 32 || c == 9 || c == 10 || c == 13 {
        return 1
    }
    return 0
}

fn Json_skip(input, pos){
    let len = strlen(input)
    let mut i = pos
    while i < len && Json_is_space(char_at(input.clone(), i)) == 1 {
        i = i + 1
    }
    return i
}

fn Json_peek(input, pos){
    let len = strlen(input)
    if pos >= len {
        return 0
    }
    return char_at(input.clone(), pos)
}

fn Json_read_string(input, pos){
    let src = input.clone()
    let len = strlen(src)
    let mut i = pos + 1
    let mut out = ""
    while i < len {
        let c = char_at(src, i)
        if c == 34 {
            return JsonAst { kind: "string", text: out }
        }
        if c == 92 {
            i = i + 1
            if i < len {
                let esc = char_at(input, i)
                if esc == 110 {
                    out = strcat(out, "\n")
                } else {
                    if esc == 116 {
                        out = strcat(out, "\t")
                    } else {
                        let slice = substring(src.clone(), i, 1)
                        out = strcat(out, slice)
                    }
                }
            }
        } else {
            let slice = substring(src.clone(), i, 1)
            out = strcat(out, slice)
        }
        i = i + 1
    }
    return JsonAst { kind: "error", text: "unterminated string" }
}

fn Json_read_number(input, pos){
    let src = input.clone()
    let len = strlen(src)
    let start = pos
    let mut i = pos
    while i < len {
        let c = char_at(src, i)
        if c >= 48 && c <= 57 {
            i = i + 1
        } else {
            if c == 46 {
                i = i + 1
            } else {
                if c == 45 && i == start {
                    i = i + 1
                } else {
                    break
                }
            }
        }
    }
    return JsonAst { kind: "number", text: substring(src, start, i - start) }
}

fn Json_read_literal(input, pos, word, kind){
    let src = input.clone()
    let len = strlen(word)
    let slice = substring(src, pos, len)
    if strcmp(slice, word) == 0 {
        return JsonAst { kind: kind, text: word }
    }
    return JsonAst { kind: "error", text: "bad literal" }
}

fn Json_parse_value(input, pos){
    let i = Json_skip(input, pos)
    let c = Json_peek(input, i)
    if c == 34 {
        return Json_read_string(input, i)
    }
    if c == 123 {
        return JsonAst { kind: "object", text: Json_parse_object_summary(input, i) }
    }
    if c == 91 {
        return JsonAst { kind: "array", text: Json_parse_array_summary(input, i) }
    }
    if c == 116 {
        return Json_read_literal(input, i, "true", "bool")
    }
    if c == 102 {
        return Json_read_literal(input, i, "false", "bool")
    }
    if c == 110 {
        return Json_read_literal(input, i, "null", "null")
    }
    if c == 45 || (c >= 48 && c <= 57) {
        return Json_read_number(input, i)
    }
    return JsonAst { kind: "error", text: "?" }
}

fn Json_advance_value(text, pos){
    let len = strlen(text)
    let i = Json_skip(text, pos)
    let c = Json_peek(text, i)
    if c == 34 {
        let mut j = i + 1
        while j < len && char_at(text.clone(), j) != 34 {
            j = j + 1
        }
        if j < len {
            return j + 1
        }
        return j
    }
    if c == 123 || c == 91 {
        let mut close = 125
        if c == 91 {
            close = 93
        }
        let mut depth = 0
        let mut j = i
        while j < len {
            let ch = char_at(text.clone(), j)
            if ch == c {
                depth = depth + 1
            } else {
                if ch == close {
                    depth = depth - 1
                    if depth == 0 {
                        return j + 1
                    }
                }
            }
            j = j + 1
        }
        return len
    }
    let mut j = i
    while j < len {
        let ch = char_at(text, j)
        if ch == 44 || ch == 125 || ch == 93 || Json_is_space(ch) == 1 {
            break
        }
        j = j + 1
    }
    return j
}

fn Json_parse_object_summary(input, pos){
    let buf = input.clone()
    let mut kv = KvVec_new()
    let len = strlen(buf)
    let mut i = Json_skip(buf.clone(), pos)
    if Json_peek(buf.clone(), i) != 123 {
        return "{}"
    }
    i = i + 1
    while i < len {
        i = Json_skip(buf.clone(), i)
        if Json_peek(buf.clone(), i) == 125 {
            break
        }
        if Json_peek(buf.clone(), i) != 34 {
            break
        }
        let key_ast = Json_read_string(buf.clone(), i)
        let mut j = Json_advance_value(buf.clone(), i)
        j = Json_skip(buf.clone(), j)
        if Json_peek(buf.clone(), j) == 58 {
            j = j + 1
        }
        j = Json_skip(buf.clone(), j)
        let val_ast = Json_parse_value(buf.clone(), j)
        kv = KvVec_push(kv, key_ast.text, strcat(strcat(val_ast.kind, ":"), val_ast.text))
        i = Json_advance_value(buf.clone(), j)
        i = Json_skip(buf.clone(), i)
        if Json_peek(buf.clone(), i) == 44 {
            i = i + 1
        }
    }
    return Json_format_kv(kv)
}

fn Json_parse_array_summary(input, pos){
    let buf = input.clone()
    let len = strlen(buf)
    let mut i = Json_skip(buf.clone(), pos)
    if Json_peek(buf.clone(), i) != 91 {
        return "[]"
    }
    i = i + 1
    let mut parts = StrVec_new()
    while i < len {
        i = Json_skip(buf.clone(), i)
        if Json_peek(buf.clone(), i) == 93 {
            break
        }
        let val_ast = Json_parse_value(buf.clone(), i)
        parts = parts.push(Json_format(val_ast))
        i = Json_advance_value(buf.clone(), i)
        i = Json_skip(buf.clone(), i)
        if Json_peek(buf.clone(), i) == 44 {
            i = i + 1
        }
    }
    let mut out = "["
    let n = parts.len()
    let mut idx = 0
    while idx < n {
        if idx > 0 {
            out = strcat(out, ", ")
        }
        out = strcat(out, parts.get(idx))
        idx = idx + 1
    }
    return strcat(out, "]")
}

fn Json_format_kv(kv){
    let n = KvVec_len(kv)
    let mut out = "{"
    let mut idx = 0
    while idx < n {
        if idx > 0 {
            out = strcat(out, ", ")
        }
        out = strcat(strcat(strcat(out, KvVec_get_key(kv, idx)), ": "), KvVec_get_value(kv, idx))
        idx = idx + 1
    }
    return strcat(out, "}")
}

fn Json_format(ast){
    return strcat(strcat(ast.kind, ": "), ast.text)
}

fn Json_parse(input){
    let ast = Json_parse_value(input, 0)
    return Json_format(ast)
}

fn Json_usage(){
    print("usage: jsonparse <file.json>")
    print("       jsonparse -   # stdin")
}

fn Json_read_stdin(){
    let data = stdin_read_bytes(0)
    let s = bytes_to_string(data)
    bytes_free(data)
    return s
}

fn Json_run(args){
    if args.len() != 1 {
        Json_usage()
        return 1
    }
    let path = args.get(0)
    let mut text = ""
    if strcmp(path, "-") == 0 {
        text = Json_read_stdin()
    } else {
        if exists(path) == 0 {
            print(`jsonparse: ${path}: not found`)
            return 1
        }
        text = read_file(path)
    }
    print(Json_parse(text))
    return 0
}
