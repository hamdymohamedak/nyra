//! Launch LLDB or GDB on a Nyra binary built with debug symbols.

use std::path::{Path, PathBuf};
use std::process::Command;

pub fn debug_program(
    bin_path: &Path,
    program_args: &[String],
    debugger: Option<&str>,
) -> Result<(), String> {
    if !bin_path.exists() {
        return Err(format!("binary not found: {}", bin_path.display()));
    }

    let dbg = match debugger {
        Some(d) => d.to_string(),
        None => detect_debugger()?,
    };

    let mut cmd = if dbg.contains("lldb") {
        let mut c = Command::new(&dbg);
        c.arg(bin_path);
        c.arg("--");
        c.args(program_args);
        c
    } else {
        let mut c = Command::new(&dbg);
        c.arg("--args");
        c.arg(bin_path);
        c.args(program_args);
        c
    };

    eprintln!("debug: launching {} on {}", dbg, bin_path.display());
    let status = cmd.status().map_err(|e| format!("failed to launch {dbg}: {e}"))?;
    if !status.success() {
        return Err(format!(
            "{dbg} exited with status {}",
            status.code().unwrap_or(-1)
        ));
    }
    Ok(())
}

pub fn detect_debugger() -> Result<String, String> {
    for candidate in ["lldb", "gdb"] {
        if Command::new(candidate)
            .arg("--version")
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .status()
            .map(|s| s.success())
            .unwrap_or(false)
        {
            return Ok(candidate.into());
        }
    }
    Err("no debugger found — install lldb (macOS) or gdb (Linux)".into())
}

pub fn write_vscode_launch(root: &Path, bin_rel: &str) -> Result<PathBuf, String> {
    let editor_dir = root.join(".vscode");
    std::fs::create_dir_all(&editor_dir).map_err(|e| e.to_string())?;
    let launch_path = editor_dir.join("launch.json");
    let content = format!(
        r#"{{
  "version": "0.2.0",
  "configurations": [
    {{
      "name": "Nyra: Debug",
      "type": "nyra",
      "request": "launch",
      "program": "${{workspaceFolder}}/{bin_rel}",
      "args": [],
      "cwd": "${{workspaceFolder}}",
      "stopOnEntry": false,
      "preLaunchTask": "Nyra: build (debug)"
    }}
  ]
}}
"#
    );
    std::fs::write(&launch_path, content).map_err(|e| e.to_string())?;

    let tasks_path = editor_dir.join("tasks.json");
    if !tasks_path.exists() {
        let tasks = r#"{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Nyra: build (debug)",
      "type": "shell",
      "command": "nyra",
      "args": ["build", ".", "--debug-symbols"],
      "group": "build",
      "problemMatcher": "$nyra"
    }
  ]
}
"#;
        std::fs::write(&tasks_path, tasks).map_err(|e| e.to_string())?;
    }
    Ok(launch_path)
}
