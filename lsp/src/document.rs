//! Incremental document edits and LSP position helpers.

use tower_lsp::lsp_types::{Position, Range, TextDocumentContentChangeEvent};

/// Apply LSP content changes to in-memory document text.
pub fn apply_changes(text: &mut String, changes: &[TextDocumentContentChangeEvent]) {
    for change in changes {
        if let Some(range) = change.range {
            let start = lsp_position_to_byte_offset(text, range.start);
            let end = lsp_position_to_byte_offset(text, range.end);
            if start <= end && end <= text.len() {
                text.replace_range(start..end, &change.text);
            }
        } else {
            *text = change.text.clone();
        }
    }
}

/// Convert an LSP position to a byte offset (UTF-16 code unit index, matching LSP spec).
pub fn lsp_position_to_byte_offset(source: &str, pos: Position) -> usize {
    let mut line = 0u32;
    let mut offset = 0usize;
    for line_text in source.split_inclusive('\n') {
        if line == pos.line {
            let line_body = line_text.strip_suffix('\n').unwrap_or(line_text);
            return offset + utf16_offset_to_byte(line_body, pos.character);
        }
        offset += line_text.len();
        line += 1;
    }
    if line == pos.line {
        return offset;
    }
    source.len()
}

fn utf16_offset_to_byte(text: &str, utf16_col: u32) -> usize {
    let mut utf16 = 0u32;
    for (byte, ch) in text.char_indices() {
        if utf16 >= utf16_col {
            return byte;
        }
        utf16 += ch.len_utf16() as u32;
    }
    text.len()
}

/// Full-document range for format/rename edits.
pub fn full_document_range(source: &str) -> Range {
    let line_count = source.lines().count().max(1);
    let last_line_len = source.lines().last().map(|l| l.chars().map(|c| c.len_utf16()).sum::<usize>()).unwrap_or(0);
    Range {
        start: Position { line: 0, character: 0 },
        end: Position {
            line: (line_count.saturating_sub(1)) as u32,
            character: last_line_len as u32,
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn apply_incremental_change() {
        let mut text = "fn main() {\n    print(1)\n}".to_string();
        let changes = vec![TextDocumentContentChangeEvent {
            range: Some(Range {
                start: Position { line: 1, character: 10 },
                end: Position { line: 1, character: 11 },
            }),
            range_length: None,
            text: "42".into(),
        }];
        apply_changes(&mut text, &changes);
        assert!(text.contains("print(42)"));
    }

    #[test]
    fn apply_full_replace() {
        let mut text = "old".to_string();
        let changes = vec![TextDocumentContentChangeEvent {
            range: None,
            range_length: None,
            text: "new".into(),
        }];
        apply_changes(&mut text, &changes);
        assert_eq!(text, "new");
    }
}
