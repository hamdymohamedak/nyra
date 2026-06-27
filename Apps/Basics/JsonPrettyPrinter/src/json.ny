const PRINTABLE = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

struct JsonIndent {
    level: i32
    step: i32
}

fn Json_ascii_byte(code){
    if code >= 32 && code <= 126 {
        return substring(PRINTABLE, code - 32, 1)
    }
    return ""
}

fn JsonIndent_new(){
    return JsonIndent { level: 0, step: 2 }
}

fn JsonIndent_spaces(ind){
    let total = ind.level * ind.step
    let mut out = ""
    let mut i = 0
    while i < total {
        out = strcat(out, " ")
        i = i + 1
    }
    return out
}

fn Json_is_space(c){
    if c == 32 || c == 9 || c == 10 || c == 13 {
        return 1
    }
    return 0
}

fn Json_pretty(input){
    let len = strlen(input)
    let mut out = ""
    let mut ind = JsonIndent_new()
    let mut i = 0
    while i < len {
        let c = char_at(input, i)
        if Json_is_space(c) == 1 {
            i = i + 1
        } else {
            if c == 123 || c == 91 {
                out = strcat(out, Json_ascii_byte(c))
                ind = JsonIndent { level: ind.level + 1, step: ind.step }
                out = strcat(out, "\n")
                out = strcat(out, JsonIndent_spaces(ind))
                i = i + 1
            } else {
                if c == 125 || c == 93 {
                    ind = JsonIndent { level: ind.level - 1, step: ind.step }
                    out = strcat(out, "\n")
                    out = strcat(out, JsonIndent_spaces(ind))
                    out = strcat(out, Json_ascii_byte(c))
                    i = i + 1
                } else {
                    if c == 44 {
                        out = strcat(out, ",")
                        out = strcat(out, "\n")
                        out = strcat(out, JsonIndent_spaces(ind))
                        i = i + 1
                    } else {
                        if c == 58 {
                            out = strcat(out, ": ")
                            i = i + 1
                        } else {
                            out = strcat(out, Json_ascii_byte(c))
                            i = i + 1
                        }
                    }
                }
            }
        }
    }
    return out
}

fn Json_usage(){
    print("usage: jsonfmt <file>")
    print("       jsonfmt - <stdin>")
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
            print(`jsonfmt: ${path}: not found`)
            return 1
        }
        text = read_file(path)
    }
    print(Json_pretty(text))
    return 0
}
