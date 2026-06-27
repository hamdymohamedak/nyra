//! Watch `.ny` files and re-run check or build on change.

use std::path::Path;
use std::process::Command;
use std::sync::mpsc::channel;
use std::time::Duration;

use notify::{Config, EventKind, RecommendedWatcher, RecursiveMode, Watcher};

#[derive(Debug, Clone, Copy)]
pub enum WatchMode {
    Check,
    Build,
    Run,
}

pub fn watch(path: &Path, mode: WatchMode) -> Result<(), String> {
    let root = if path.is_dir() {
        path.to_path_buf()
    } else {
        path.parent()
            .unwrap_or(Path::new("."))
            .to_path_buf()
    };
    let target = path.to_path_buf();

    let (tx, rx) = channel();
    let mut watcher = RecommendedWatcher::new(
        move |res| {
            if let Ok(event) = res {
                let _ = tx.send(event);
            }
        },
        Config::default(),
    )
    .map_err(|e| e.to_string())?;

    watcher
        .watch(&root, RecursiveMode::Recursive)
        .map_err(|e| e.to_string())?;

    eprintln!(
        "watch: monitoring {} — mode {:?} (Ctrl+C to stop)",
        root.display(),
        mode
    );
    run_once(&target, mode)?;

    let mut debounce = None::<std::time::Instant>;
    loop {
        match rx.recv_timeout(Duration::from_millis(200)) {
            Ok(event) => {
                if matches!(
                    event.kind,
                    EventKind::Modify(_) | EventKind::Create(_) | EventKind::Remove(_)
                ) {
                    debounce = Some(std::time::Instant::now());
                }
            }
            Err(std::sync::mpsc::RecvTimeoutError::Timeout) => {}
            Err(std::sync::mpsc::RecvTimeoutError::Disconnected) => break,
        }
        if debounce.is_some_and(|t| t.elapsed() > Duration::from_millis(300)) {
            debounce = None;
            eprintln!("watch: change detected");
            if let Err(e) = run_once(&target, mode) {
                eprintln!("watch: {e}");
            }
        }
    }
    Ok(())
}

fn run_once(path: &Path, mode: WatchMode) -> Result<(), String> {
    let nyra = std::env::current_exe().map_err(|e| e.to_string())?;
    let (sub, extra): (&str, Vec<&str>) = match mode {
        WatchMode::Check => ("check", vec![]),
        WatchMode::Build => ("build", vec![]),
        WatchMode::Run => ("run", vec![]),
    };
    let mut cmd = Command::new(nyra);
    cmd.arg(sub).arg(path);
    for a in extra {
        cmd.arg(a);
    }
    let status = cmd.status().map_err(|e| e.to_string())?;
    if !status.success() {
        return Err(format!("{sub} failed"));
    }
    Ok(())
}
