// Redis RESP2 subset — encode/decode for simple strings, bulk strings, and arrays.

fn Resp_encode_simple(s) {
    return strcat("+", strcat(s, "\r\n"))
}

fn Resp_encode_error(s) {
    return strcat("-", strcat(s, "\r\n"))
}

fn Resp_encode_bulk(s) {
    let n = strlen(s)
    return strcat(strcat("$", strcat(i32_to_string(n), "\r\n")), strcat(s, "\r\n"))
}

fn Resp_encode_pong() {
    return Resp_encode_simple("PONG")
}

fn Resp_encode_nil() {
    return "$-1\r\n"
}

fn Resp_read_line(buf, pos) {
    let len = strlen(buf)
    let mut i = pos
    while i + 1 < len {
        if char_at(buf, i) == 13 && char_at(buf, i + 1) == 10 {
            let line = substring(buf, pos, i - pos)
            return strcat(line, strcat("|", i32_to_string(i + 2)))
        }
        i = i + 1
    }
    return ""
}

fn Resp_line_text(packed) {
    let p = strstr_pos(packed, "|")
    if p < 0 {
        return packed
    }
    return substring(packed, 0, p)
}

fn Resp_line_end(packed) {
    let p = strstr_pos(packed, "|")
    if p < 0 {
        return 0
    }
    return str_to_i32(substring(packed, p + 1, strlen(packed) - p - 1))
}

fn Resp_decode_bulk(buf, pos) {
    let head = Resp_read_line(buf, pos)
    if strlen(head) == 0 {
        return ""
    }
    let line = Resp_line_text(head)
    let next = Resp_line_end(head)
    if strstr_pos(line, "$-1") == 0 {
        return strcat("", strcat("|", i32_to_string(next)))
    }
    if char_at(line, 0) != 36 {
        return ""
    }
    let len = str_to_i32(substring(line, 1, strlen(line) - 1))
    if len < 0 {
        return ""
    }
    let body = substring(buf, next, len)
    return strcat(body, strcat("|", i32_to_string(next + len + 2)))
}

fn Resp_bulk_text(packed) {
    let p = strstr_pos(packed, "|")
    if p < 0 {
        return packed
    }
    return substring(packed, 0, p)
}

fn Resp_bulk_end(packed) {
    let p = strstr_pos(packed, "|")
    if p < 0 {
        return 0
    }
    return str_to_i32(substring(packed, p + 1, strlen(packed) - p - 1))
}

fn Resp_decode_array(buf, pos) {
    let head = Resp_read_line(buf, pos)
    if strlen(head) == 0 {
        return StrVec_new()
    }
    let line = Resp_line_text(head)
    let next = Resp_line_end(head)
    if char_at(line, 0) != 42 {
        return StrVec_new()
    }
    let count = str_to_i32(substring(line, 1, strlen(line) - 1))
    let mut out = StrVec_new()
    let mut i = 0
    let mut at = next
    while i < count {
        let part = Resp_decode_bulk(buf, at)
        out = out.push(Resp_bulk_text(part))
        at = Resp_bulk_end(part)
        i = i + 1
    }
    return out
}

fn Resp_cmd_name(args) {
    if args.len() == 0 {
        return ""
    }
    return str_to_upper(args.get(0))
}
