import "../strings.ny"

fn utf8_codepoint_at(s, byte_pos){
    let len = strlen(s)
    if byte_pos < 0 || byte_pos >= len {
        return -1
    }
    let b0 = char_at(s, byte_pos)
    if b0 < 128 {
        return b0
    }
    if b0 >= 192 && b0 <= 223 {
        if byte_pos + 1 >= len {
            return -1
        }
        let b1 = char_at(s, byte_pos + 1)
        if b1 < 128 || b1 > 191 {
            return -1
        }
        return (b0 - 192) * 64 + (b1 - 128)
    }
    if b0 >= 224 && b0 <= 239 {
        if byte_pos + 2 >= len {
            return -1
        }
        let b1 = char_at(s, byte_pos + 1)
        let b2 = char_at(s, byte_pos + 2)
        if b1 < 128 || b1 > 191 || b2 < 128 || b2 > 191 {
            return -1
        }
        return (b0 - 224) * 4096 + (b1 - 128) * 64 + (b2 - 128)
    }
    if b0 >= 240 && b0 <= 244 {
        if byte_pos + 3 >= len {
            return -1
        }
        let b1 = char_at(s, byte_pos + 1)
        let b2 = char_at(s, byte_pos + 2)
        let b3 = char_at(s, byte_pos + 3)
        if b1 < 128 || b1 > 191 || b2 < 128 || b2 > 191 || b3 < 128 || b3 > 191 {
            return -1
        }
        return (b0 - 240) * 262144 + (b1 - 128) * 4096 + (b2 - 128) * 64 + (b3 - 128)
    }
    return -1
}

fn utf8_next_index(s, byte_pos){
    let len = strlen(s)
    if byte_pos < 0 || byte_pos >= len {
        return byte_pos
    }
    let b0 = char_at(s, byte_pos)
    if b0 < 128 {
        return byte_pos + 1
    }
    if b0 >= 192 && b0 <= 223 {
        return byte_pos + 2
    }
    if b0 >= 224 && b0 <= 239 {
        return byte_pos + 3
    }
    if b0 >= 240 && b0 <= 244 {
        return byte_pos + 4
    }
    return byte_pos + 1
}

fn utf8_codepoint_count(s){
    let len = strlen(s)
    let mut i = 0
    let mut n = 0
    while i < len {
        i = utf8_next_index(s, i)
        n = n + 1
    }
    return n
}

fn utf8_is_ascii_code(cp){
    if cp >= 0 && cp < 128 {
        return 1
    }
    return 0
}

fn char_is_ascii(c){
    if c < 128 {
        return 1
    }
    return 0
}

fn utf8_char_at(s, codepoint_index){
    let len = strlen(s)
    let mut i = 0
    let mut n = 0
    while i < len {
        if n == codepoint_index {
            return utf8_codepoint_at(s, i)
        }
        i = utf8_next_index(s, i)
        n = n + 1
    }
    return -1
}
