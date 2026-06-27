use std::io::Write;
use std::path::{Path, PathBuf};

use crate::debugger::{resolve_source_path, DebugBackend, StackFrame};
use crate::protocol::{DapMessage, LaunchArgs, SetBreakpointsArgs, SourceArgs, VariablesArgs};
use crate::transport::{read_message, write_message};
use serde_json::json;

pub struct DapServer {
    seq: u64,
    backend: Option<DebugBackend>,
    cwd: PathBuf,
    next_var_ref: i64,
    var_refs: std::collections::HashMap<i64, i64>,
    pending_breaks: Vec<(String, i64)>,
}

impl DapServer {
    pub fn new() -> Self {
        Self {
            seq: 1,
            backend: None,
            cwd: PathBuf::from("."),
            next_var_ref: 1000,
            var_refs: std::collections::HashMap::new(),
            pending_breaks: Vec::new(),
        }
    }

    fn next_seq(&mut self) -> u64 {
        let s = self.seq;
        self.seq += 1;
        s
    }

    pub fn run_stdio(&mut self) -> Result<(), String> {
        let stdin = std::io::stdin();
        let mut stdin = stdin.lock();
        let mut stdout = std::io::stdout();
        loop {
            let msg = read_message(&mut stdin)?;
            let Some(msg) = msg else {
                break;
            };
            self.handle_message(&mut stdout, msg)?;
        }
        Ok(())
    }

    fn handle_message(&mut self, out: &mut impl Write, msg: DapMessage) -> Result<(), String> {
        match msg.type_.as_str() {
            "request" => {
                let cmd = msg.command.as_deref().unwrap_or("");
                let seq = msg.seq;
                match cmd {
                    "initialize" => self.respond(
                        out,
                        seq,
                        json!({
                            "supportsConfigurationDoneRequest": true,
                            "supportsEvaluateForHovers": false,
                            "supportsSetVariable": false,
                            "supportsRestartRequest": false,
                            "supportsTerminateDebuggee": true,
                        }),
                    )?,
                    "launch" => {
                        let args: LaunchArgs = serde_json::from_value(
                            msg.arguments.clone().unwrap_or(json!({})),
                        )
                        .map_err(|e| e.to_string())?;
                        match self.launch(&args) {
                            Ok(()) => {
                                self.respond(out, seq, json!({}))?;
                                self.event(out, "initialized", json!({}))?;
                                if self
                                    .backend
                                    .as_ref()
                                    .map(|b| b.is_stopped())
                                    .unwrap_or(false)
                                {
                                    self.event(
                                        out,
                                        "stopped",
                                        json!({ "reason": "entry", "threadId": 1 }),
                                    )?;
                                } else if self
                                    .backend
                                    .as_ref()
                                    .map(|b| b.is_exited())
                                    .unwrap_or(false)
                                {
                                    self.event(out, "terminated", json!({}))?;
                                }
                            }
                            Err(e) => self.respond_error(out, seq, &e)?,
                        }
                    }
                    "configurationDone" => self.respond(out, seq, json!({}))?,
                    "threads" => self.respond(
                        out,
                        seq,
                        json!({ "threads": [{ "id": 1, "name": "main" }] }),
                    )?,
                    "stackTrace" => {
                        let frames = self.stack_frames_json()?;
                        self.respond(
                            out,
                            seq,
                            json!({ "stackFrames": frames, "totalFrames": frames.len() }),
                        )?;
                    }
                    "scopes" => {
                        let frame_id = msg
                            .arguments
                            .as_ref()
                            .and_then(|a| a.get("frameId"))
                            .and_then(|v| v.as_i64())
                            .unwrap_or(1);
                        let var_ref = self.alloc_var_ref(frame_id);
                        self.respond(
                            out,
                            seq,
                            json!({ "scopes": [{ "name": "Locals", "variablesReference": var_ref, "expensive": false }] }),
                        )?;
                    }
                    "variables" => {
                        let args: VariablesArgs = serde_json::from_value(
                            msg.arguments.clone().unwrap_or(json!({})),
                        )
                        .map_err(|e| e.to_string())?;
                        let items = self.variables_json(args.variables_reference)?;
                        self.respond(out, seq, json!({ "variables": items }))?;
                    }
                    "source" => {
                        let args: SourceArgs = serde_json::from_value(
                            msg.arguments.clone().unwrap_or(json!({})),
                        )
                        .map_err(|e| e.to_string())?;
                        let body = self.source_body(&args)?;
                        self.respond(out, seq, body)?;
                    }
                    "continue" => {
                        let stopped = self.continue_run()?;
                        self.respond(out, seq, json!({ "allThreadsContinued": !stopped }))?;
                        if stopped {
                            self.event(
                                out,
                                "stopped",
                                json!({ "reason": "breakpoint", "threadId": 1 }),
                            )?;
                        } else if self
                            .backend
                            .as_ref()
                            .map(|b| b.is_exited())
                            .unwrap_or(false)
                        {
                            self.event(out, "terminated", json!({}))?;
                        }
                    }
                    "next" | "stepIn" | "stepOut" => {
                        let stopped = match cmd {
                            "next" => self.next()?,
                            "stepIn" => self.step_in()?,
                            _ => self.step_out()?,
                        };
                        self.respond(out, seq, json!({}))?;
                        if stopped {
                            self.event(
                                out,
                                "stopped",
                                json!({ "reason": "step", "threadId": 1 }),
                            )?;
                        } else if self
                            .backend
                            .as_ref()
                            .map(|b| b.is_exited())
                            .unwrap_or(false)
                        {
                            self.event(out, "terminated", json!({}))?;
                        }
                    }
                    "pause" => {
                        self.pause()?;
                        self.respond(out, seq, json!({}))?;
                        self.event(
                            out,
                            "stopped",
                            json!({ "reason": "pause", "threadId": 1 }),
                        )?;
                    }
                    "disconnect" | "terminate" => {
                        self.stop_debugger();
                        self.respond(out, seq, json!({}))?;
                        self.event(out, "terminated", json!({}))?;
                    }
                    "setBreakpoints" => {
                        let args: SetBreakpointsArgs = serde_json::from_value(
                            msg.arguments.clone().unwrap_or(json!({})),
                        )
                        .map_err(|e| e.to_string())?;
                        let breakpoints = self.set_breakpoints(&args)?;
                        self.respond(out, seq, json!({ "breakpoints": breakpoints }))?;
                    }
                    _ => self.respond_error(out, seq, &format!("unknown command: {cmd}"))?,
                }
            }
            _ => {}
        }
        Ok(())
    }

    fn alloc_var_ref(&mut self, frame_id: i64) -> i64 {
        let id = self.next_var_ref;
        self.next_var_ref += 1;
        self.var_refs.insert(id, frame_id);
        id
    }

    fn launch(&mut self, args: &LaunchArgs) -> Result<(), String> {
        let program = Path::new(&args.program);
        if !program.exists() {
            return Err(format!("program not found: {}", args.program));
        }
        let cwd = args
            .cwd
            .as_deref()
            .map(Path::new)
            .map(Path::to_path_buf)
            .unwrap_or_else(|| {
                program
                    .parent()
                    .map(Path::to_path_buf)
                    .unwrap_or_else(|| PathBuf::from("."))
            });
        self.cwd = cwd.clone();
        let mut backend =
            DebugBackend::spawn_auto(args.debugger.as_deref())?;
        for (file, line) in self.pending_breaks.drain(..) {
            backend.queue_breakpoint(&file, line);
        }
        backend.launch(
            &args.program,
            &args.args,
            &cwd,
            args.stop_on_entry,
        )?;
        self.backend = Some(backend);
        Ok(())
    }

    fn set_breakpoints(&mut self, args: &SetBreakpointsArgs) -> Result<Vec<serde_json::Value>, String> {
        let source_path = args
            .source
            .path
            .as_deref()
            .ok_or_else(|| "setBreakpoints: missing source.path".to_string())?;
        let file = resolve_source_path(source_path, &self.cwd);
        let file_str = file.to_string_lossy().into_owned();
        let lines: Vec<i64> = if args.lines.is_empty() {
            args.breakpoints.iter().map(|b| b.line).collect()
        } else {
            args.lines.clone()
        };
        let mut out = Vec::new();
        for line in lines {
            if let Some(backend) = self.backend.as_mut() {
                let hit = backend.set_breakpoint(&file_str, line)?;
                out.push(json!({
                    "id": hit.id,
                    "verified": hit.verified,
                    "line": hit.line,
                }));
            } else {
                self.pending_breaks.push((file_str.clone(), line));
                out.push(json!({
                    "id": line,
                    "verified": true,
                    "line": line,
                }));
            }
        }
        Ok(out)
    }

    fn stack_frames_json(&mut self) -> Result<Vec<serde_json::Value>, String> {
        let Some(backend) = self.backend.as_mut() else {
            return Ok(vec![]);
        };
        let frames = backend.stack_trace()?;
        Ok(frames.into_iter().map(frame_to_json).collect())
    }

    fn variables_json(&mut self, var_ref: i64) -> Result<Vec<serde_json::Value>, String> {
        let frame_id = self.var_refs.get(&var_ref).copied().unwrap_or(1);
        let Some(backend) = self.backend.as_mut() else {
            return Ok(vec![]);
        };
        let vars = backend.locals(frame_id)?;
        Ok(vars
            .into_iter()
            .map(|v| {
                json!({
                    "name": v.name,
                    "value": v.value,
                    "type": v.type_name.unwrap_or_default(),
                    "variablesReference": 0,
                })
            })
            .collect())
    }

    fn source_body(&self, args: &SourceArgs) -> Result<serde_json::Value, String> {
        if let Some(path) = args.source.path.as_deref() {
            let p = resolve_source_path(path, &self.cwd);
            if p.exists() {
                let content = std::fs::read_to_string(&p).map_err(|e| e.to_string())?;
                return Ok(json!({ "content": content, "mimeType": "text/x-nyra" }));
            }
        }
        Ok(json!({}))
    }

    fn continue_run(&mut self) -> Result<bool, String> {
        self.backend
            .as_mut()
            .ok_or_else(|| "debugger not running".to_string())?
            .continue_run()
    }

    fn next(&mut self) -> Result<bool, String> {
        self.backend
            .as_mut()
            .ok_or_else(|| "debugger not running".to_string())?
            .next()
    }

    fn step_in(&mut self) -> Result<bool, String> {
        self.backend
            .as_mut()
            .ok_or_else(|| "debugger not running".to_string())?
            .step_in()
    }

    fn step_out(&mut self) -> Result<bool, String> {
        self.backend
            .as_mut()
            .ok_or_else(|| "debugger not running".to_string())?
            .step_out()
    }

    fn pause(&mut self) -> Result<(), String> {
        self.backend
            .as_mut()
            .ok_or_else(|| "debugger not running".to_string())?
            .pause()
    }

    fn respond(&mut self, out: &mut impl Write, request_seq: u64, body: serde_json::Value) -> Result<(), String> {
        write_message(
            out,
            &DapMessage {
                seq: self.next_seq(),
                type_: "response".into(),
                request_seq: Some(request_seq),
                command: None,
                event: None,
                success: Some(true),
                message: None,
                body: Some(body),
                arguments: None,
            },
        )
    }

    fn respond_error(&mut self, out: &mut impl Write, request_seq: u64, message: &str) -> Result<(), String> {
        write_message(
            out,
            &DapMessage {
                seq: self.next_seq(),
                type_: "response".into(),
                request_seq: Some(request_seq),
                command: None,
                event: None,
                success: Some(false),
                message: Some(message.into()),
                body: None,
                arguments: None,
            },
        )
    }

    fn event(&mut self, out: &mut impl Write, event: &str, body: serde_json::Value) -> Result<(), String> {
        write_message(
            out,
            &DapMessage {
                seq: self.next_seq(),
                type_: "event".into(),
                request_seq: None,
                command: None,
                event: Some(event.into()),
                success: None,
                message: None,
                body: Some(body),
                arguments: None,
            },
        )
    }

    fn stop_debugger(&mut self) {
        if let Some(mut backend) = self.backend.take() {
            backend.kill();
        }
    }
}

fn frame_to_json(f: StackFrame) -> serde_json::Value {
    let source = f.file.map(|path| json!({ "path": path }));
    json!({
        "id": f.id,
        "name": f.name,
        "line": f.line,
        "column": f.column,
        "source": source,
    })
}

pub fn run_stdio() -> Result<(), String> {
    DapServer::new().run_stdio()
}
