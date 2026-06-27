import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"
import "../../shared/widgets.ny"

const NOTE_MAX = 2048
const NOTE_STORE = "notes.txt"

fn NoteApp_load() {
    if exists(NOTE_STORE) == 0 {
        return "Welcome to Note App.\nEdit and press Save."
    }
    return read_file(NOTE_STORE)
}

fn NoteApp_run() {
    let mut text = NoteApp_load()
    let mut status = "Ready"
    let bg = Gfx_color(34, 34, 38, 0xff)
    let area = Gfx_color(24, 24, 28, 0xff)
    let border = Gfx_color(75, 75, 85, 0xff)
    let ink = Gfx_color(235, 235, 240, 0xff)
    let hint = Gfx_color(120, 120, 130, 0xff)
    Gfx_window_open(720, 560, "Note App")
    while !WindowShouldClose() {
        text = Gui_text_poll(text, NOTE_MAX)
        if Gui_button_clicked(16, 12, 88, 32) == 1 {
            write_file(NOTE_STORE, text)
            status = "Saved to notes.txt"
        }
        if Gui_button_clicked(116, 12, 88, 32) == 1 {
            text = ""
            status = "Cleared"
        }
        if Gui_button_clicked(216, 12, 88, 32) == 1 {
            text = NoteApp_load()
            status = "Reloaded"
        }
        Gfx_frame_begin(bg)
        Gui_button_draw(16, 12, 88, 32, "Save", Gfx_color(70, 130, 200, 0xff), border, ink)
        Gui_button_draw(116, 12, 88, 32, "Clear", Gfx_color(200, 90, 90, 0xff), border, ink)
        Gui_button_draw(216, 12, 88, 32, "Reload", Gfx_color(58, 58, 66, 0xff), border, ink)
        Gui_label(320, 20, status, 16, hint)
        Gui_text_area_draw(16, 56, 688, 488, text, area, border, ink)
        Gfx_frame_end()
    }
    Gfx_window_close()
}
