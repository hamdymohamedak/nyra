import "strings.ny"
import "io.ny"

extern fn stdout_writeln_str(s: string) -> void

fn log_info(msg: string) -> void {
    let line = strcat("[info] ", msg)
    stdout_writeln_str(line)
}

fn log_warn(msg: string) -> void {
    let line = strcat("[warn] ", msg)
    stdout_writeln_str(line)
}

fn log_error(msg: string) -> void {
    let line = strcat("[error] ", msg)
    stdout_writeln_str(line)
}
