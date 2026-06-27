import "../../shared/cli.ny"
import "../../shared/walk.ny"

fn DocGen_is_doc_line(line) {
    if strstr_pos(line, "///") == 0 {
        return 1
    }
    return 0
}

fn DocGen_doc_text(line) {
    let rest = substring(line, 3, strlen(line) - 3)
    let mut i = 0
    while i < strlen(rest) && char_at(rest, i) == 32 {
        i = i + 1
    }
    return substring(rest, i, strlen(rest) - i)
}

fn DocGen_is_fn_line(line) {
    if strstr_pos(line, "fn ") < 0 {
        return 0
    }
    if strstr_pos(line, "extern fn ") == 0 {
        return 0
    }
    if strstr_pos(line, "test fn ") == 0 {
        return 0
    }
    return 1
}

fn DocGen_is_struct_line(line) {
    if strstr_pos(line, "struct ") == 0 {
        return 1
    }
    return 0
}

fn DocGen_extract_name(line, keyword) {
    let key_len = strlen(keyword)
    let rest = substring(line, key_len, strlen(line) - key_len)
    let paren = strstr_pos(rest, "(")
    let brace = strstr_pos(rest, "{")
    let mut end = strlen(rest)
    if paren >= 0 && (brace < 0 || paren < brace) {
        end = paren
    } else {
        if brace >= 0 {
            end = brace
        }
    }
    let name = substring(rest, 0, end)
    let mut i = 0
    while i < strlen(name) && char_at(name, i) == 32 {
        i = i + 1
    }
    if i >= strlen(name) {
        return ""
    }
    let trimmed = substring(name, i, strlen(name) - i)
    let sp = strstr_pos(trimmed, " ")
    if sp >= 0 {
        return substring(trimmed, 0, sp)
    }
    return trimmed
}

fn DocGen_scan_file(path, symbols) {
    let text = read_file(path)
    let lines = StrVec_from_lines(text)
    let n = lines.len()
    let mut out = symbols
    let mut pending_doc = ""
    let mut i = 0
    while i < n {
        let line = lines.get(i)
        if DocGen_is_doc_line(line) == 1 {
            let piece = DocGen_doc_text(line)
            if strlen(pending_doc) == 0 {
                pending_doc = piece
            } else {
                pending_doc = strcat(strcat(pending_doc, "\n"), piece)
            }
        } else {
            if DocGen_is_fn_line(line) == 1 {
                let name = DocGen_extract_name(line, "fn ")
                if strlen(name) > 0 {
                    let row = if strlen(pending_doc) > 0 {
                        strcat(strcat(strcat("fn ", name), " — "), pending_doc)
                    } else {
                        strcat(strcat("fn ", name), strcat(" — ", path))
                    }
                    out = out.push(row)
                }
                pending_doc = ""
            } else {
                if DocGen_is_struct_line(line) == 1 {
                    let name = DocGen_extract_name(line, "struct ")
                    if strlen(name) > 0 {
                        let row = if strlen(pending_doc) > 0 {
                            strcat(strcat(strcat("struct ", name), " — "), pending_doc)
                        } else {
                            strcat(strcat(strcat("struct ", name), " — "), path)
                        }
                        out = out.push(row)
                    }
                    pending_doc = ""
                }
            }
        }
        i = i + 1
    }
    return out
}

fn DocGen_run(args) {
    let listed = DevCli_paths(args)
    let n = DevPathList_len(listed)
    if n == 0 {
        DevCli_usage("ny-docgen", " <src-dir> [out.md]")
        return 1
    }
    let root = DevPathList_at(listed, 0)
    let out_path = if n >= 2 { DevPathList_at(listed, 1) } else { "API.md" }
    let found = DevWalk_collect_ny(root, DevFileList { files: StrVec_new() })
    let fc = DevFileList_len(found)
    let mut symbols = StrVec_new()
    let mut i = 0
    while i < fc {
        symbols = DocGen_scan_file(DevFileList_at(found, i), symbols)
        i = i + 1
    }
    let mut md = strcat("# API\n\nGenerated from ", root)
    md = strcat(md, "\n\n")
    let sc = symbols.len()
    let mut j = 0
    while j < sc {
        md = strcat(md, strcat("- ", strcat(symbols.get(j), "\n")))
        j = j + 1
    }
    write_file(out_path, md)
    print(`wrote ${sc} symbols to ${out_path}`)
    return 0
}
