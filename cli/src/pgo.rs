//! Profile-guided optimization: instrument → train → merge → rebuild (+ smart cache).

use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};
use std::path::{Path, PathBuf};
use std::process::{Child, Command};
use std::thread;
use std::time::{Duration, Instant};

use compiler::{parse_file, paths};
use pkg::resolve_project_native_link;

use crate::link::{LinkProfile, LtoMode, OptLevel};
use crate::llvm_tools;
use crate::target::TargetSpec;

const PROFDATA_NAME: &str = "nyra.profdata";
const INSTRUMENTED_BIN_STEM: &str = "instrumented_bin";
const FINGERPRINT_FILE: &str = "pgo.fingerprint";

/// Paths under `target/{profile}/pgo/`.
pub struct PgoLayout {
    pub dir: PathBuf,
    pub profdata: PathBuf,
    /// `LLVM_PROFILE_FILE` pattern (supports multiple training runs).
    pub profraw_pattern: PathBuf,
    pub instrumented_bin: PathBuf,
    pub fingerprint_path: PathBuf,
}

impl PgoLayout {
    pub fn new(profile_dir: &Path, spec: &TargetSpec) -> Self {
        let dir = profile_dir.join("pgo");
        Self {
            profdata: dir.join(PROFDATA_NAME),
            profraw_pattern: dir.join("default_%m_%p.profraw"),
            instrumented_bin: dir.join(format!("{INSTRUMENTED_BIN_STEM}{}", spec.exe_extension())),
            fingerprint_path: dir.join(FINGERPRINT_FILE),
            dir,
        }
    }

    pub fn test_instrumented_bin(&self, stem: &str, test_name: &str, spec: &TargetSpec) -> PathBuf {
        self.dir
            .join(format!("test_{stem}_{test_name}-instr{}", spec.exe_extension()))
    }
}

/// Cached profile matches current sources + link/PGO options.
pub struct PgoCacheKey {
    pub source_hash: u64,
    pub options_hash: u64,
}

impl PgoCacheKey {
    pub fn write(&self, layout: &PgoLayout) -> Result<(), String> {
        std::fs::create_dir_all(&layout.dir).map_err(|e| e.to_string())?;
        let body = format!("{}\n{}", self.source_hash, self.options_hash);
        std::fs::write(&layout.fingerprint_path, body).map_err(|e| e.to_string())
    }

    pub fn read(layout: &PgoLayout) -> Option<Self> {
        let text = std::fs::read_to_string(&layout.fingerprint_path).ok()?;
        let mut lines = text.lines();
        let source_hash = lines.next()?.parse().ok()?;
        let options_hash = lines.next()?.parse().ok()?;
        Some(Self {
            source_hash,
            options_hash,
        })
    }
}

pub fn pgo_options_hash(
    lto_full: bool,
    debug_symbols: bool,
    native_cpu: bool,
    freestanding: bool,
    link_libs: &[String],
    link_args: &[String],
    training_args: &[String],
    training_timeout_secs: u64,
    comparison_training_fp: u64,
) -> u64 {
    let mut hasher = DefaultHasher::new();
    lto_full.hash(&mut hasher);
    debug_symbols.hash(&mut hasher);
    native_cpu.hash(&mut hasher);
    freestanding.hash(&mut hasher);
    training_timeout_secs.hash(&mut hasher);
    comparison_training_fp.hash(&mut hasher);
    for lib in link_libs {
        lib.hash(&mut hasher);
    }
    for arg in link_args {
        arg.hash(&mut hasher);
    }
    for arg in training_args {
        arg.hash(&mut hasher);
    }
    hasher.finish()
}

/// Args for instrumented binaries during PGO training (`nyra.mod` + `--pgo-arg`).
pub fn resolve_training_args(project_path: &Path, cli_args: &[String]) -> Vec<String> {
    let root = if project_path.is_dir() {
        project_path.to_path_buf()
    } else {
        project_path
            .parent()
            .map(Path::to_path_buf)
            .unwrap_or_else(|| project_path.to_path_buf())
    };
    let mut args = resolve_project_native_link(&root)
        .map(|m| m.pgo_run_args)
        .unwrap_or_default();
    args.extend(cli_args.iter().cloned());
    args
}

/// Configuration for automated PGO training runs.
pub struct PgoTrainingConfig {
    pub args: Vec<String>,
    pub timeout: Duration,
}

pub fn validate_pgo_build(spec: &TargetSpec, cdylib: bool) -> Result<(), String> {
    if spec.is_cross {
        return Err(format!(
            "PGO collects execution profiles by running the instrumented binary on this machine; \
             it cannot be used with cross-compilation (target `{}`).\n\
             Build on the target host, or use `nyra build --release` without `--pgo` for cross builds.",
            spec.triple_for_codegen()
        ));
    }
    if spec.is_wasm {
        return Err("PGO is not supported for wasm targets".into());
    }
    if cdylib {
        return Err("PGO is not supported for --cdylib builds".into());
    }
    Ok(())
}

/// Profile + instrumented binary match sources; safe to skip train/merge.
pub fn profile_cache_hit(layout: &PgoLayout, key: &PgoCacheKey) -> bool {
    if !layout.profdata.is_file() || !layout.instrumented_bin.is_file() {
        return false;
    }
    match PgoCacheKey::read(layout) {
        Some(cached) => {
            cached.source_hash == key.source_hash && cached.options_hash == key.options_hash
        }
        None => false,
    }
}

/// A `test fn` / `test_*` harness to run during PGO training.
pub struct PgoTestCase {
    pub label: String,
    pub harness_source: String,
    pub instrumented_bin: PathBuf,
}

fn walk_ny_files(root: &Path) -> Result<Vec<PathBuf>, String> {
    let mut files = Vec::new();
    if root.is_file() {
        if paths::is_nyra_source(root) {
            files.push(root.to_path_buf());
        }
        return Ok(files);
    }
    if !root.is_dir() {
        return Err(format!("not found: {}", root.display()));
    }
    for entry in std::fs::read_dir(root).map_err(|e| e.to_string())? {
        let entry = entry.map_err(|e| e.to_string())?;
        let p = entry.path();
        if p.is_dir() {
            files.extend(walk_ny_files(&p)?);
        } else if paths::is_nyra_source(&p) {
            files.push(p);
        }
    }
    Ok(files)
}

/// Discover `test fn` / `test_*` workloads under a project tree (mirrors `nyra test` discovery).
pub fn discover_test_cases(root: &Path, layout: &PgoLayout, spec: &TargetSpec) -> Result<Vec<PgoTestCase>, String> {
    let mut cases = Vec::new();
    for entry in walk_ny_files(root)? {
        let src = std::fs::read_to_string(&entry).map_err(|e| e.to_string())?;
        let program = parse_file(&entry)?;
        let stem = entry
            .file_stem()
            .map(|s| s.to_string_lossy().into_owned())
            .unwrap_or_else(|| "test".into());
        let mut tests: Vec<String> = program
            .functions
            .iter()
            .filter(|f| f.is_test || f.name.starts_with("test_"))
            .map(|f| f.name.clone())
            .collect();
        if tests.is_empty() && paths::is_legacy_test_file(&entry) {
            tests.push("main".into());
        }
        for test_name in tests {
            if test_name == "main" && paths::is_legacy_test_file(&entry) {
                continue;
            }
            let label = format!("{}::{}", entry.display(), test_name);
            let harness = format!("{src}\nfn main() {{\n    {test_name}()\n}}\n");
            cases.push(PgoTestCase {
                label,
                harness_source: harness,
                instrumented_bin: layout.test_instrumented_bin(&stem, &test_name, spec),
            });
        }
    }
    Ok(cases)
}

fn find_comparison_pgo_training(entry: &Path) -> Option<PathBuf> {
    let mut dir = if entry.is_file() {
        entry.parent()?.to_path_buf()
    } else {
        entry.to_path_buf()
    };
    loop {
        if dir.file_name().is_some_and(|n| n == "comparison") {
            let train = dir.join("pgo_training");
            if train.is_dir() {
                return Some(train);
            }
        }
        dir = dir.parent()?.to_path_buf();
    }
}

/// Fingerprint of `examples/comparison/pgo_training/*.ny` (invalidates PGO cache when edited).
pub fn comparison_training_fingerprint(entry: &Path) -> u64 {
    let Some(dir) = find_comparison_pgo_training(entry) else {
        return 0;
    };
    let mut hasher = DefaultHasher::new();
    "comparison-pgo-training-v1".hash(&mut hasher);
    let mut files = walk_ny_files(&dir).unwrap_or_default();
    files.retain(|p| p.parent().is_some_and(|parent| parent == dir));
    files.sort();
    for path in files {
        path.hash(&mut hasher);
        if let Ok(bytes) = std::fs::read(&path) {
            bytes.hash(&mut hasher);
        }
    }
    hasher.finish()
}

/// Branch/mod workloads shipped under `examples/comparison/pgo_training/`.
pub fn discover_comparison_training(
    entry: &Path,
    layout: &PgoLayout,
    spec: &TargetSpec,
) -> Result<Vec<PgoTestCase>, String> {
    let Some(dir) = find_comparison_pgo_training(entry) else {
        return Ok(Vec::new());
    };
    let mut cases = Vec::new();
    for path in walk_ny_files(&dir)? {
        if !path.parent().is_some_and(|parent| parent == dir) {
            continue;
        }
        let src = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
        let stem = path
            .file_stem()
            .map(|s| s.to_string_lossy().into_owned())
            .unwrap_or_else(|| "train".into());
        cases.push(PgoTestCase {
            label: format!("pgo_training::{}", path.display()),
            harness_source: src,
            instrumented_bin: layout.test_instrumented_bin("pgo", &stem, spec),
        });
    }
    Ok(cases)
}

/// Test harnesses + comparison training workloads for richer PGO profiles.
pub fn discover_training_cases(
    root: &Path,
    layout: &PgoLayout,
    spec: &TargetSpec,
) -> Result<Vec<PgoTestCase>, String> {
    let mut cases = discover_test_cases(root, layout, spec)?;
    cases.extend(discover_comparison_training(root, layout, spec)?);
    Ok(cases)
}

fn collect_profraw(dir: &Path) -> Result<Vec<PathBuf>, String> {
    let mut files = Vec::new();
    let entries = std::fs::read_dir(dir).map_err(|e| format!("read {}: {e}", dir.display()))?;
    for entry in entries {
        let entry = entry.map_err(|e| e.to_string())?;
        let path = entry.path();
        if path.extension().and_then(|e| e.to_str()) == Some("profraw") {
            files.push(path);
        }
    }
    files.sort();
    if files.is_empty() {
        return Err(format!(
            "no .profraw files in {} — training run did not write profile data",
            dir.display()
        ));
    }
    Ok(files)
}

pub fn merge_profdata(layout: &PgoLayout) -> Result<(), String> {
    let profraw = collect_profraw(&layout.dir)?;
    let profdata_bin = llvm_tools::require_llvm_profdata()?;
    let mut cmd = Command::new(&profdata_bin);
    cmd.arg("merge").arg("-output").arg(&layout.profdata);
    for f in &profraw {
        cmd.arg(f);
    }
    let status = cmd
        .status()
        .map_err(|e| format!("failed to run {profdata_bin}: {e}"))?;
    if !status.success() {
        return Err(format!("{profdata_bin} merge failed"));
    }
    if !layout.profdata.is_file() {
        return Err(format!(
            "expected profile at {}",
            layout.profdata.display()
        ));
    }
    Ok(())
}

fn wait_child_timeout(child: &mut Child, timeout: Duration, label: &str) -> Result<std::process::ExitStatus, String> {
    let start = Instant::now();
    loop {
        match child.try_wait().map_err(|e| format!("PGO training ({label}) wait failed: {e}"))? {
            Some(status) => return Ok(status),
            None if start.elapsed() >= timeout => {
                let _ = child.kill();
                let _ = child.wait();
                return Err(format!(
                    "PGO training ({label}) timed out after {}s — use a shorter workload, \
                     pass `--pgo-arg` (e.g. benchmark mode), or increase `--pgo-timeout`",
                    timeout.as_secs()
                ));
            }
            None => thread::sleep(Duration::from_millis(100)),
        }
    }
}

fn run_one_training_bin(
    bin: &Path,
    profile_file: &str,
    label: &str,
    training: &PgoTrainingConfig,
) -> Result<(), String> {
    let start = Instant::now();
    let mut cmd = Command::new(bin);
    cmd.env("LLVM_PROFILE_FILE", profile_file);
    cmd.env("NYRA_PGO", "1");
    cmd.args(&training.args);
    if !training.args.is_empty() {
        eprintln!(
            "PGO:   {label} args: {}",
            training
                .args
                .iter()
                .map(|a| format!("{a:?}"))
                .collect::<Vec<_>>()
                .join(" ")
        );
    }
    let mut child = cmd
        .spawn()
        .map_err(|e| format!("failed to run {}: {e}", bin.display()))?;
    let status = wait_child_timeout(&mut child, training.timeout, label)?;
    if !status.success() {
        return Err(format!(
            "PGO training ({label}) exited with status {} — ensure the program exits cleanly \
             (libc exit/return from main) so LLVM can write .profraw",
            status.code().unwrap_or(-1)
        ));
    }
    eprintln!(
        "PGO:   {label} finished in {:.2}s",
        start.elapsed().as_secs_f64()
    );
    Ok(())
}

/// Step 2: run instrumented `main`, then any instrumented test harnesses.
pub fn run_training(
    layout: &PgoLayout,
    instrumented_main: &Path,
    test_bins: &[PathBuf],
    training: &PgoTrainingConfig,
) -> Result<(), String> {
    std::fs::create_dir_all(&layout.dir).map_err(|e| e.to_string())?;
    for old in collect_profraw(&layout.dir).unwrap_or_default() {
        let _ = std::fs::remove_file(old);
    }

    let profile_file = layout.profraw_pattern.to_string_lossy().into_owned();
    let start = Instant::now();

    eprintln!(
        "PGO:   running main ({})",
        instrumented_main.display()
    );
    run_one_training_bin(instrumented_main, &profile_file, "main", training)?;

    for (i, bin) in test_bins.iter().enumerate() {
        if !bin.is_file() {
            return Err(format!(
                "PGO test binary missing: {} (build test harness first)",
                bin.display()
            ));
        }
        eprintln!("PGO:   running test {} ({})", i + 1, bin.display());
        run_one_training_bin(bin, &profile_file, &format!("test #{i}"), training)?;
    }

    let count = collect_profraw(&layout.dir)?.len();
    eprintln!(
        "PGO: training finished in {:.2}s ({} profile file(s))",
        start.elapsed().as_secs_f64(),
        count
    );
    Ok(())
}

pub fn instrumented_link_profile(
    base: LinkProfile,
    debug_symbols: bool,
    cdylib: bool,
    freestanding: bool,
    link_libs: Vec<String>,
    link_search_paths: Vec<PathBuf>,
    link_args: Vec<String>,
    link_sources: Vec<PathBuf>,
) -> LinkProfile {
    // Instrument on unoptimized IR: pre-running `llvm opt -O3` before clang
    // `-fprofile-instr-generate` skips counters in Nyra-generated `@main` (only runtime C
    // symbols appear in profdata). Clang inserts counters when it compiles the `.ll`.
    LinkProfile {
        pgo_generate: true,
        pgo_use: None,
        opt_level: OptLevel::O0,
        lto: LtoMode::Off,
        llvm_ir_opt: false,
        ..base
            .with_debug(debug_symbols)
            .with_cdylib(cdylib)
            .with_freestanding(freestanding)
            .with_native_link(link_libs, link_search_paths, link_args, link_sources)
    }
}

pub fn optimized_link_profile(
    base: LinkProfile,
    profdata: PathBuf,
    debug_symbols: bool,
    cdylib: bool,
    freestanding: bool,
    link_libs: Vec<String>,
    link_search_paths: Vec<PathBuf>,
    link_args: Vec<String>,
    link_sources: Vec<PathBuf>,
) -> LinkProfile {
    LinkProfile {
        pgo_generate: false,
        pgo_use: Some(profdata),
        ..base
            .with_debug(debug_symbols)
            .with_cdylib(cdylib)
            .with_freestanding(freestanding)
            .with_native_link(link_libs, link_search_paths, link_args, link_sources)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn instrumented_profile_skips_llvm_opt_for_counters() {
        let base = LinkProfile::from_cli(true, None, false, false, false, false, None, true).unwrap();
        let instr = instrumented_link_profile(
            base,
            false,
            false,
            false,
            Vec::new(),
            Vec::new(),
            Vec::new(),
            Vec::new(),
        );
        assert!(instr.pgo_generate);
        assert!(!instr.llvm_ir_opt, "instrumented PGO must not pre-opt IR");
        assert_eq!(instr.lto, LtoMode::Off);
        assert_eq!(instr.opt_level, OptLevel::O0);
    }

    #[test]
    fn pgo_layout_paths() {
        let spec = TargetSpec::host();
        let profile_dir = Path::new("/proj/target/release");
        let layout = PgoLayout::new(profile_dir, &spec);
        assert!(layout.dir.ends_with("target/release/pgo"));
        assert!(layout.profdata.ends_with(PROFDATA_NAME));
        assert!(
            layout
                .instrumented_bin
                .to_string_lossy()
                .contains(INSTRUMENTED_BIN_STEM)
        );
    }

    #[test]
    fn cache_key_roundtrip() {
        let spec = TargetSpec::host();
        let layout = PgoLayout::new(Path::new("/tmp/nyra-pgo-test"), &spec);
        let key = PgoCacheKey {
            source_hash: 42,
            options_hash: 99,
        };
        key.write(&layout).unwrap();
        let read = PgoCacheKey::read(&layout).unwrap();
        assert_eq!(read.source_hash, 42);
        assert_eq!(read.options_hash, 99);
    }

    #[test]
    fn discovers_comparison_pgo_training_near_cpu_bound() {
        let spec = TargetSpec::host();
        let entry = Path::new("examples/comparison/cpu_bound/bench.ny");
        if !entry.is_file() {
            return;
        }
        let layout = PgoLayout::new(Path::new("/tmp/nyra-pgo-train"), &spec);
        let cases = discover_comparison_training(entry, &layout, &spec).unwrap();
        assert!(
            cases.len() >= 3,
            "expected branch/mod training workloads, got {}",
            cases.len()
        );
        assert!(cases.iter().any(|c| c.label.contains("branch_dispatch")));
    }
}
