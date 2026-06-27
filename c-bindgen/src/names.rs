//! Sanitize C identifiers for valid Nyra parameter / field names.

/// Nyra keywords and type names that cannot be used as bare identifiers.
const NYRA_RESERVED: &[&str] = &[
    "let", "mut", "fn", "if", "else", "while", "return", "true", "false", "print", "import",
    "module", "struct", "impl", "self", "for", "const", "extern", "export", "inst", "enum",
    "match", "spawn", "in", "test", "async", "await", "trait", "macro", "defer", "unsafe", "asm",
    "as", "move", "clone", "void", "bool", "string", "ptr", "char", "type", "out",
    "i8", "i16", "i32", "i64", "i128", "u8", "u16", "u32", "u64", "u128", "isize", "usize", "f64",
];

/// Normalize a C parameter or field name for Nyra source.
/// Illegal characters become `_`; reserved words get a trailing `_`.
pub fn sanitize_identifier(name: &str) -> String {
    let mut out = String::new();
    for (i, c) in name.chars().enumerate() {
        if i == 0 && c.is_ascii_digit() {
            out.push('_');
        }
        if c.is_ascii_alphanumeric() || c == '_' {
            out.push(c);
        } else {
            out.push('_');
        }
    }
    if out.is_empty() {
        out.push_str("arg");
    }
    if is_nyra_reserved(&out) {
        out.push('_');
    }
    out
}

fn is_nyra_reserved(name: &str) -> bool {
    NYRA_RESERVED
        .iter()
        .any(|kw| name.eq_ignore_ascii_case(kw))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn escapes_in_keyword() {
        assert_eq!(sanitize_identifier("in"), "in_");
        assert_eq!(sanitize_identifier("out"), "out_");
        assert_eq!(sanitize_identifier("type"), "type_");
    }

    #[test]
    fn keeps_normal_names() {
        assert_eq!(sanitize_identifier("width"), "width");
        assert_eq!(sanitize_identifier("destLen"), "destLen");
    }
}
