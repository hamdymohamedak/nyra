import "../strings.ny"
import "../io.ny"
import "../strconv/mod.ny"

enum LogLevel {
    Debug,
    Info,
    Warn,
    Error,
}

fn slog_level_name(level: LogLevel) -> string {
    if level == LogLevel.Debug {
        return "DEBUG"
    }
    if level == LogLevel.Info {
        return "INFO"
    }
    if level == LogLevel.Warn {
        return "WARN"
    }
    return "ERROR"
}

fn slog_json_line(level: LogLevel, msg: string, key: string, value: string) -> string {
    let lvl = slog_level_name(level)
    return strcat(
        strcat(
            strcat(
                strcat(strcat("{\"level\":\"", lvl), strcat("\",\"msg\":\"", msg)),
                strcat("\",\"", key)
            ),
            strcat("\":\"", value)
        ),
        "\"}"
    )
}

fn slog_info(msg: string) -> void {
    stdout_writeln_str(slog_json_line(LogLevel.Info, msg, "ts", format_i32(0)))
}

fn slog_info_kv(msg: string, key: string, value: string) -> void {
    stdout_writeln_str(slog_json_line(LogLevel.Info, msg, key, value))
}

fn slog_warn(msg: string) -> void {
    stdout_writeln_str(slog_json_line(LogLevel.Warn, msg, "ts", format_i32(0)))
}

fn slog_error(msg: string) -> void {
    stdout_writeln_str(slog_json_line(LogLevel.Error, msg, "ts", format_i32(0)))
}

fn slog_debug(msg: string) -> void {
    stdout_writeln_str(slog_json_line(LogLevel.Debug, msg, "ts", format_i32(0)))
}
