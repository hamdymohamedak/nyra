fn Huff_count(text, ch){
    let len = strlen(text)
    let mut count = 0
    let mut i = 0
    while i < len {
        if char_at(text, i) == ch {
            count = count + 1
        }
        i = i + 1
    }
    return count
}

fn Huff_code(ch){
    if ch == 97 {
        return "0"
    }
    if ch == 98 {
        return "10"
    }
    if ch == 99 {
        return "110"
    }
    if ch == 32 {
        return "111"
    }
    return "11"
}

fn Huff_encode(text){
    let len = strlen(text)
    let mut out = ""
    let mut i = 0
    while i < len {
        out = strcat(out, Huff_code(char_at(text, i)))
        i = i + 1
    }
    return out
}

fn Huffman_run(args){
    let text = if args.len() == 1 { args.get(0) } else { "abc ab" }
    print(`freq a: ${Huff_count(text, 97)}`)
    print(`freq b: ${Huff_count(text, 98)}`)
    print(`freq c: ${Huff_count(text, 99)}`)
    print(`encoded: ${Huff_encode(text)}`)
    return 0
}
