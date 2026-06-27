use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Debug, Serialize, Deserialize)]
pub struct DapMessage {
    pub seq: u64,
    #[serde(rename = "type")]
    pub type_: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub request_seq: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub command: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub event: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub success: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub message: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub body: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub arguments: Option<Value>,
}

#[derive(Debug, Deserialize)]
pub struct LaunchArgs {
    pub program: String,
    #[serde(default)]
    pub cwd: Option<String>,
    #[serde(default)]
    pub args: Vec<String>,
    #[serde(rename = "stopOnEntry", default)]
    pub stop_on_entry: bool,
    #[serde(rename = "debugger", default)]
    pub debugger: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct SetBreakpointsArgs {
    pub source: SourceRef,
    #[serde(default)]
    pub lines: Vec<i64>,
    #[serde(default)]
    pub breakpoints: Vec<BreakpointReq>,
}

#[derive(Debug, Deserialize)]
pub struct BreakpointReq {
    #[serde(default)]
    pub line: i64,
}

#[derive(Debug, Deserialize)]
pub struct SourceRef {
    #[serde(default)]
    pub path: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct VariablesArgs {
    #[serde(rename = "variablesReference")]
    pub variables_reference: i64,
}

#[derive(Debug, Deserialize)]
pub struct SourceArgs {
    pub source: SourceRef,
}
