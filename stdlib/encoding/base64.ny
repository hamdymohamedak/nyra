const B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

fn b64_lookup(c: i32) -> i32 {
    let mut i = 0
    while i < 64 {
        if char_at(B64, i) == c {
            return i
        }
        i = i + 1
    }
    return 0
}

fn b64_char(i: i32) -> string {
    return substring(B64, i, 1)
}

fn base64_encode(s: string) -> string {
    let len = strlen(s)
    let mut out = ""
    let mut i = 0
    while i < len {
        let a = char_at(s, i)
        let mut b = 0
        let mut c = 0
        if i + 1 < len {
            b = char_at(s, i + 1)
        }
        if i + 2 < len {
            c = char_at(s, i + 2)
        }
        let triple = (a << 16) | (b << 8) | c
        out = strcat(out, b64_char((triple >> 18) & 63))
        out = strcat(out, b64_char((triple >> 12) & 63))
        if i + 1 < len {
            out = strcat(out, b64_char((triple >> 6) & 63))
        } else {
            out = strcat(out, "=")
        }
        if i + 2 < len {
            out = strcat(out, b64_char(triple & 63))
        } else {
            out = strcat(out, "=")
        }
        i = i + 3
    }
    return out
}

// Decode Base64 into a byte string (each char code is one byte 0–255).
fn base64_decode(s: string) -> string {
    let len = strlen(s)
    let mut out = ""
    let mut i = 0
    while i < len {
        if char_at(s, i) == 61 {
            break
        }
        let a = b64_lookup(char_at(s, i))
        let mut b = 0
        let mut c = 0
        let mut d = 0
        if i + 1 < len {
            b = b64_lookup(char_at(s, i + 1))
        }
        if i + 2 < len && char_at(s, i + 2) != 61 {
            c = b64_lookup(char_at(s, i + 2))
        }
        if i + 3 < len && char_at(s, i + 3) != 61 {
            d = b64_lookup(char_at(s, i + 3))
        }
        let triple = (a << 18) | (b << 12) | (c << 6) | d
        let b0 = (triple >> 16) & 255
        out = str_push_char(out, b0)
        if i + 2 < len && char_at(s, i + 2) != 61 {
            let b1 = (triple >> 8) & 255
            out = str_push_char(out, b1)
        }
        if i + 3 < len && char_at(s, i + 3) != 61 {
            let b2 = triple & 255
            out = str_push_char(out, b2)
        }
        i = i + 4
    }
    return out
}
