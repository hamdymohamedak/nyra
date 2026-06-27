fn Regex_peek(pat, pos){
    let len = strlen(pat)
    if pos >= len {
        return 0
    }
    return char_at(pat, pos)
}

fn Regex_peek_text(text, pos){
    let len = strlen(text)
    if pos >= len {
        return 0
    }
    return char_at(text, pos)
}

fn Regex_match_char(c, text, tpos){
    let tc = Regex_peek_text(text, tpos)
    if tc == 0 {
        return 0
    }
    if c == 46 {
        return 1
    }
    if c == tc {
        return 1
    }
    return 0
}

fn Regex_match_here(pat, pos, text, tpos){
    let pat_len = strlen(pat)
    if pos >= pat_len {
        if tpos >= strlen(text) {
            return 1
        }
        return 0
    }
    if pos + 1 < pat_len && Regex_peek(pat, pos + 1) == 42 {
        return Regex_match_star(Regex_peek(pat, pos), pat, pos + 2, text, tpos)
    }
    if Regex_match_char(Regex_peek(pat, pos), text, tpos) == 0 {
        return 0
    }
    return Regex_match_here(pat, pos + 1, text, tpos + 1)
}

fn Regex_match_star(atom, pat, pos, text, tpos){
    let mut j = tpos
    while 1 == 1 {
        if Regex_match_here(pat, pos, text, j) == 1 {
            return 1
        }
        if Regex_match_char(atom, text, j) == 0 {
            return 0
        }
        j = j + 1
    }
    return 0
}

fn Regex_is_match(pattern, text){
    return Regex_match_here(pattern, 0, text, 0)
}

fn Regex_demo(){
    print("=== RegexEngine — Thompson-style subset ===", color: bold)
    let mut patterns = StrVec_new()
    patterns = patterns.push("ab*c")
    patterns = patterns.push("a.c")
    patterns = patterns.push("x*y")
    let mut samples = StrVec_new()
    samples = samples.push("ac")
    samples = samples.push("abc")
    samples = samples.push("axc")
    samples = samples.push("xy")
    let mut i = 0
    while i < 3 {
        let pat = patterns.get(i)
        let mut j = 0
        while j < 4 {
            let txt = samples.get(j)
            let ok = Regex_is_match(pat, txt)
            print(`${pat} ~ ${txt} => ${i32_to_string(ok)}`)
            j = j + 1
        }
        print("---")
        i = i + 1
    }
}

fn Regex_run(args){
    if args.len() < 2 {
        Regex_demo()
        return 0
    }
    let pattern = args.get(0)
    let text = args.get(1)
    if Regex_is_match(pattern, text) == 1 {
        print("match")
        return 0
    }
    print("no match")
    return 1
}
