/// Resolve a color spec (name, `#RGB`, `#RRGGBB`) to an ANSI SGR prefix.
pub fn color_spec_to_ansi(spec: &str) -> Option<String> {
    let spec = spec.trim();
    if spec.is_empty() {
        return None;
    }
    if let Some(hex) = spec.strip_prefix('#') {
        return parse_hex_color(hex);
    }
    if is_bare_hex(spec) {
        return parse_hex_color(spec);
    }
    if let Some(inner) = spec.strip_prefix("rgb(").and_then(|s| s.strip_suffix(')')) {
        return parse_rgb_fn(inner);
    }
    named_color_to_ansi(spec).map(str::to_string)
}

fn is_bare_hex(spec: &str) -> bool {
    matches!(spec.len(), 3 | 6) && spec.chars().all(|c| c.is_ascii_hexdigit())
}

fn parse_rgb_fn(inner: &str) -> Option<String> {
    let mut parts = inner.split(',').map(str::trim);
    let r: u8 = parts.next()?.parse().ok()?;
    let g: u8 = parts.next()?.parse().ok()?;
    let b: u8 = parts.next()?.parse().ok()?;
    Some(format!("\x1b[38;2;{r};{g};{b}m"))
}

fn parse_hex_color(hex: &str) -> Option<String> {
    let (r, g, b) = match hex.len() {
        3 => {
            let r = nybble(hex.as_bytes()[0])? * 17;
            let g = nybble(hex.as_bytes()[1])? * 17;
            let b = nybble(hex.as_bytes()[2])? * 17;
            (r, g, b)
        }
        6 => {
            let r = byte_hex(&hex[0..2])?;
            let g = byte_hex(&hex[2..4])?;
            let b = byte_hex(&hex[4..6])?;
            (r, g, b)
        }
        _ => return None,
    };
    Some(format!("\x1b[38;2;{r};{g};{b}m"))
}

fn nybble(c: u8) -> Option<u8> {
    match c {
        b'0'..=b'9' => Some(c - b'0'),
        b'a'..=b'f' => Some(c - b'a' + 10),
        b'A'..=b'F' => Some(c - b'A' + 10),
        _ => None,
    }
}

fn byte_hex(s: &str) -> Option<u8> {
    u8::from_str_radix(s, 16).ok()
}

fn named_color_to_ansi(name: &str) -> Option<&'static str> {
    let lower = name.to_ascii_lowercase();
    Some(match lower.as_str() {
        "reset" | "default" => "\x1b[0m",
        "black" => "\x1b[30m",
        "red" => "\x1b[31m",
        "green" => "\x1b[32m",
        "yellow" => "\x1b[33m",
        "blue" => "\x1b[34m",
        "magenta" | "purple" => "\x1b[35m",
        "cyan" => "\x1b[36m",
        "white" => "\x1b[37m",
        "bright_black" | "gray" | "grey" => "\x1b[90m",
        "bright_red" => "\x1b[91m",
        "bright_green" => "\x1b[92m",
        "bright_yellow" => "\x1b[93m",
        "bright_blue" => "\x1b[94m",
        "bright_magenta" | "bright_purple" => "\x1b[95m",
        "bright_cyan" => "\x1b[96m",
        "bright_white" => "\x1b[97m",
        "bold" => "\x1b[1m",
        "dim" => "\x1b[2m",
        "italic" => "\x1b[3m",
        "underline" => "\x1b[4m",
        _ => return None,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn named_red() {
        assert_eq!(color_spec_to_ansi("red"), Some("\x1b[31m".into()));
    }

    #[test]
    fn hex_six_digit() {
        assert_eq!(
            color_spec_to_ansi("#FF5733"),
            Some("\x1b[38;2;255;87;51m".into())
        );
    }

    #[test]
    fn hex_three_digit() {
        assert_eq!(
            color_spec_to_ansi("#F00"),
            Some("\x1b[38;2;255;0;0m".into())
        );
    }

    #[test]
    fn bare_hex_six_digit() {
        assert_eq!(
            color_spec_to_ansi("00FF00"),
            Some("\x1b[38;2;0;255;0m".into())
        );
    }

    #[test]
    fn octal_escape_equivalent() {
        assert_eq!(color_spec_to_ansi("red").unwrap(), "\x1b[31m");
    }
}
