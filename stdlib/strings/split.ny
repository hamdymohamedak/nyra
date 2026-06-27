import "../strings.ny"
import "../vec_str.ny"

fn Split_is_space(c){
    if c == 32 || c == 9 || c == 10 || c == 13 {
        return 1
    }
    return 0
}

fn Split_push(out, part){
    return out.push(part)
}

fn Split_split_bytes(text, sep){
    let len = strlen(text)
    let sep_len = strlen(sep)
    let mut out = StrVec_new()
    if sep_len == 0 {
        return out.push(text)
    }
    let mut i = 0
    let mut start = 0
    while i < len {
        let mut matched = 1
        let mut j = 0
        while j < sep_len {
            if i + j >= len {
                matched = 0
                break
            }
            if char_at(text, i + j) != char_at(sep, j) {
                matched = 0
                break
            }
            j = j + 1
        }
        if matched == 1 {
            out = out.push(substring(text, start, i - start))
            i = i + sep_len
            start = i
        } else {
            i = i + 1
        }
    }
    out = out.push(substring(text, start, len - start))
    return out
}

fn Split_in_quotes(text, pos, quote){
    let len = strlen(text)
    if pos >= len {
        return 0
    }
    if char_at(text, pos) != quote {
        return 0
    }
    let mut i = pos + 1
    while i < len {
        let c = char_at(text, i)
        if c == 92 {
            i = i + 1
        } else {
            if c == quote {
                return 1
            }
        }
        i = i + 1
    }
    return 0
}

fn Split_split_respecting_quotes(text, sep, quote){
    let len = strlen(text)
    let sep_len = strlen(sep)
    let mut out = StrVec_new()
    let mut i = 0
    let mut start = 0
    let mut in_quote = 0
    while i < len {
        let c = char_at(text, i)
        if in_quote == 0 && c == quote {
            in_quote = 1
            i = i + 1
        } else {
            if in_quote == 1 {
                if c == 92 {
                    i = i + 2
                } else {
                    if c == quote {
                        in_quote = 0
                    }
                    i = i + 1
                }
            } else {
                let mut matched = 1
                let mut j = 0
                while j < sep_len {
                    if i + j >= len || char_at(text, i + j) != char_at(sep, j) {
                        matched = 0
                        break
                    }
                    j = j + 1
                }
                if matched == 1 {
                    out = out.push(substring(text, start, i - start))
                    i = i + sep_len
                    start = i
                } else {
                    i = i + 1
                }
            }
        }
    }
    out = out.push(substring(text, start, len - start))
    return out
}

fn String_split_safe(text, sep){
    return Split_split_bytes(text, sep)
}

fn String_split_quoted(text, sep){
    return Split_split_respecting_quotes(text, sep, 34)
}
