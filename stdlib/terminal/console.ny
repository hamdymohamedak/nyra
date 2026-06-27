import "../io.ny"
import "../strings.ny"

const ANSI_RESET = "\033[0m"
const ANSI_RED = "\033[31m"
const ANSI_GREEN = "\033[32m"
const ANSI_YELLOW = "\033[33m"
const ANSI_BLUE = "\033[34m"

fn console_red(msg: string) -> void {
    let line = strcat(strcat(ANSI_RED, msg), ANSI_RESET)
    stdout_writeln_str(line)
}

fn console_green(msg: string) -> void {
    let line = strcat(strcat(ANSI_GREEN, msg), ANSI_RESET)
    stdout_writeln_str(line)
}

fn console_yellow(msg: string) -> void {
    let line = strcat(strcat(ANSI_YELLOW, msg), ANSI_RESET)
    stdout_writeln_str(line)
}

fn console_blue(msg: string) -> void {
    let line = strcat(strcat(ANSI_BLUE, msg), ANSI_RESET)
    stdout_writeln_str(line)
}
