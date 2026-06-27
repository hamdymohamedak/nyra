use std::path::{Path, PathBuf};

use compiler::{CompileOptions, CompileStage, Compiler};
use errors::diagnostics_to_json;

use crate::app::args::StabilityFlags;

pub(crate) fn path_or_file(p: &Path) -> PathBuf {
    p.to_path_buf()
}

pub(crate) fn diag(path: &Path, json: bool, stability: &StabilityFlags) -> Result<(), String> {
    let options = CompileOptions {
        stop_after: Some(CompileStage::Borrow),
        deny_extended: stability.deny_extended,
        deny_warnings: stability.deny_warnings,
        ..CompileOptions::default()
    };
    let output = if path.is_dir() {
        Compiler::compile_project(path, &options)?
    } else {
        Compiler::compile_file(path, &options)?
    };
    if json {
        let mut all = Vec::new();
        for e in output
            .warnings
            .iter()
            .chain(&output.load_errors)
            .chain(&output.lexer_errors)
            .chain(&output.parser_errors)
            .chain(&output.type_errors)
            .chain(&output.borrow_errors)
        {
            all.push(e);
        }
        let owned: Vec<_> = all.into_iter().cloned().collect();
        println!(
            "{}",
            diagnostics_to_json(&owned).map_err(|e| e.to_string())?
        );
        return Ok(());
    }
    if Compiler::report_errors(&output) {
        return Err("diagnostics found".into());
    }
    println!("diag: {} — ok", path.display());
    Ok(())
}

pub(crate) fn check(path: &Path, stability: &StabilityFlags) -> Result<(), String> {
    let options = CompileOptions {
        stop_after: Some(CompileStage::Borrow),
        deny_extended: stability.deny_extended,
        deny_warnings: stability.deny_warnings,
        ..CompileOptions::default()
    };
    let output = if path.is_dir() {
        Compiler::compile_project(path, &options)?
    } else {
        Compiler::compile_file(path, &options)?
    };
    if Compiler::report_errors(&output) {
        return Err("check failed".into());
    }
    println!("check: {} — ok", path.display());
    Ok(())
}
