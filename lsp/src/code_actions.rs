//! Quick-fix code actions from compiler `help:` suggestions.

use errors::NyraError;
use tower_lsp::lsp_types::{
    CodeAction, CodeActionKind, CodeActionOrCommand, Diagnostic, Range, TextEdit, Url, WorkspaceEdit,
};

pub fn code_actions_for_diagnostics(
    uri: &Url,
    diagnostics: &[Diagnostic],
) -> Vec<CodeActionOrCommand> {
    let mut out = Vec::new();
    for diag in diagnostics {
        let Some(related) = &diag.related_information else {
            continue;
        };
        for info in related {
            let msg = &info.message;
            if let Some(action) = help_to_action(uri, diag.range, msg) {
                out.push(CodeActionOrCommand::CodeAction(action));
            }
        }
    }
    out
}

pub fn code_actions_from_errors(uri: &Url, errors: &[NyraError]) -> Vec<CodeActionOrCommand> {
    use crate::diagnostics::diagnostic_from_error;
    let diags: Vec<Diagnostic> = errors
        .iter()
        .map(|e| diagnostic_from_error(e, tower_lsp::lsp_types::DiagnosticSeverity::ERROR))
        .collect();
    code_actions_for_diagnostics(uri, &diags)
}

fn help_to_action(uri: &Url, range: Range, message: &str) -> Option<CodeAction> {
    let help = message.strip_prefix("help: ")?;
    let (title, edit_text) = parse_help_fix(help)?;
    Some(CodeAction {
        title,
        kind: Some(CodeActionKind::QUICKFIX),
        diagnostics: None,
        edit: Some(WorkspaceEdit {
            changes: Some(std::collections::HashMap::from([(
                uri.clone(),
                vec![TextEdit {
                    range,
                    new_text: edit_text,
                }],
            )])),
            ..Default::default()
        }),
        ..Default::default()
    })
}

fn parse_help_fix(help: &str) -> Option<(String, String)> {
    if let Some(rest) = help.strip_prefix("borrow instead: ") {
        return Some(("Apply borrow suggestion".into(), rest.to_string()));
    }
    if let Some(rest) = help.strip_prefix("or duplicate: ") {
        return Some(("Apply clone suggestion".into(), rest.to_string()));
    }
    if let Some(rest) = help.strip_prefix("use `") {
        if let Some(code) = rest.strip_suffix('`') {
            return Some(("Apply suggested fix".into(), code.to_string()));
        }
    }
    if help.contains("clone") && help.contains(':') {
        if let Some((_, code)) = help.split_once(':') {
            let code = code.trim();
            if !code.is_empty() {
                return Some(("Apply clone suggestion".into(), code.to_string()));
            }
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_borrow_help() {
        let (title, text) = parse_help_fix("borrow instead: save(&user)").unwrap();
        assert!(title.contains("borrow"));
        assert_eq!(text, "save(&user)");
    }
}
