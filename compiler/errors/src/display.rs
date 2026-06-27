use std::collections::BTreeMap;

use crate::color;
use crate::{display_path, NyraError};

/// Print diagnostics grouped by file with a summary line (errors before warnings).
pub fn print_diagnostics(errors: &[NyraError], suppressed: usize) {
    if errors.is_empty() && suppressed == 0 {
        return;
    }

    let mut err_items: Vec<_> = errors.iter().filter(|e| e.is_error()).cloned().collect();
    let mut warn_items: Vec<_> = errors.iter().filter(|e| !e.is_error()).cloned().collect();

    err_items.sort_by(|a, b| sort_key(a).cmp(&sort_key(b)));
    warn_items.sort_by(|a, b| sort_key(a).cmp(&sort_key(b)));

    if !err_items.is_empty() {
        print_grouped_by_file(&err_items);
    }
    if !warn_items.is_empty() {
        if !err_items.is_empty() {
            eprintln!();
        }
        print_grouped_by_file(&warn_items);
    }

    let error_count = err_items.len();
    let warning_count = warn_items.len();
    if error_count > 0 || warning_count > 0 || suppressed > 0 {
        print_summary(error_count, warning_count, suppressed);
    }
}

fn sort_key(e: &NyraError) -> (String, usize, usize) {
    (
        display_path(&e.span.file),
        e.span.start.line,
        e.span.start.column,
    )
}

fn print_grouped_by_file(items: &[NyraError]) {
    let mut by_file: BTreeMap<String, Vec<&NyraError>> = BTreeMap::new();
    for e in items {
        let key = display_path(&e.span.file);
        by_file.entry(key).or_default().push(e);
    }
    let mut first_file = true;
    for (file, group) in by_file {
        if !first_file {
            eprintln!();
        }
        first_file = false;
        let c = color::Colors::new();
        let count = group.len();
        let label = if group[0].is_error() {
            if count == 1 {
                c.error(&format!("in `{file}`: 1 error"))
            } else {
                c.error(&format!("in `{file}`: {count} errors"))
            }
        } else if count == 1 {
            c.warning(&format!("in `{file}`: 1 warning"))
        } else {
            c.warning(&format!("in `{file}`: {count} warnings"))
        };
        eprintln!("{label}");
        for e in group {
            eprintln!("{e}");
        }
    }
}

fn print_summary(errors: usize, warnings: usize, suppressed: usize) {
    let c = color::Colors::new();
    eprintln!();
    if errors > 0 {
        let msg = if errors == 1 {
            "could not compile due to 1 previous error".to_string()
        } else {
            format!("could not compile due to {errors} previous errors")
        };
        eprintln!("{}", c.error(&msg));
    }
    if suppressed > 0 {
        let msg = if suppressed == 1 {
            "1 more error suppressed — fix the errors above first".to_string()
        } else {
            format!("{suppressed} more errors suppressed — fix the errors above first")
        };
        eprintln!("   {} {}", c.note_label("= note:"), msg);
    }
    if warnings > 0 {
        let msg = if warnings == 1 {
            "1 warning emitted".to_string()
        } else {
            format!("{warnings} warnings emitted")
        };
        eprintln!("{}", c.warning(&msg));
    }
}
