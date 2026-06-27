//! Preserve full-line `//` comments when formatting.

/// Re-insert standalone comment lines from `original` into `formatted`.
pub fn merge_comments(original: &str, formatted: &str) -> String {
    let anchors = comment_anchors(original);
    if anchors.is_empty() {
        return formatted.to_string();
    }
    let mut out_lines: Vec<String> = formatted.lines().map(str::to_string).collect();
    for (comment, following) in anchors {
        if out_lines.iter().any(|l| l.trim() == comment.trim()) {
            continue;
        }
        let insert_at = out_lines
            .iter()
            .position(|l| l.trim_start().starts_with(&following))
            .unwrap_or(out_lines.len());
        out_lines.insert(insert_at, comment);
    }
    let mut out = out_lines.join("\n");
    if original.ends_with('\n') && !out.ends_with('\n') {
        out.push('\n');
    }
    out
}

/// Pairs of `(comment line, first token on next non-comment line)` for anchoring.
fn comment_anchors(source: &str) -> Vec<(String, String)> {
    let lines: Vec<&str> = source.lines().collect();
    let mut out = Vec::new();
    let mut i = 0;
    while i < lines.len() {
        let trimmed = lines[i].trim();
        if trimmed.starts_with("//") {
            let comment = lines[i].to_string();
            let mut j = i + 1;
            while j < lines.len() && lines[j].trim().is_empty() {
                j += 1;
            }
            let following = lines
                .get(j)
                .map(|l| l.trim().split_whitespace().next().unwrap_or("").to_string())
                .unwrap_or_default();
            if !following.is_empty() {
                out.push((comment, following));
            }
            i = j;
        } else {
            i += 1;
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn merges_comment_before_fn() {
        let orig = "// greet helper\nfn main() {}\n";
        let fmt = "fn main() {\n}\n";
        let merged = merge_comments(orig, fmt);
        assert!(merged.contains("// greet helper"));
        assert!(merged.contains("fn main()"));
    }
}
