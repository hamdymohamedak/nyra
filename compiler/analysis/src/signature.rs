//! Signature help: active call-site parameter info.

use crate::{DocumentAnalysis, SymbolKind};

#[derive(Debug, Clone)]
pub struct SignatureHelpInfo {
    pub label: String,
    pub parameters: Vec<String>,
    pub active_parameter: usize,
    pub documentation: Option<String>,
}

pub fn signature_help_at(
    source: &str,
    analysis: &DocumentAnalysis,
    line: u32,
    character: u32,
) -> Option<SignatureHelpInfo> {
    let line_text = source.lines().nth(line as usize)?;
    let col = (character as usize).min(line_text.len());
    let prefix = &line_text[..col];
    let open_paren = prefix.rfind('(')?;
    let callee_part = prefix[..open_paren].trim_end();
    let callee = callee_part
        .rsplit(|c: char| !c.is_ascii_alphanumeric() && c != '_')
        .next()?
        .to_string();
    if callee.is_empty() {
        return None;
    }
    let sym = analysis.symbols.iter().find(|s| {
        s.name == callee
            && matches!(
                s.kind,
                SymbolKind::Function | SymbolKind::Extern | SymbolKind::Method
            )
    })?;
    let detail = sym.detail.as_ref()?;
    let (params, active) = parse_call_context(prefix, open_paren, detail);
    Some(SignatureHelpInfo {
        label: detail.clone(),
        parameters: params,
        active_parameter: active,
        documentation: None,
    })
}

fn parse_call_context(prefix: &str, open_paren: usize, detail: &str) -> (Vec<String>, usize) {
    let after_paren = &prefix[open_paren + 1..];
    let commas = after_paren.matches(',').count();
    let params = extract_param_labels(detail);
    let active = commas.min(params.len().saturating_sub(1));
    (params, active)
}

fn extract_param_labels(detail: &str) -> Vec<String> {
    let inner = detail
        .strip_prefix("fn(")
        .and_then(|s| s.split(") ->").next())
        .unwrap_or("");
    if inner.trim().is_empty() {
        return vec![];
    }
    inner.split(',').map(|p| p.trim().to_string()).collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::DocumentAnalysis;

    #[test]
    fn signature_for_call() {
        let src = "fn add(a: i32, b: i32) -> i32 { a + b }\nfn main() { add(1, 2) }\n";
        let analysis = DocumentAnalysis::analyze(src, "t.ny");
        let help = signature_help_at(src, &analysis, 1, 17).expect("sig");
        assert!(help.label.contains("i32"));
        assert_eq!(help.parameters.len(), 2);
    }
}
