import "../strings.ny"
import "../strings/ops.ny"

fn utf8_valid(s: string) -> i32 {
    let n = strlen(s)
    let mut i = 0
    while i < n {
        let c = char_at(s, i)
        if c < 128 {
            i = i + 1
        } else {
            if c >= 194 && c <= 244 {
                i = i + 1
                if i >= n {
                    return 0
                }
                let c2 = char_at(s, i)
                if c2 < 128 || c2 > 191 {
                    return 0
                }
                i = i + 1
            } else {
                return 0
            }
        }
    }
    return 1
}

fn utf8_byte_len(s: string) -> i32 {
    return strlen(s)
}

fn utf8_starts_with_rune(s: string, prefix: string) -> i32 {
    return str_starts_with(s, prefix)
}
