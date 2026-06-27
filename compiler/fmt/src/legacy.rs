//! Line-based formatter fallback when AST parse fails.

const KEYWORDS: &[&str] = &[
    "fn", "let", "mut", "const", "if", "else", "while", "for", "return", "struct", "enum",
    "match", "impl", "import", "module", "extern", "export", "spawn", "print", "in",
];

pub fn format_source_line_based(src: &str) -> String {
    let mut out = String::new();
    let mut indent: usize = 0;
    let mut prev_was_toplevel = false;
    for line in src.lines() {
        let trimmed = line.trim();
        if trimmed.is_empty() {
            out.push('\n');
            continue;
        }
        if trimmed.starts_with('}')
            || trimmed == "else"
            || trimmed.starts_with("else ")
        {
            indent = indent.saturating_sub(1);
        }
        for _ in 0..indent {
            out.push_str("    ");
        }
        let is_toplevel = trimmed.starts_with("fn ")
            || trimmed.starts_with("test fn ")
            || trimmed.starts_with("struct ")
            || trimmed.starts_with("enum ")
            || trimmed.starts_with("impl ")
            || trimmed.starts_with("extern ")
            || trimmed.starts_with("const ")
            || trimmed.starts_with("import ")
            || trimmed.starts_with("module ");
        if is_toplevel && prev_was_toplevel && !out.is_empty() && !out.ends_with("\n\n") {
            out.push('\n');
        }
        let formatted = format_line_tokens(trimmed);
        out.push_str(&formatted);
        out.push('\n');
        prev_was_toplevel = is_toplevel;
        if trimmed.ends_with('{')
            || trimmed == "else"
            || trimmed.starts_with("else ")
        {
            indent += 1;
        }
    }
    if !out.ends_with('\n') {
        out.push('\n');
    }
    out
}

fn format_line_tokens(line: &str) -> String {
    let mut out = String::new();
    let mut i = 0;
    let chars: Vec<char> = line.chars().collect();
    while i < chars.len() {
        if chars[i].is_whitespace() {
            if !out.is_empty() && !out.ends_with(' ') {
                out.push(' ');
            }
            i += 1;
            continue;
        }
        if i + 1 < chars.len() && chars[i] == '-' && chars[i + 1] == '>' {
            out.push_str(" -> ");
            i += 2;
            continue;
        }
        if i + 1 < chars.len() && chars[i] == '=' && chars[i + 1] == '>' {
            out.push_str(" => ");
            i += 2;
            continue;
        }
        if chars[i].is_ascii_alphanumeric() || chars[i] == '_' {
            let start = i;
            i += 1;
            while i < chars.len() && (chars[i].is_ascii_alphanumeric() || chars[i] == '_') {
                i += 1;
            }
            let word: String = chars[start..i].iter().collect();
            if KEYWORDS.contains(&word.as_str()) {
                if !out.is_empty() && !out.ends_with(' ') {
                    out.push(' ');
                }
                out.push_str(&word);
                out.push(' ');
            } else {
                if !out.is_empty() && !out.ends_with(' ') && !out.ends_with('(') {
                    out.push(' ');
                }
                out.push_str(&word);
            }
            continue;
        }
        if !out.is_empty() && !out.ends_with(' ') {
            out.push(' ');
        }
        out.push(chars[i]);
        if matches!(chars[i], '(' | '{' | '[') {
        } else if matches!(chars[i], ')' | '}' | ']' | ',') {
        } else {
            out.push(' ');
        }
        i += 1;
    }
    out.trim().to_string()
}
