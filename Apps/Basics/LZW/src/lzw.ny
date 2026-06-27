fn Lzw_find(dict, s){
    let n = dict.len()
    let mut i = 0
    while i < n {
        if strcmp(dict.get(i), s) == 0 {
            return i
        }
        i = i + 1
    }
    return -1
}

fn Lzw_compress(text){
    let mut dict = StrVec_new()
    let mut i = 0
    while i < 256 {
        dict = dict.push(substring(" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~", i, 1))
        i = i + 1
    }
    let mut w = ""
    let mut out = StrVec_new()
    let len = strlen(text)
    let mut j = 0
    while j < len {
        let c = substring(text, j, 1)
        let wc = strcat(w, c)
        if Lzw_find(dict, wc) >= 0 {
            w = wc
        } else {
            let idx = Lzw_find(dict, w)
            out = out.push(i32_to_string(idx))
            dict = dict.push(wc)
            w = c
        }
        j = j + 1
    }
    if strlen(w) > 0 {
        out = out.push(i32_to_string(Lzw_find(dict, w)))
    }
    return out
}

fn LZW_run(args){
    let text = if args.len() == 1 { args.get(0) } else { "TOBEORNOTOBEORTOBEORNOT" }
    let codes = Lzw_compress(text)
    print(`input: ${text}`)
    print("LZW codes:")
    let n = codes.len()
    let mut i = 0
    while i < n {
        print(codes.get(i))
        i = i + 1
    }
    return 0
}
