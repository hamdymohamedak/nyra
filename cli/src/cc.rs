//! `nyra cc` — clang driver with Nyra toolchain discovery (zig cc–style foundation).
//!
//! Forwards to the same LLVM `clang` used by `nyra build`, optionally injecting
//! cross-target flags from `--for` / `--target`.

use std::process::Command;

use crate::app::args::TargetArgs;
use crate::llvm_tools::{self, print_toolchain_info};
use crate::target::{LinkTargetFlags, apply_target_link_flags};

fn target_args_active(args: &TargetArgs) -> bool {
    args.for_os.is_some()
        || args.os.is_some()
        || args.arch.is_some()
        || !args.target.is_empty()
}

/// Run `nyra cc` — exec clang with optional Nyra target flags prepended.
pub fn run_cc(
    target_args: &TargetArgs,
    print_toolchain: bool,
    verbose: bool,
    clang_args: &[String],
) -> Result<(), String> {
    if print_toolchain {
        print_toolchain_info();
        return Ok(());
    }

    let clang = llvm_tools::find_clang();
    let mut cmd = Command::new(&clang);

    if target_args_active(target_args) {
        let spec = target_args.resolve()?;
        if spec.is_wasm {
            crate::wasm_toolchain::prepare_wasm_toolchain()?;
        }
        apply_target_link_flags(&mut cmd, &spec, &LinkTargetFlags::default());
        if verbose {
            eprintln!(
                "nyra cc: target {} ({})",
                spec.triple_for_codegen(),
                if spec.is_cross { "cross" } else { "native" }
            );
        }
    }

    cmd.args(clang_args);

    if verbose {
        eprintln!("nyra cc: {}", format_command(&cmd));
    }

    let status = cmd.status().map_err(|e| format!("failed to run {clang}: {e}"))?;
    if status.success() {
        Ok(())
    } else {
        Err(format!(
            "nyra cc: clang exited with status {}",
            status.code().unwrap_or(-1)
        ))
    }
}

fn format_command(cmd: &Command) -> String {
    let mut parts = Vec::new();
    parts.push(
        cmd.get_program()
            .to_string_lossy()
            .into_owned(),
    );
    for arg in cmd.get_args() {
        parts.push(arg.to_string_lossy().into_owned());
    }
    parts.join(" ")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn inactive_target_args() {
        let args = TargetArgs::default();
        assert!(!target_args_active(&args));
    }
}
