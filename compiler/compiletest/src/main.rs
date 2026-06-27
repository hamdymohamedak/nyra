//! CLI for running Nyra file-based compile tests outside `cargo test`.

use std::env;
use std::path::PathBuf;
use std::process::ExitCode;

use compiletest::{run_suite, SuiteMode, SuiteResult};

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();
    let mut paths: Vec<PathBuf> = Vec::new();
    let mut filter = String::new();
    let mut update = false;
    let mut mode: Option<SuiteMode> = None;

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--filter" => {
                i += 1;
                filter = args.get(i).cloned().unwrap_or_default();
            }
            "--update" => update = true,
            "--capture" => {
                i += 1;
                let Some(path) = args.get(i).map(PathBuf::from) else {
                    eprintln!("--capture requires a .ny path");
                    return ExitCode::from(2);
                };
                match compiletest::capture_errors(&path) {
                    Ok(text) => {
                        print!("{text}");
                        return ExitCode::SUCCESS;
                    }
                    Err(e) => {
                        eprintln!("{e}");
                        return ExitCode::from(1);
                    }
                }
            }
            "--pass" => mode = Some(SuiteMode::Pass),
            "--fail" => mode = Some(SuiteMode::Fail),
            "--run" => mode = Some(SuiteMode::Run),
            "--help" | "-h" => {
                eprintln!(
                    "Usage: compiletest [--pass|--fail|--run] [--filter SUB] [--update] [PATH...]\n\
                     Default: run pass + fail + run under tests/suite/\n\
                     Progress: per-test lines on stderr (set NYRA_SUITE_QUIET=1 to disable)"
                );
                return ExitCode::SUCCESS;
            }
            arg if arg.starts_with('-') => {
                eprintln!("unknown flag: {arg}");
                return ExitCode::from(2);
            }
            arg => paths.push(PathBuf::from(arg)),
        }
        i += 1;
    }

    if paths.is_empty() {
        paths.push(compiletest::default_suite_root());
    }

    let modes: Vec<SuiteMode> = match mode {
        Some(m) => vec![m],
        None => vec![SuiteMode::Pass, SuiteMode::Fail, SuiteMode::Run],
    };

    let mut failed = 0usize;
    let mut passed = 0usize;
    for root in &paths {
        for m in &modes {
            let sub = root.join(mode_dir(*m));
            if !sub.exists() {
                continue;
            }
            let result = run_suite(&sub, *m, &filter, update);
            print_summary(&result);
            passed += result.passed();
            failed += result.failed();
        }
    }

    eprintln!("compiletest: {passed} passed, {failed} failed");
    if failed > 0 {
        ExitCode::from(1)
    } else {
        ExitCode::SUCCESS
    }
}

fn mode_dir(mode: SuiteMode) -> &'static str {
    match mode {
        SuiteMode::Pass => "pass",
        SuiteMode::Fail => "fail",
        SuiteMode::Run => "run",
    }
}

fn print_summary(result: &SuiteResult) {
    for r in &result.results {
        match r.status {
            compiletest::TestStatus::Passed => {
                println!("PASS [{:?}] {}", result.mode, r.path.display());
            }
            compiletest::TestStatus::Failed => {
                eprintln!("FAIL [{:?}] {}", result.mode, r.path.display());
                eprintln!("  {}", r.message);
            }
            compiletest::TestStatus::Ignored => {}
        }
    }
}
