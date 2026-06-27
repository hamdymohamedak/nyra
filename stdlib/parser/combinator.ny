import "../strings.ny"
import "../vec_str.ny"
import "sourceloc.ny"

struct ParseCursor {
    text: string
    pos: i32
    loc: SourceLoc
}

struct ParseOk {
    value: string
    pos: i32
    loc: SourceLoc
}

fn ParseCursor_new(text, file){
    return ParseCursor { text: text, pos: 0, loc: SourceLoc_new(file, 1, 1) }
}

fn ParseCursor_len(cur){
    return strlen(cur.text)
}

fn ParseCursor_eof(cur){
    if cur.pos >= ParseCursor_len(cur) {
        return 1
    }
    return 0
}

fn ParseCursor_peek(cur){
    if ParseCursor_eof(cur) == 1 {
        return 0
    }
    return char_at(cur.text, cur.pos)
}

fn ParseCursor_advance(cur){
    let ch = ParseCursor_peek(cur)
    return ParseCursor {
        text: cur.text,
        pos: cur.pos + 1,
        loc: SourceLoc_advance(cur.loc, ch)
    }
}

fn ParseCursor_skip_space(cur){
    let mut c = cur
    let mut ch = ParseCursor_peek(c)
    while ch == 32 || ch == 9 || ch == 10 || ch == 13 {
        c = ParseCursor_advance(c)
        ch = ParseCursor_peek(c)
    }
    return c
}

fn ParseOk_pack(value, cur){
    return strcat(strcat(strcat(value, "|"), i32_to_string(cur.pos)), strcat("|", SourceLoc_format(cur.loc)))
}

fn Comb_literal(cur, lit){
    let c = ParseCursor_skip_space(cur)
    let len = strlen(lit)
    let slice = substring(c.text, c.pos, len)
    if strcmp(slice, lit) != 0 {
        return ""
    }
    let mut next = c
    let mut i = 0
    while i < len {
        next = ParseCursor_advance(next)
        i = i + 1
    }
    return ParseOk_pack(lit, next)
}

fn Comb_take_while(cur, kind){
    let c = ParseCursor_skip_space(cur)
    let start = c.pos
    let mut next = c
    let mut ch = ParseCursor_peek(next)
    while ch != 0 {
        let mut ok = 0
        if kind == 1 {
            if ch >= 48 && ch <= 57 {
                ok = 1
            }
        } else {
            if (ch >= 65 && ch <= 90) || (ch >= 97 && ch <= 122) || ch == 95 {
                ok = 1
            }
            if ch >= 48 && ch <= 57 {
                ok = 1
            }
        }
        if ok == 0 {
            break
        }
        next = ParseCursor_advance(next)
        ch = ParseCursor_peek(next)
    }
    if next.pos == start {
        return ""
    }
    let value = substring(c.text, start, next.pos - start)
    return ParseOk_pack(value, next)
}

fn Comb_ok_value(packed){
    let p = strstr_pos(packed, "|")
    if p < 0 {
        return packed
    }
    return substring(packed, 0, p)
}

fn Comb_ok_pos(packed){
    let p = strstr_pos(packed, "|")
    if p < 0 {
        return 0
    }
    let tail = substring(packed, p + 1, strlen(packed) - p - 1)
    let p2 = strstr_pos(tail, "|")
    if p2 < 0 {
        return str_to_i32(tail)
    }
    return str_to_i32(substring(tail, 0, p2))
}

fn Comb_many(cur, kind){
    let mut c = cur
    let mut out = StrVec_new()
    let mut part = Comb_take_while(c, kind)
    while strlen(part) > 0 {
        out = out.push(Comb_ok_value(part))
        c = ParseCursor { text: c.text, pos: Comb_ok_pos(part), loc: c.loc }
        part = Comb_take_while(c, kind)
    }
    return out
}

fn Comb_or_literal(cur, a, b){
    let left = Comb_literal(cur, a)
    if strlen(left) > 0 {
        return left
    }
    return Comb_literal(cur, b)
}

fn Comb_or_take(cur, kind_a, kind_b){
    let left = Comb_take_while(cur, kind_a)
    if strlen(left) > 0 {
        return left
    }
    return Comb_take_while(cur, kind_b)
}

fn Comb_or(cur, a, b){
    return Comb_or_literal(cur, a, b)
}
