import "../strings.ny"

// hex_encode_byte — two-char lowercase hex for 0..255 (MVP table lookup).
fn hex_digit(n: i32) -> string {
    if n < 10 {
        return i32_to_string(n)
    }
    if n == 10 {
        return "a"
    }
    if n == 11 {
        return "b"
    }
    if n == 12 {
        return "c"
    }
    if n == 13 {
        return "d"
    }
    if n == 14 {
        return "e"
    }
    return "f"
}

fn hex_encode_byte(b: i32) -> string {
    let hi = (b / 16) % 16
    let lo = b % 16
    return strcat(hex_digit(hi), hex_digit(lo))
}

// url_encode — percent-encode spaces only (MVP; full RFC in community packages).
fn url_encode(s: string) -> string {
    let pos = strstr_pos(s, " ")
    if pos < 0 {
        return s
    }
    let before = substring(s, 0, pos)
    let after = substring(s, pos + 1, strlen(s) - pos - 1)
    return strcat(strcat(strcat(before, "%20"), after), "")
}

fn url_decode(s: string) -> string {
    let pos = strstr_pos(s, "%20")
    if pos < 0 {
        return s
    }
    let before = substring(s, 0, pos)
    let after = substring(s, pos + 3, strlen(s) - pos - 3)
    return strcat(strcat(before, " "), after)
}

// base64_encode / base64_decode — see `encoding/base64.ny` (binary-safe decode).
import "base64.ny"

