//! Parse LLDB/GDB text output into structured debug data.

#[derive(Debug, Clone)]
pub struct StackFrame {
    pub id: i64,
    pub name: String,
    pub file: Option<String>,
    pub line: i64,
    pub column: i64,
}

#[derive(Debug, Clone)]
pub struct Variable {
    pub name: String,
    pub value: String,
    pub type_name: Option<String>,
}

#[derive(Debug, Clone)]
pub struct BreakpointHit {
    pub id: i64,
    pub verified: bool,
    pub line: i64,
}

/// Parse `thread backtrace` output (LLDB or GDB).
pub fn parse_backtrace(output: &str) -> Vec<StackFrame> {
    let mut frames = Vec::new();
    for line in output.lines() {
        let trimmed = line.trim();
        if !trimmed.contains("frame #") {
            continue;
        }
        let Some(rest) = trimmed.strip_prefix('*').map(str::trim).or(Some(trimmed)) else {
            continue;
        };
        let Some(idx_end) = rest.find(':') else { continue };
        let header = &rest[..idx_end];
        let body = rest[idx_end + 1..].trim();

        let level = header
            .strip_prefix("frame #")
            .and_then(|s| s.split_whitespace().next())
            .and_then(|s| s.parse::<i64>().ok())
            .unwrap_or(frames.len() as i64);

        let (name, file, line, column) = parse_frame_body(body);
        frames.push(StackFrame {
            id: level + 1,
            name,
            file,
            line,
            column,
        });
    }
    frames
}

fn parse_frame_body(body: &str) -> (String, Option<String>, i64, i64) {
    // `0x... nyra_dbg_test`main at hello.ny:3:5`
    // `0x... nyra_dbg_test`main`
    if let Some(at_pos) = body.rfind(" at ") {
        let loc = &body[at_pos + 4..];
        let func = body[..at_pos]
            .split('`')
            .nth(1)
            .or_else(|| body.split_whitespace().nth(1))
            .unwrap_or("?")
            .trim_matches('`')
            .to_string();
        let (file, line, col) = parse_source_location(loc);
        return (func, file, line, col);
    }
    let name = body
        .split('`')
        .nth(1)
        .or_else(|| body.split_whitespace().nth(1))
        .unwrap_or("?")
        .trim_matches('`')
        .to_string();
    (name, None, 1, 1)
}

fn parse_source_location(loc: &str) -> (Option<String>, i64, i64) {
    // file.ny:line[:col]
    let mut parts = loc.split(':');
    let file = parts.next().map(|s| s.trim().to_string());
    let line = parts
        .next()
        .and_then(|s| s.parse().ok())
        .unwrap_or(1);
    let col = parts.next().and_then(|s| s.parse().ok()).unwrap_or(1);
    (file, line, col)
}

/// Parse `frame variable` (LLDB) output.
pub fn parse_lldb_variables(output: &str) -> Vec<Variable> {
    let mut vars = Vec::new();
    for line in output.lines() {
        let t = line.trim();
        if t.is_empty() || t.starts_with("(lldb)") || t.starts_with('*') || t.starts_with("frame #") {
            continue;
        }
        if t.starts_with('(') && !t.contains(" = ") {
            continue;
        }
        if let Some((name, value)) = t.split_once(" = ") {
            vars.push(Variable {
                name: name.trim().to_string(),
                value: value.trim().to_string(),
                type_name: None,
            });
        }
    }
    vars
}

/// Parse GDB MI `stack-list-variables` or `stack-list-frames` variable list.
pub fn parse_gdb_variables(output: &str) -> Vec<Variable> {
    let mut vars = Vec::new();
    for segment in output.split("variable=") {
        if !segment.contains("name=") {
            continue;
        }
        let name = extract_quoted(segment, "name").unwrap_or_default();
        if name.is_empty() {
            continue;
        }
        let value = extract_quoted(segment, "value").unwrap_or_else(|| "?".into());
        let type_name = extract_quoted(segment, "type");
        vars.push(Variable {
            name,
            value,
            type_name,
        });
    }
    vars
}

pub fn extract_quoted(s: &str, key: &str) -> Option<String> {
    let needle = format!("{key}=\"");
    let start = s.find(&needle)? + needle.len();
    let rest = &s[start..];
    let end = rest.find('"')?;
    Some(rest[..end].to_string())
}

pub fn output_indicates_stopped(output: &str) -> bool {
    output.contains("Process") && output.contains("stopped")
        || output.contains("stop reason")
        || output.contains("*stopped")
}

pub fn output_indicates_exited(output: &str) -> bool {
    output.contains("Process exited")
        || output.contains("exited with status")
        || output.contains("reason=\"exited")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_lldb_backtrace() {
        let out = r#"* thread #1, stop reason = breakpoint 1.1
  * frame #0: 0x100000548 nyra_dbg_test`main
    frame #1: 0x187cbab98 dyld`start + 6076"#;
        let frames = parse_backtrace(out);
        assert_eq!(frames.len(), 2);
        assert_eq!(frames[0].name, "main");
    }

    #[test]
    fn parse_backtrace_with_source() {
        let out = "  * frame #0: 0x100 demo`main at hello.ny:3:5";
        let frames = parse_backtrace(out);
        assert_eq!(frames[0].file.as_deref(), Some("hello.ny"));
        assert_eq!(frames[0].line, 3);
    }

    #[test]
    fn parse_lldb_vars() {
        let out = "(lldb) frame variable\n(int) i = 42\n(int) sum = 0";
        let vars = parse_lldb_variables(out);
        assert_eq!(vars.len(), 2);
        assert_eq!(vars[0].name, "(int) i");
    }
}
