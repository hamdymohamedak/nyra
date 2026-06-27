use std::io::Write;
use std::path::Path;
use std::process::{Child, Command, Stdio};
use std::sync::mpsc;
use std::thread;
use std::time::{Duration, Instant};

use super::parse::{
    extract_quoted, output_indicates_exited, output_indicates_stopped, parse_backtrace,
    parse_gdb_variables, BreakpointHit, StackFrame, Variable,
};

pub struct GdbSession {
    child: Child,
    stdin: std::process::ChildStdin,
    rx: mpsc::Receiver<String>,
    token: u64,
    stopped: bool,
    exited: bool,
    pending_breaks: Vec<(String, i64)>,
}

impl GdbSession {
    pub fn spawn(gdb: &str) -> Result<Self, String> {
        let mut child = Command::new(gdb)
            .arg("--quiet")
            .arg("--interpreter=mi2")
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .map_err(|e| format!("gdb spawn: {e}"))?;
        let stdout = child.stdout.take().ok_or("gdb stdout unavailable")?;
        let stdin = child.stdin.take().ok_or("gdb stdin unavailable")?;
        let (tx, rx) = mpsc::channel();
        thread::spawn(move || {
            let reader = std::io::BufReader::new(stdout);
            use std::io::BufRead;
            for line in reader.lines() {
                if tx.send(line.unwrap_or_default()).is_err() {
                    break;
                }
            }
        });
        Ok(Self {
            child,
            stdin,
            rx,
            token: 1,
            stopped: false,
            exited: false,
            pending_breaks: Vec::new(),
        })
    }

    pub fn is_stopped(&self) -> bool {
        self.stopped
    }

    pub fn is_exited(&self) -> bool {
        self.exited
    }

    pub fn launch(
        &mut self,
        program: &str,
        args: &[String],
        _cwd: &Path,
        stop_on_entry: bool,
    ) -> Result<(), String> {
        self.mi(&format!("-file-exec-and-symbols \"{program}\""))?;
        for (file, line) in self.pending_breaks.clone() {
            self.set_breakpoint(&file, line)?;
        }
        if stop_on_entry {
            self.mi("-break-insert -n main")?;
        }
        let mut cmd = String::from("-exec-run");
        if !args.is_empty() {
            cmd.push(' ');
            for a in args {
                cmd.push_str(&format!("--arg \"{a}\" "));
            }
        }
        let out = self.mi(&cmd)?;
        self.update_state(&out);
        Ok(())
    }

    pub fn queue_breakpoint(&mut self, file: &str, line: i64) {
        self.pending_breaks.push((file.to_string(), line));
    }

    pub fn set_breakpoint(&mut self, file: &str, line: i64) -> Result<BreakpointHit, String> {
        let out = self.mi(&format!("-break-insert -f \"{file}\" -l {line}"))?;
        let verified = out.contains("^done") && !out.contains("^error");
        Ok(BreakpointHit {
            id: line,
            verified,
            line,
        })
    }

    pub fn continue_run(&mut self) -> Result<bool, String> {
        let out = self.mi("-exec-continue")?;
        self.update_state(&out);
        Ok(self.stopped)
    }

    pub fn next(&mut self) -> Result<bool, String> {
        let out = self.mi("-exec-next")?;
        self.update_state(&out);
        Ok(self.stopped)
    }

    pub fn step_in(&mut self) -> Result<bool, String> {
        let out = self.mi("-exec-step")?;
        self.update_state(&out);
        Ok(self.stopped)
    }

    pub fn step_out(&mut self) -> Result<bool, String> {
        let out = self.mi("-exec-finish")?;
        self.update_state(&out);
        Ok(self.stopped)
    }

    pub fn pause(&mut self) -> Result<(), String> {
        let out = self.mi("-exec-interrupt")?;
        self.update_state(&out);
        Ok(())
    }

    pub fn stack_trace(&mut self) -> Result<Vec<StackFrame>, String> {
        let out = self.mi("-stack-list-frames")?;
        if out.contains("frame=") {
            return Ok(parse_gdb_stack(&out));
        }
        Ok(parse_backtrace(&out))
    }

    pub fn locals(&mut self, frame_id: i64) -> Result<Vec<Variable>, String> {
        let idx = (frame_id - 1).max(0);
        let out = self.mi(&format!("-stack-list-variables --frame {idx} --all-values"))?;
        Ok(parse_gdb_variables(&out))
    }

    pub fn kill(&mut self) {
        let _ = self.mi("-gdb-exit");
        let _ = self.child.kill();
        let _ = self.child.wait();
    }

    fn update_state(&mut self, out: &str) {
        if output_indicates_stopped(out) {
            self.stopped = true;
            self.exited = false;
        }
        if output_indicates_exited(out) {
            self.exited = true;
            self.stopped = false;
        }
    }

    fn mi(&mut self, cmd: &str) -> Result<String, String> {
        let token = self.token;
        self.token += 1;
        let line = format!("{token}{cmd}\n");
        self.stdin.write_all(line.as_bytes()).map_err(|e| e.to_string())?;
        self.stdin.flush().map_err(|e| e.to_string())?;
        self.read_until_token(token, Duration::from_secs(30))
    }

    fn read_until_token(&mut self, token: u64, timeout: Duration) -> Result<String, String> {
        let prefix = format!("^{token}");
        let deadline = Instant::now() + timeout;
        let mut out = String::new();
        loop {
            let remaining = deadline.saturating_duration_since(Instant::now());
            if remaining.is_zero() {
                return Err("gdb mi timed out".into());
            }
            match self.rx.recv_timeout(remaining.min(Duration::from_millis(200))) {
                Ok(line) => {
                    if line.starts_with("*stopped") {
                        self.stopped = true;
                    }
                    out.push_str(&line);
                    out.push('\n');
                    if line.starts_with(&prefix) || line.starts_with("^error") {
                        break;
                    }
                }
                Err(mpsc::RecvTimeoutError::Timeout) => continue,
                Err(mpsc::RecvTimeoutError::Disconnected) => break,
            }
        }
        if out.contains("^error") {
            return Err(out);
        }
        Ok(out)
    }
}

fn parse_gdb_stack(output: &str) -> Vec<StackFrame> {
    let mut frames = Vec::new();
    for segment in output.split("frame=") {
        if !segment.contains("func=") {
            continue;
        }
        let level = extract_quoted(segment, "level")
            .and_then(|s| s.parse().ok())
            .unwrap_or(frames.len() as i64);
        let name = extract_quoted(segment, "func").unwrap_or_else(|| "?".into());
        let file = extract_quoted(segment, "file");
        let line = extract_quoted(segment, "line")
            .and_then(|s| s.parse().ok())
            .unwrap_or(1);
        frames.push(StackFrame {
            id: level + 1,
            name,
            file,
            line,
            column: 1,
        });
    }
    frames
}
