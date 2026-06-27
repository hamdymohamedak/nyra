use std::io::{BufRead, Write};

use serde_json;

use crate::protocol::DapMessage;

pub fn read_message<R: BufRead>(reader: &mut R) -> Result<Option<DapMessage>, String> {
    let mut content_length = 0usize;
    loop {
        let mut line = String::new();
        let n = reader.read_line(&mut line).map_err(|e| e.to_string())?;
        if n == 0 {
            return Ok(None);
        }
        let line = line.trim_end();
        if line.is_empty() {
            break;
        }
        if let Some(rest) = line.strip_prefix("Content-Length: ") {
            content_length = rest.parse().map_err(|e| format!("bad Content-Length: {e}"))?;
        }
    }
    if content_length == 0 {
        return Ok(None);
    }
    let mut body = vec![0u8; content_length];
    reader
        .read_exact(&mut body)
        .map_err(|e| e.to_string())?;
    let msg: DapMessage = serde_json::from_slice(&body).map_err(|e| e.to_string())?;
    Ok(Some(msg))
}

pub fn write_message<W: Write>(writer: &mut W, msg: &DapMessage) -> Result<(), String> {
    let body = serde_json::to_string(msg).map_err(|e| e.to_string())?;
    write!(writer, "Content-Length: {}\r\n\r\n{}", body.len(), body)
        .map_err(|e| e.to_string())?;
    writer.flush().map_err(|e| e.to_string())
}
