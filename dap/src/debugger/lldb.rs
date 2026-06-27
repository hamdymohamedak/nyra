use std::io::Write;
use std::path::Path;
use std::process::{Child, Command, Stdio};
use std::sync::mpsc;
use std::thread;
use std::time::{Duration, Instant};

use super::parse::{
    output_indicates_exited, output_indicates_stopped, parse_backtrace, parse_lldb_variables,
    BreakpointHit, StackFrame, Variable,
};

pub struct LldbSession {
    child: Child,
    stdin: std::process::ChildStdin,
    rx: mpsc::Receiver<String>,
    stopped: bool,
    exited: bool,
    pending_breaks: Vec<(String, i64)>,
}

impl LldbSession {
    pub fn spawn(lldb: &str) -> Result<Self, String> {
        let mut child = Command::new(lldb)
            .arg("-Q")
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .map_err(|e| format!("lldb spawn: {e}"))?;
        let stdout = child
            .stdout
            .take()
            .ok_or_else(|| "lldb stdout unavailable".to_string())?;
        let stdin = child
            .stdin
            .take()
            .ok_or_else(|| "lldb stdin unavailable".to_string())?;
        let (tx, rx) = mpsc::channel();
        thread::spawn(move || {
            let reader = std::io::BufReader::new(stdout);
            use std::io::BufRead;
            for line in reader.lines() {
                match line {
                    Ok(l) => {
                        if tx.send(l).is_err() {
                            break;
                        }
                    }
                    Err(_) => break,
                }
            }
        });
        let mut session = Self {
            child,
            stdin,
            rx,
            stopped: false,
            exited: false,
            pending_breaks: Vec::new(),
        };
        session.wait_prompt(Duration::from_secs(5))?;
        Ok(session)
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
        cwd: &Path,
        stop_on_entry: bool,
    ) -> Result<(), String> {
        let _ = self.exec(&format!("settings set target.process.working-directory \"{}\"", cwd.display()))?;
        let out = self.exec(&format!("target create \"{program}\""))?;
        if out.contains("error:") {
            return Err(out);
        }
        for (file, line) in self.pending_breaks.clone() {
            self.set_breakpoint(&file, line)?;
        }
        if stop_on_entry {
            self.exec("breakpoint set -n main")?;
        }
        let mut launch = String::from("process launch");
        if !args.is_empty() {
            launch.push(' ');
            for (i, a) in args.iter().enumerate() {
                if i > 0 {
                    launch.push(' ');
                }
                launch.push('"');
                launch.push_str(a);
                launch.push('"');
            }
        }
        let out = self.exec(&launch)?;
        if output_indicates_stopped(&out) {
            self.stopped = true;
        }
        if output_indicates_exited(&out) {
            self.exited = true;
            self.stopped = false;
        }
        Ok(())
    }

    pub fn queue_breakpoint(&mut self, file: &str, line: i64) {
        self.pending_breaks.push((file.to_string(), line));
    }

    pub fn set_breakpoint(&mut self, file: &str, line: i64) -> Result<BreakpointHit, String> {
        let cmd = format!("breakpoint set -f \"{file}\" -l {line}");
        let out = self.exec(&cmd)?;
        let verified = out.contains("Breakpoint") && !out.contains("no locations (pending)");
        Ok(BreakpointHit {
            id: line,
            verified,
            line,
        })
    }

    pub fn continue_run(&mut self) -> Result<bool, String> {
        let out = self.exec("process continue")?;
        self.stopped = output_indicates_stopped(&out);
        self.exited = output_indicates_exited(&out);
        Ok(self.stopped)
    }

    pub fn next(&mut self) -> Result<bool, String> {
        let out = self.exec("thread step-over")?;
        self.stopped = output_indicates_stopped(&out);
        self.exited = output_indicates_exited(&out);
        Ok(self.stopped)
    }

    pub fn step_in(&mut self) -> Result<bool, String> {
        let out = self.exec("thread step-in")?;
        self.stopped = output_indicates_stopped(&out);
        self.exited = output_indicates_exited(&out);
        Ok(self.stopped)
    }

    pub fn step_out(&mut self) -> Result<bool, String> {
        let out = self.exec("thread step-out")?;
        self.stopped = output_indicates_stopped(&out);
        self.exited = output_indicates_exited(&out);
        Ok(self.stopped)
    }

    pub fn pause(&mut self) -> Result<(), String> {
        let out = self.exec("process interrupt")?;
        if output_indicates_stopped(&out) {
            self.stopped = true;
        }
        Ok(())
    }

    pub fn stack_trace(&mut self) -> Result<Vec<StackFrame>, String> {
        let out = self.exec("thread backtrace")?;
        Ok(parse_backtrace(&out))
    }

    pub fn locals(&mut self, frame_id: i64) -> Result<Vec<Variable>, String> {
        let idx = (frame_id - 1).max(0);
        let _ = self.exec(&format!("frame select {idx}"))?;
        let out = self.exec("frame variable")?;
        Ok(parse_lldb_variables(&out))
    }

    pub fn kill(&mut self) {
        let _ = self.exec("process kill");
        let _ = self.exec("quit");
        let _ = self.child.kill();
        let _ = self.child.wait();
    }

    fn exec(&mut self, cmd: &str) -> Result<String, String> {
        self.stdin
            .write_all(format!("{cmd}\n").as_bytes())
            .map_err(|e| e.to_string())?;
        self.stdin.flush().map_err(|e| e.to_string())?;
        self.wait_prompt(Duration::from_secs(30))
    }

    fn wait_prompt(&mut self, timeout: Duration) -> Result<String, String> {
        let deadline = Instant::now() + timeout;
        let mut out = String::new();
        loop {
            let remaining = deadline.saturating_duration_since(Instant::now());
            if remaining.is_zero() {
                return Err("lldb command timed out".into());
            }
            match self.rx.recv_timeout(remaining.min(Duration::from_millis(200))) {
                Ok(line) => {
                    if line.trim() == "(lldb)" {
                        break;
                    }
                    out.push_str(&line);
                    out.push('\n');
                }
                Err(mpsc::RecvTimeoutError::Timeout) => continue,
                Err(mpsc::RecvTimeoutError::Disconnected) => break,
            }
        }
        Ok(out)
    }
}
