//! Parse `//~` and file-level directives from Nyra test sources.

use std::path::Path;

/// Expected diagnostic on a specific source line.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ExpectedDiag {
    pub line: usize,
    pub kind: DiagKind,
    pub pattern: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DiagKind {
    Error,
    Warning,
}

/// File-level directives parsed from comments.
#[derive(Debug, Clone, Default)]
pub struct FileDirectives {
    pub expected: Vec<ExpectedDiag>,
    pub run_stdout: Option<String>,
    pub ignore: bool,
    pub tier: Option<String>,
}

/// Walk `source` and collect `//~ ERROR` / `//~ WARNING` directives.
pub fn parse_directives(source: &str) -> FileDirectives {
    let mut out = FileDirectives::default();
    for (idx, line) in source.lines().enumerate() {
        let line_no = idx + 1;
        let trimmed = line.trim();
        if let Some(rest) = trimmed.strip_prefix("// run-stdout:") {
            let line = rest.trim().to_string();
            out.run_stdout = Some(match out.run_stdout.take() {
                Some(prev) => format!("{prev}\n{line}"),
                None => line,
            });
            continue;
        }
        if let Some(rest) = trimmed.strip_prefix("// ignore-test") {
            if rest.is_empty() || rest.starts_with(char::is_whitespace) {
                out.ignore = true;
            }
            continue;
        }
        if let Some(rest) = trimmed.strip_prefix("// tier:") {
            out.tier = Some(rest.trim().to_string());
            continue;
        }
        if let Some(pos) = trimmed.find("//~") {
            let after = trimmed[pos + 3..].trim();
            let (kind, pattern) = if let Some(p) = after.strip_prefix("ERROR") {
                (DiagKind::Error, p.trim().to_string())
            } else if let Some(p) = after.strip_prefix("WARNING") {
                (DiagKind::Warning, p.trim().to_string())
            } else {
                continue;
            };
            if !pattern.is_empty() {
                out.expected.push(ExpectedDiag {
                    line: line_no,
                    kind,
                    pattern,
                });
            } else {
                out.expected.push(ExpectedDiag {
                    line: line_no,
                    kind,
                    pattern: String::new(),
                });
            }
        }
    }
    out
}

/// Path to optional golden stderr file adjacent to a `.ny` test.
pub fn stderr_path(test: &Path) -> std::path::PathBuf {
    test.with_extension("stderr")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_error_directive() {
        let src = r#"fn main() {
    let x = 1
    x = 2 //~ ERROR cannot assign
}"#;
        let d = parse_directives(src);
        assert_eq!(d.expected.len(), 1);
        assert_eq!(d.expected[0].line, 3);
        assert_eq!(d.expected[0].pattern, "cannot assign");
    }

    #[test]
    fn parses_run_stdout() {
        let src = "// run-stdout: 42\nfn main() { print(42) }";
        let d = parse_directives(src);
        assert_eq!(d.run_stdout.as_deref(), Some("42"));
    }

    #[test]
    fn parses_multiline_run_stdout() {
        let src = "// run-stdout: 1\n// run-stdout: 2\n// run-stdout: 3\nfn main() {}";
        let d = parse_directives(src);
        assert_eq!(d.run_stdout.as_deref(), Some("1\n2\n3"));
    }
}
