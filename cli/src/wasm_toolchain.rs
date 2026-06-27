//! Auto-detect wasm32-wasip1 link deps (Homebrew llvm/lld, wasi-libc sysroot).

use std::path::PathBuf;
use std::process::Command;

use crate::llvm_tools::{self, find_wasm_ld};
use crate::target::detect_wasi_sysroot;

const LLVM_BIN_DIRS: &[&str] = &[
    "/opt/homebrew/opt/llvm/bin",
    "/usr/local/opt/llvm/bin",
];

const LLD_BIN_DIRS: &[&str] = &[
    "/opt/homebrew/opt/lld/bin",
    "/usr/local/opt/lld/bin",
];

/// Prepend LLVM/lld bins to `PATH` and set `NYRA_WASI_SYSROOT` when building for Wasm.
pub fn prepare_wasm_toolchain() -> Result<(), String> {
    prepend_toolchain_bins_to_path()?;
    ensure_wasi_sysroot_env()?;
    verify_wasm_linker()?;
    Ok(())
}

fn prepend_toolchain_bins_to_path() -> Result<(), String> {
    let mut prepend = Vec::new();
    for dir in LLVM_BIN_DIRS {
        let p = PathBuf::from(dir);
        if p.join("clang").is_file() && !prepend.iter().any(|d: &PathBuf| d == &p) {
            prepend.push(p);
        }
    }
    for dir in LLD_BIN_DIRS {
        let p = PathBuf::from(dir);
        if p.join("wasm-ld").is_file() && !prepend.iter().any(|d: &PathBuf| d == &p) {
            prepend.push(p);
        }
    }
    if let Some(ref bin_dir) = llvm_tools::toolchain_info().llvm_bin_dir {
        if bin_dir.is_dir() && !prepend.iter().any(|d| d == bin_dir) {
            prepend.push(bin_dir.clone());
        }
    }
    if prepend.is_empty() {
        return Ok(());
    }
    let current = std::env::var("PATH").unwrap_or_default();
    let prefix = prepend
        .iter()
        .map(|p| p.to_string_lossy().into_owned())
        .collect::<Vec<_>>()
        .join(":");
    std::env::set_var("PATH", format!("{prefix}:{current}"));
    Ok(())
}

fn ensure_wasi_sysroot_env() -> Result<(), String> {
    let has_sysroot = std::env::var("NYRA_WASI_SYSROOT")
        .ok()
        .is_some_and(|s| !s.trim().is_empty())
        || std::env::var("NYRA_SYSROOT")
            .ok()
            .is_some_and(|s| !s.trim().is_empty());
    if has_sysroot {
        return Ok(());
    }
    if let Some(root) = detect_wasi_sysroot() {
        std::env::set_var("NYRA_WASI_SYSROOT", root.as_os_str());
        eprintln!(
            "wasm: using WASI sysroot {} (override with NYRA_WASI_SYSROOT)",
            root.display()
        );
    }
    Ok(())
}

fn verify_wasm_linker() -> Result<(), String> {
    if find_wasm_ld().is_some() {
        return Ok(());
    }
    if Command::new("wasm-ld")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
    {
        return Ok(());
    }
    Err(format!(
        "wasm link requires wasm-ld (lld).\n\
         Install: brew install llvm lld wasi-libc  (macOS)\n\
         Or: apt install clang lld wasi-libc  (Debian/Ubuntu)\n\
         Then re-run, or set NYRA_LLVM_BIN to LLVM's bin directory."
    ))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ensure_wasi_sysroot_does_not_panic() {
        let _ = ensure_wasi_sysroot_env();
    }
}
