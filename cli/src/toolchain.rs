//! Install / inspect the Nyra native toolchain (LLVM/clang layout under `$NYRA_HOME`).

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::llvm_tools::{self, toolchain_info};
use crate::target::detect_wasi_sysroot;

const LLVM_DOWNLOAD_VERSION: &str = "18.1.8";

/// Nyra install root: `$NYRA_HOME`, install-relative, or `~/.nyra`.
pub fn nyra_home() -> PathBuf {
    if let Ok(h) = std::env::var("NYRA_HOME") {
        let h = h.trim();
        if !h.is_empty() {
            return PathBuf::from(h);
        }
    }
    if let Ok(exe) = std::env::current_exe() {
        if let Some(bin) = exe.parent() {
            let root = bin.parent();
            if root.is_some_and(|r| r.join("share/stdlib").is_dir() || r.join("lib/llvm").is_dir()) {
                return root.unwrap().to_path_buf();
            }
        }
    }
    dirs::home_dir()
        .map(|h| h.join(".nyra"))
        .unwrap_or_else(|| PathBuf::from(".nyra"))
}

pub fn llvm_bin_dir(home: &Path) -> PathBuf {
    home.join("lib/llvm/bin")
}

pub fn wasi_sysroot_dir(home: &Path) -> PathBuf {
    home.join("lib/sysroot/wasi")
}

pub fn env_snippet(home: &Path) -> String {
    let llvm = llvm_bin_dir(home);
    let wasi = wasi_sysroot_dir(home);
    format!(
        r#"# Nyra native toolchain
export NYRA_HOME="{home}"
export NYRA_LLVM_BIN="{llvm}"
export NYRA_WASI_SYSROOT="{wasi}"
export PATH="${{NYRA_HOME}}/bin:${{NYRA_LLVM_BIN}}:${{PATH}}"
"#,
        home = home.display(),
        llvm = llvm.display(),
        wasi = wasi.display(),
    )
}

pub fn install_toolchain(download: bool, include_wasi: bool) -> Result<(), String> {
    let home = nyra_home();
    let bin_dir = llvm_bin_dir(&home);
    fs::create_dir_all(&bin_dir).map_err(|e| e.to_string())?;

    if download {
        download_llvm_toolchain(&bin_dir)?;
    } else {
        link_system_llvm(&bin_dir)?;
    }

    if include_wasi {
        install_wasi_sysroot(&home)?;
    }

    write_env_file(&home)?;
    eprintln!("toolchain: installed under {}", home.display());
    eprintln!("toolchain: add to shell — source \"{}/env\"", home.display());
    toolchain_info();
    Ok(())
}

fn link_system_llvm(dest_bin: &Path) -> Result<(), String> {
    let info = toolchain_info();
    let Some(ref src_dir) = info.llvm_bin_dir else {
        return Err(
            "no LLVM installation found (install brew install llvm, or use nyra toolchain install --download)"
                .into(),
        );
    };

    let tools = [
        "clang",
        "clang++",
        "clang-cpp",
        "opt",
        "llvm-opt",
        "llvm-profdata",
        "lld",
        "wasm-ld",
        "llvm-ar",
        "llvm-ranlib",
    ];

    let mut linked = 0usize;
    for name in tools {
        let src = src_dir.join(name);
        if !src.is_file() {
            continue;
        }
        let dest = dest_bin.join(name);
        let _ = fs::remove_file(&dest);
        symlink_or_copy(&src, &dest)?;
        linked += 1;
    }

    if linked == 0 {
        return Err(format!(
            "no LLVM tools linked from {}",
            src_dir.display()
        ));
    }

    eprintln!(
        "toolchain: linked {linked} tool(s) from {} → {}",
        src_dir.display(),
        dest_bin.display()
    );
    Ok(())
}

fn symlink_or_copy(src: &Path, dest: &Path) -> Result<(), String> {
    #[cfg(unix)]
    {
        std::os::unix::fs::symlink(src, dest).map_err(|e| {
            format!("symlink {} → {}: {e}", src.display(), dest.display())
        })
    }
    #[cfg(not(unix))]
    {
        fs::copy(src, dest).map_err(|e| format!("copy {}: {e}", src.display()))?;
        Ok(())
    }
}

fn install_wasi_sysroot(home: &Path) -> Result<(), String> {
    let Some(src) = detect_wasi_sysroot() else {
        eprintln!("toolchain: wasi-libc sysroot not found — skip (brew install wasi-libc)");
        return Ok(());
    };
    let dest = wasi_sysroot_dir(home);
    if dest.exists() {
        fs::remove_dir_all(&dest).ok();
    }
    fs::create_dir_all(dest.parent().unwrap()).map_err(|e| e.to_string())?;
    symlink_or_copy_dir(&src, &dest)?;
    eprintln!(
        "toolchain: WASI sysroot {} → {}",
        src.display(),
        dest.display()
    );
    Ok(())
}

fn symlink_or_copy_dir(src: &Path, dest: &Path) -> Result<(), String> {
    #[cfg(unix)]
    {
        std::os::unix::fs::symlink(src, dest).map_err(|e| {
            format!("symlink dir {} → {}: {e}", src.display(), dest.display())
        })
    }
    #[cfg(not(unix))]
    {
        copy_dir_recursive(src, dest)
    }
}

#[cfg(not(unix))]
fn copy_dir_recursive(src: &Path, dest: &Path) -> Result<(), String> {
    fs::create_dir_all(dest).map_err(|e| e.to_string())?;
    for entry in fs::read_dir(src).map_err(|e| e.to_string())? {
        let entry = entry.map_err(|e| e.to_string())?;
        let ty = entry.file_type().map_err(|e| e.to_string())?;
        let to = dest.join(entry.file_name());
        if ty.is_dir() {
            copy_dir_recursive(&entry.path(), &to)?;
        } else {
            fs::copy(entry.path(), &to).map_err(|e| e.to_string())?;
        }
    }
    Ok(())
}

fn write_env_file(home: &Path) -> Result<(), String> {
    fs::write(home.join("env"), env_snippet(home)).map_err(|e| e.to_string())
}

fn download_llvm_toolchain(dest_bin: &Path) -> Result<(), String> {
    let url = llvm_download_url()?;
    eprintln!("toolchain: downloading LLVM {LLVM_DOWNLOAD_VERSION} …");
    eprintln!("  {url}");

    let tmp = std::env::temp_dir().join(format!("nyra-llvm-{}", std::process::id()));
    fs::create_dir_all(&tmp).map_err(|e| e.to_string())?;
    let archive = tmp.join("llvm.tar.xz");

    let status = Command::new("curl")
        .args(["-fsSL", "-o", archive.to_str().unwrap(), &url])
        .status()
        .map_err(|e| format!("curl failed: {e}"))?;
    if !status.success() {
        return Err("LLVM download failed (curl)".into());
    }

    let extract = tmp.join("extract");
    fs::create_dir_all(&extract).map_err(|e| e.to_string())?;
    let status = Command::new("tar")
        .args(["-xJf", archive.to_str().unwrap(), "-C", extract.to_str().unwrap()])
        .status()
        .map_err(|e| format!("tar failed: {e}"))?;
    if !status.success() {
        return Err("LLVM extract failed (tar)".into());
    }

    let extracted_bin = find_extracted_llvm_bin(&extract)?;
    for entry in fs::read_dir(&extracted_bin).map_err(|e| e.to_string())? {
        let entry = entry.map_err(|e| e.to_string())?;
        if !entry.file_type().map_err(|e| e.to_string())?.is_file() {
            continue;
        }
        let name = entry.file_name();
        let dest = dest_bin.join(&name);
        let _ = fs::remove_file(&dest);
        symlink_or_copy(&entry.path(), &dest)?;
    }

    let _ = fs::remove_dir_all(&tmp);
    eprintln!(
        "toolchain: installed LLVM binaries from {} → {}",
        extracted_bin.display(),
        dest_bin.display()
    );
    Ok(())
}

fn find_extracted_llvm_bin(extract: &Path) -> Result<PathBuf, String> {
    for entry in fs::read_dir(extract).map_err(|e| e.to_string())? {
        let entry = entry.map_err(|e| e.to_string())?;
        if !entry.file_type().map_err(|e| e.to_string())?.is_dir() {
            continue;
        }
        let bin = entry.path().join("bin");
        if bin.join("clang").is_file() {
            return Ok(bin);
        }
    }
    Err("downloaded LLVM archive missing bin/clang".into())
}

fn llvm_download_url() -> Result<String, String> {
    let arch = std::env::consts::ARCH;
    let os = std::env::consts::OS;
    let tag = format!("llvmorg-{LLVM_DOWNLOAD_VERSION}");
    let base = format!("https://github.com/llvm/llvm-project/releases/download/{tag}");

    let asset = match (os, arch) {
        ("macos", "aarch64") => format!("clang+llvm-{LLVM_DOWNLOAD_VERSION}-arm64-apple-darwin.tar.xz"),
        ("macos", "x86_64") => format!("clang+llvm-{LLVM_DOWNLOAD_VERSION}-x86_64-apple-darwin.tar.xz"),
        ("linux", "x86_64") => {
            format!("clang+llvm-{LLVM_DOWNLOAD_VERSION}-x86_64-linux-gnu-ubuntu-22.04.tar.xz")
        }
        ("linux", "aarch64") => {
            format!("clang+llvm-{LLVM_DOWNLOAD_VERSION}-aarch64-linux-gnu.tar.xz")
        }
        _ => {
            return Err(format!(
                "no prebuilt LLVM download for {os}/{arch}; use system LLVM (nyra toolchain install without --download)"
            ));
        }
    };

    Ok(format!("{base}/{asset}"))
}

pub fn print_info() {
    llvm_tools::print_toolchain_info();
    let home = nyra_home();
    eprintln!("Nyra home: {}", home.display());
    if home.join("env").is_file() {
        eprintln!("Env file:  {}", home.join("env").display());
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn nyra_home_not_empty() {
        assert!(!nyra_home().as_os_str().is_empty());
    }

    #[test]
    fn env_snippet_contains_nyra_home() {
        let s = env_snippet(Path::new("/tmp/nyra-test"));
        assert!(s.contains("NYRA_HOME="));
        assert!(s.contains("NYRA_LLVM_BIN="));
    }

    #[test]
    fn download_url_mac_or_linux() {
        let url = llvm_download_url();
        if std::env::consts::OS == "macos" || std::env::consts::OS == "linux" {
            assert!(url.is_ok());
            assert!(url.unwrap().contains("github.com"));
        }
    }
}
