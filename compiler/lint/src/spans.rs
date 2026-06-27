/// Insert `_` before the identifier at a 1-indexed column on one line.
pub fn prefix_binding_on_line(line: &str, col: usize) -> Option<String> {
    let idx = col.saturating_sub(1);
    if idx >= line.len() {
        return None;
    }
    let rest = &line[idx..];
    if !rest
        .chars()
        .next()
        .is_some_and(|c| c.is_ascii_alphabetic() || c == '_')
    {
        return None;
    }
    if idx > 0 && line.as_bytes()[idx - 1] == b'_' {
        return None;
    }
    let mut out = String::new();
    out.push_str(&line[..idx]);
    out.push('_');
    out.push_str(rest);
    Some(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn remove_line(source: &str, line: usize) -> String {
        let mut out = String::new();
        for (i, text) in source.lines().enumerate() {
            if i + 1 == line {
                continue;
            }
            out.push_str(text);
            out.push('\n');
        }
        out
    }

    #[test]
    fn removes_import_line() {
        let src = "import \"a.ny\"\n\nfn main() {}\n";
        assert_eq!(remove_line(src, 1), "\nfn main() {}\n");
    }

    #[test]
    fn prefixes_binding_name() {
        let line = "    let dead = 42";
        assert_eq!(
            prefix_binding_on_line(line, 9),
            Some("    let _dead = 42".into())
        );
    }
}
