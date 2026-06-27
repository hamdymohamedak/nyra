mod gdb;
mod lldb;
mod parse;

pub use parse::{StackFrame, Variable};

use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

use gdb::GdbSession;
use lldb::LldbSession;
use parse::BreakpointHit;

pub enum DebugBackend {
    Lldb(LldbSession),
    Gdb(GdbSession),
}

impl DebugBackend {
    pub fn spawn(preferred: &str) -> Result<Self, String> {
        if preferred.contains("gdb") {
            return GdbSession::spawn(preferred).map(DebugBackend::Gdb);
        }
        if supports_gdb_mi("gdb") {
            // If user asked for lldb but only gdb mi works, still try lldb first below.
        }
        LldbSession::spawn(preferred).map(DebugBackend::Lldb)
    }

    pub fn spawn_auto(requested: Option<&str>) -> Result<Self, String> {
        if let Some(name) = requested {
            return Self::spawn(name);
        }
        if supports_gdb_mi("gdb") {
            return GdbSession::spawn("gdb").map(DebugBackend::Gdb);
        }
        for candidate in ["lldb", "gdb"] {
            if debugger_available(candidate) {
                if candidate == "gdb" && supports_gdb_mi(candidate) {
                    return GdbSession::spawn(candidate).map(DebugBackend::Gdb);
                }
                return LldbSession::spawn(candidate).map(DebugBackend::Lldb);
            }
        }
        Err("no debugger found — install lldb (macOS) or gdb (Linux)".into())
    }

    pub fn is_stopped(&self) -> bool {
        match self {
            Self::Lldb(s) => s.is_stopped(),
            Self::Gdb(s) => s.is_stopped(),
        }
    }

    pub fn is_exited(&self) -> bool {
        match self {
            Self::Lldb(s) => s.is_exited(),
            Self::Gdb(s) => s.is_exited(),
        }
    }

    pub fn launch(
        &mut self,
        program: &str,
        args: &[String],
        cwd: &Path,
        stop_on_entry: bool,
    ) -> Result<(), String> {
        match self {
            Self::Lldb(s) => s.launch(program, args, cwd, stop_on_entry),
            Self::Gdb(s) => s.launch(program, args, cwd, stop_on_entry),
        }
    }

    pub fn queue_breakpoint(&mut self, file: &str, line: i64) {
        match self {
            Self::Lldb(s) => s.queue_breakpoint(file, line),
            Self::Gdb(s) => s.queue_breakpoint(file, line),
        }
    }

    pub fn set_breakpoint(&mut self, file: &str, line: i64) -> Result<BreakpointHit, String> {
        match self {
            Self::Lldb(s) => s.set_breakpoint(file, line),
            Self::Gdb(s) => s.set_breakpoint(file, line),
        }
    }

    pub fn continue_run(&mut self) -> Result<bool, String> {
        match self {
            Self::Lldb(s) => s.continue_run(),
            Self::Gdb(s) => s.continue_run(),
        }
    }

    pub fn next(&mut self) -> Result<bool, String> {
        match self {
            Self::Lldb(s) => s.next(),
            Self::Gdb(s) => s.next(),
        }
    }

    pub fn step_in(&mut self) -> Result<bool, String> {
        match self {
            Self::Lldb(s) => s.step_in(),
            Self::Gdb(s) => s.step_in(),
        }
    }

    pub fn step_out(&mut self) -> Result<bool, String> {
        match self {
            Self::Lldb(s) => s.step_out(),
            Self::Gdb(s) => s.step_out(),
        }
    }

    pub fn pause(&mut self) -> Result<(), String> {
        match self {
            Self::Lldb(s) => s.pause(),
            Self::Gdb(s) => s.pause(),
        }
    }

    pub fn stack_trace(&mut self) -> Result<Vec<StackFrame>, String> {
        match self {
            Self::Lldb(s) => s.stack_trace(),
            Self::Gdb(s) => s.stack_trace(),
        }
    }

    pub fn locals(&mut self, frame_id: i64) -> Result<Vec<Variable>, String> {
        match self {
            Self::Lldb(s) => s.locals(frame_id),
            Self::Gdb(s) => s.locals(frame_id),
        }
    }

    pub fn kill(&mut self) {
        match self {
            Self::Lldb(s) => s.kill(),
            Self::Gdb(s) => s.kill(),
        }
    }
}

fn debugger_available(name: &str) -> bool {
    Command::new(name)
        .arg("--version")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn supports_gdb_mi(gdb: &str) -> bool {
    Command::new(gdb)
        .arg("--interpreter=mi2")
        .arg("--version")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

/// Resolve a source path from DAP to an absolute path for breakpoints.
pub fn resolve_source_path(path: &str, cwd: &Path) -> PathBuf {
    let p = PathBuf::from(path);
    if p.is_absolute() {
        return p;
    }
    cwd.join(p)
}
