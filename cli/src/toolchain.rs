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
    let libclang = libclang_dir(home);
    let mut out = format!(
        r#"# Nyra native toolchain (bundled under $NYRA_HOME)
export NYRA_HOME="{home}"
export NYRA_LLVM_BIN="{llvm}"
export NYRA_WASI_SYSROOT="{wasi}"
export PATH="${{NYRA_HOME}}/bin:${{NYRA_LLVM_BIN}}:${{PATH}}"
"#,
        home = home.display(),
        llvm = llvm.display(),
        wasi = wasi.display(),
    );
    if libclang.is_dir() {
        out.push_str(&format!(
            "export LIBCLANG_PATH=\"{libclang}\"\n",
            libclang = libclang.display()
        ));
    }
    out
}

pub fn libclang_dir(home: &Path) -> PathBuf {
    home.join("lib/llvm/lib")
}

/// Ensure clang tools + libclang are available for `nyra bind c` / builds.
///
/// Prefer an existing `$NYRA_HOME/lib/llvm` layout or a system Homebrew/apt LLVM;
/// otherwise download a prebuilt release. Sets `LIBCLANG_PATH` / `NYRA_LLVM_BIN`
/// for this process so users do not need a separate `brew install llvm` step.
pub fn ensure_bindgen_toolchain() -> Result<(), String> {
    apply_process_toolchain_env();
    let _ = discover_and_set_system_libclang();
    if libclang_ready() {
        return Ok(());
    }

    eprintln!("toolchain: preparing bundled LLVM/libclang for C bindgen…");
    match install_toolchain(false, false) {
        Ok(()) => {
            apply_process_toolchain_env();
            if libclang_ready() {
                return Ok(());
            }
        }
        Err(e) => {
            eprintln!("toolchain: link system LLVM failed ({e}); trying download…");
        }
    }

    install_toolchain(true, false)?;
    apply_process_toolchain_env();
    if libclang_ready() {
        return Ok(());
    }
    Err(
        "libclang still not available after toolchain install — set LIBCLANG_PATH or reinstall Nyra so the bundled toolchain is present"
            .into(),
    )
}

fn discover_and_set_system_libclang() -> bool {
    if let Some(dir) = brew_llvm_lib_dir() {
        if libclang_exists(&dir) {
            std::env::set_var("LIBCLANG_PATH", &dir);
            return true;
        }
    }
    for cand in [
        "/usr/lib",
        "/usr/lib64",
        "/usr/lib/llvm-18/lib",
        "/usr/lib/llvm-17/lib",
        "/usr/lib/llvm-16/lib",
        "/usr/lib/x86_64-linux-gnu",
        "/usr/lib/aarch64-linux-gnu",
    ] {
        let p = Path::new(cand);
        if libclang_exists(p) {
            std::env::set_var("LIBCLANG_PATH", p);
            return true;
        }
    }
    false
}

fn brew_llvm_lib_dir() -> Option<PathBuf> {
    let out = Command::new("brew")
        .args(["--prefix", "llvm"])
        .output()
        .ok()?;
    if !out.status.success() {
        return None;
    }
    let prefix = String::from_utf8_lossy(&out.stdout).trim().to_string();
    if prefix.is_empty() {
        return None;
    }
    Some(PathBuf::from(prefix).join("lib"))
}

fn apply_process_toolchain_env() {
    let home = nyra_home();
    let bin = llvm_bin_dir(&home);
    if bin.is_dir() {
        std::env::set_var("NYRA_LLVM_BIN", &bin);
    }
    let lib = libclang_dir(&home);
    if libclang_exists(&lib) {
        std::env::set_var("LIBCLANG_PATH", &lib);
    } else if let Some(discovered) = discover_libclang_near_bin(&bin) {
        std::env::set_var("LIBCLANG_PATH", &discovered);
    }
}

fn libclang_ready() -> bool {
    if let Ok(p) = std::env::var("LIBCLANG_PATH") {
        if libclang_exists(Path::new(&p)) {
            return true;
        }
    }
    libclang_exists(&libclang_dir(&nyra_home()))
}

fn libclang_exists(dir: &Path) -> bool {
    if !dir.is_dir() {
        return false;
    }
    let names = [
        "libclang.dylib",
        "libclang.so",
        "libclang.so.18",
        "libclang.so.17",
        "libclang.so.16",
        "libclang.dll",
        "libclang.lib",
    ];
    if names.iter().any(|n| dir.join(n).is_file()) {
        return true;
    }
    // versioned .so.N on Linux
    if let Ok(entries) = fs::read_dir(dir) {
        for ent in entries.flatten() {
            let name = ent.file_name();
            let s = name.to_string_lossy();
            if s.starts_with("libclang.so") || s.starts_with("libclang.") {
                return true;
            }
        }
    }
    false
}

fn discover_libclang_near_bin(llvm_bin: &Path) -> Option<PathBuf> {
    let mut cands = Vec::new();
    if let Some(prefix) = llvm_bin.parent() {
        cands.push(prefix.join("lib"));
        if let Some(up) = prefix.parent() {
            cands.push(up.join("lib"));
        }
    }
    cands.into_iter().find(|c| libclang_exists(c))
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

    // Always try to wire libclang next to the tools (bindgen + clang-sys).
    let _ = install_libclang_layout(&home, &bin_dir);

    if include_wasi {
        install_wasi_sysroot(&home)?;
    }

    write_env_file(&home)?;
    apply_process_toolchain_env();
    eprintln!("toolchain: installed under {}", home.display());
    eprintln!("toolchain: add to shell — source \"{}/env\"", home.display());
    toolchain_info();
    Ok(())
}

fn install_libclang_layout(home: &Path, llvm_bin: &Path) -> Result<(), String> {
    let dest = libclang_dir(home);
    fs::create_dir_all(&dest).map_err(|e| e.to_string())?;

    let src = discover_libclang_near_bin(llvm_bin).ok_or_else(|| {
        "libclang not found next to LLVM bin (bindgen may still use a system copy)".to_string()
    })?;

    if src.canonicalize().ok() == dest.canonicalize().ok() {
        return Ok(());
    }

    let mut linked = 0usize;
    for entry in fs::read_dir(&src).map_err(|e| e.to_string())? {
        let entry = entry.map_err(|e| e.to_string())?;
        let name = entry.file_name();
        let s = name.to_string_lossy();
        if !s.starts_with("libclang") {
            continue;
        }
        let dest_file = dest.join(&name);
        let _ = fs::remove_file(&dest_file);
        symlink_or_copy(&entry.path(), &dest_file)?;
        linked += 1;
    }
    if linked == 0 {
        return Err(format!("no libclang* files in {}", src.display()));
    }
    eprintln!(
        "toolchain: linked {linked} libclang artifact(s) → {}",
        dest.display()
    );
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

    // Official clang+llvm tarballs ship libclang next to bin/.
    if let Some(extracted_lib) = extracted_bin.parent().map(|p| p.join("lib")) {
        if libclang_exists(&extracted_lib) {
            let home = nyra_home();
            let dest_lib = libclang_dir(&home);
            fs::create_dir_all(&dest_lib).map_err(|e| e.to_string())?;
            for entry in fs::read_dir(&extracted_lib).map_err(|e| e.to_string())? {
                let entry = entry.map_err(|e| e.to_string())?;
                let name = entry.file_name();
                let s = name.to_string_lossy();
                if !s.starts_with("libclang") {
                    continue;
                }
                let dest = dest_lib.join(&name);
                let _ = fs::remove_file(&dest);
                // Prefer copy for extracted archives so tmp cleanup is safe.
                fs::copy(entry.path(), &dest)
                    .map_err(|e| format!("copy libclang {}: {e}", entry.path().display()))?;
            }
            eprintln!("toolchain: installed libclang → {}", dest_lib.display());
        }
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
    fn env_snippet_includes_libclang_when_present() {
        let root = std::env::temp_dir().join(format!("nyra-tc-test-{}", std::process::id()));
        let lib = root.join("lib/llvm/lib");
        fs::create_dir_all(&lib).unwrap();
        fs::write(lib.join("libclang.dylib"), b"").unwrap();
        let s = env_snippet(&root);
        assert!(s.contains("LIBCLANG_PATH="), "{s}");
        let _ = fs::remove_dir_all(&root);
    }

    #[test]
    fn libclang_exists_detects_dylib() {
        let root = std::env::temp_dir().join(format!("nyra-lc-test-{}", std::process::id()));
        let lib = root.join("lib");
        fs::create_dir_all(&lib).unwrap();
        assert!(!libclang_exists(&lib));
        fs::write(lib.join("libclang.dylib"), b"").unwrap();
        assert!(libclang_exists(&lib));
        let _ = fs::remove_dir_all(&root);
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
