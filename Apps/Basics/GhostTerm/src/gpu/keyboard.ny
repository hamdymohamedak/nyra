import "@root/vendor/bindings/raylib.ny"
import "../shell/spawn.ny"

const KEY_ESCAPE = 256
const KEY_ENTER = 257
const KEY_TAB = 258
const KEY_BACKSPACE = 259
const KEY_DELETE = 261
const KEY_RIGHT = 262
const KEY_LEFT = 263
const KEY_DOWN = 264
const KEY_UP = 265
const KEY_HOME = 268
const KEY_END = 269
const KEY_LEFT_CONTROL = 341
const KEY_RIGHT_CONTROL = 345
const KEY_LEFT_SHIFT = 340
const KEY_RIGHT_SHIFT = 344
const KEY_SPACE = 32
const KEY_C = 67
const KEY_D = 68
const KEY_L = 76
const KEY_Q = 81
const KEY_T = 84
const KEY_W = 87
const KEY_PAGE_UP = 266
const KEY_PAGE_DOWN = 267
const KEY_KP_ENTER = 335

const TAB_ACTION_NONE = 0
const TAB_ACTION_NEW = 1
const TAB_ACTION_PRIVATE = 2
const TAB_ACTION_CLOSE = 3
const TAB_ACTION_NEXT = 4
const TAB_ACTION_PREV = 5

struct GpuInputResult {
    input_line: string
    quit: i32
    sent: i32
    submit: i32
    tab_action: i32
    screen_clear: i32
}

fn GpuKeyboard_idle(input_line) -> GpuInputResult {
    return GpuInputResult { input_line: input_line, quit: 0, sent: 0, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
}

fn GpuKeyboard_ctrl_down(){
    if IsKeyDown(KEY_LEFT_CONTROL) == true || IsKeyDown(KEY_RIGHT_CONTROL) == true {
        return 1
    }
    return 0
}

fn GpuKeyboard_shift_down(){
    if IsKeyDown(KEY_LEFT_SHIFT) == true || IsKeyDown(KEY_RIGHT_SHIFT) == true {
        return 1
    }
    return 0
}

fn GpuKeyboard_send(shell, data){
    PtySession_write(shell.pty, data)
}

fn GpuKeyboard_send_byte(shell, code){
    GpuKeyboard_send(shell, str_push_char("", code))
}

fn GpuKeyboard_push_char(shell, input_line, code){
    let line = str_push_char(input_line, code)
    GpuKeyboard_send(shell, str_push_char("", code))
    return GpuInputResult { input_line: line, quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
}

fn GpuKeyboard_poll_tab_shortcuts() -> GpuInputResult {
    if GpuKeyboard_ctrl_down() == 1 && GpuKeyboard_shift_down() == 1 && IsKeyPressed(KEY_T) == true {
        return GpuInputResult { input_line: "", quit: 0, sent: 0, submit: 0, tab_action: TAB_ACTION_PRIVATE, screen_clear: 0 }
    }
    if GpuKeyboard_ctrl_down() == 1 && IsKeyPressed(KEY_T) == true {
        return GpuInputResult { input_line: "", quit: 0, sent: 0, submit: 0, tab_action: TAB_ACTION_NEW, screen_clear: 0 }
    }
    if GpuKeyboard_ctrl_down() == 1 && IsKeyPressed(KEY_W) == true {
        return GpuInputResult { input_line: "", quit: 0, sent: 0, submit: 0, tab_action: TAB_ACTION_CLOSE, screen_clear: 0 }
    }
    if GpuKeyboard_ctrl_down() == 1 && IsKeyPressed(KEY_PAGE_DOWN) == true {
        return GpuInputResult { input_line: "", quit: 0, sent: 0, submit: 0, tab_action: TAB_ACTION_NEXT, screen_clear: 0 }
    }
    if GpuKeyboard_ctrl_down() == 1 && IsKeyPressed(KEY_PAGE_UP) == true {
        return GpuInputResult { input_line: "", quit: 0, sent: 0, submit: 0, tab_action: TAB_ACTION_PREV, screen_clear: 0 }
    }
    return GpuKeyboard_idle("")
}

fn GpuKeyboard_ctrl_combo(shell, key, byte){
    if GpuKeyboard_ctrl_down() == 1 && IsKeyPressed(key) == true {
        GpuKeyboard_send_byte(shell, byte)
        return 1
    }
    return 0
}

fn GpuKeyboard_key_char(key){
    if key == KEY_SPACE {
        return 32
    }
    if key >= 65 && key <= 90 {
        if GpuKeyboard_shift_down() == 1 {
            return key
        }
        return key + 32
    }
    if key >= 48 && key <= 57 {
        return key
    }
    if key == 45 {
        return 45
    }
    if key == 46 {
        return 46
    }
    if key == 47 {
        return 47
    }
    if key == 61 {
        return 61
    }
    if key == 44 {
        return 44
    }
    if key == 39 {
        return 39
    }
    if key == 59 {
        return 59
    }
    if key == 92 {
        return 92
    }
    return 0
}

fn GpuKeyboard_poll_special(shell, input_line, fullscreen) -> GpuInputResult {
    if GpuKeyboard_ctrl_combo(shell, KEY_C, 3) == 1 {
        return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if GpuKeyboard_ctrl_combo(shell, KEY_D, 4) == 1 {
        return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if GpuKeyboard_ctrl_combo(shell, KEY_L, 12) == 1 {
        return GpuInputResult { input_line: input_line, quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 1 }
    }
    if GpuKeyboard_ctrl_combo(shell, KEY_Q, 17) == 1 {
        return GpuInputResult { input_line: input_line, quit: 1, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if IsKeyPressed(KEY_ENTER) == true {
        GpuKeyboard_send(shell, "\n")
        if fullscreen == 1 {
            return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
        }
        return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 1, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if IsKeyPressed(KEY_KP_ENTER) == true {
        GpuKeyboard_send(shell, "\n")
        if fullscreen == 1 {
            return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
        }
        return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 1, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if IsKeyPressed(KEY_TAB) == true {
        GpuKeyboard_send(shell, "\t")
        return GpuInputResult { input_line: input_line, quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if IsKeyPressed(KEY_BACKSPACE) == true {
        GpuKeyboard_send_byte(shell, 127)
        if fullscreen == 1 {
            return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
        }
        return GpuInputResult { input_line: str_pop(input_line), quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if IsKeyPressedRepeat(KEY_BACKSPACE) == true {
        GpuKeyboard_send_byte(shell, 127)
        if fullscreen == 1 {
            return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
        }
        return GpuInputResult { input_line: str_pop(input_line), quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if IsKeyPressed(KEY_DELETE) == true {
        GpuKeyboard_send(shell, "\x1b[3~")
        return GpuInputResult { input_line: input_line, quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if IsKeyPressed(KEY_ESCAPE) == true {
        GpuKeyboard_send_byte(shell, 27)
        return GpuInputResult { input_line: input_line, quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if IsKeyPressed(KEY_UP) == true {
        GpuKeyboard_send(shell, "\x1b[A")
        return GpuInputResult { input_line: input_line, quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if IsKeyPressed(KEY_DOWN) == true {
        GpuKeyboard_send(shell, "\x1b[B")
        return GpuInputResult { input_line: input_line, quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if IsKeyPressed(KEY_RIGHT) == true {
        GpuKeyboard_send(shell, "\x1b[C")
        return GpuInputResult { input_line: input_line, quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    if IsKeyPressed(KEY_LEFT) == true {
        GpuKeyboard_send(shell, "\x1b[D")
        return GpuInputResult { input_line: input_line, quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    return GpuKeyboard_idle(input_line)
}

fn GpuKeyboard_poll_unicode(shell, input_line, fullscreen) -> GpuInputResult {
    let mut line = input_line
    let mut sent = 0
    let mut ch = GetCharPressed()
    while ch != 0 {
        if ch >= 32 && ch != 127 {
            GpuKeyboard_send(shell, str_push_char("", ch))
            sent = 1
            if fullscreen == 0 {
                line = str_push_char(line, ch)
            }
        }
        ch = GetCharPressed()
    }
    if sent == 1 {
        return GpuInputResult { input_line: line, quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
    }
    return GpuKeyboard_idle(input_line)
}

fn GpuKeyboard_poll_scan(shell, input_line, fullscreen) -> GpuInputResult {
    let mut key = 65
    while key <= 90 {
        if IsKeyPressed(key) == true {
            let code = GpuKeyboard_key_char(key)
            if code >= 32 {
                if fullscreen == 1 {
                    GpuKeyboard_send(shell, str_push_char("", code))
                    return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
                }
                return GpuKeyboard_push_char(shell, input_line, code)
            }
        }
        key = key + 1
    }
    key = 48
    while key <= 57 {
        if IsKeyPressed(key) == true {
            let code = GpuKeyboard_key_char(key)
            if code >= 32 {
                if fullscreen == 1 {
                    GpuKeyboard_send(shell, str_push_char("", code))
                    return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
                }
                return GpuKeyboard_push_char(shell, input_line, code)
            }
        }
        key = key + 1
    }
    if IsKeyPressed(KEY_SPACE) == true {
        if fullscreen == 1 {
            GpuKeyboard_send(shell, " ")
            return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
        }
        return GpuKeyboard_push_char(shell, input_line, 32)
    }
    let pressed = GetKeyPressed()
    if pressed != 0 {
        let code = GpuKeyboard_key_char(pressed)
        if code >= 32 {
            if fullscreen == 1 {
                GpuKeyboard_send(shell, str_push_char("", code))
                return GpuInputResult { input_line: "", quit: 0, sent: 1, submit: 0, tab_action: TAB_ACTION_NONE, screen_clear: 0 }
            }
            return GpuKeyboard_push_char(shell, input_line, code)
        }
    }
    return GpuKeyboard_idle(input_line)
}

fn GpuKeyboard_poll(shell: ShellSession, input_line: string, fullscreen: i32) -> GpuInputResult {
    if IsWindowFocused() == false {
        return GpuKeyboard_idle(input_line)
    }
    let tabs = GpuKeyboard_poll_tab_shortcuts()
    if tabs.tab_action != TAB_ACTION_NONE {
        return tabs
    }
    let special = GpuKeyboard_poll_special(shell, input_line, fullscreen)
    if special.sent == 1 || special.quit == 1 {
        return special
    }
    if GpuKeyboard_ctrl_down() == 1 {
        return GpuKeyboard_idle(input_line)
    }
    let unicode = GpuKeyboard_poll_unicode(shell, input_line, fullscreen)
    if unicode.sent == 1 {
        return unicode
    }
    return GpuKeyboard_poll_scan(shell, input_line, fullscreen)
}
