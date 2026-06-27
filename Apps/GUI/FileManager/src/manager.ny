import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"
import "../../shared/widgets.ny"

const PREVIEW_LIMIT = 65536

fn Fm_draw_picker(x, y, w, picker) {
    let n = picker.entries.len()
    let mut i = 0
    while i < n && i < 18 {
        let name = picker.entries.get(i)
        let full = FilePicker_join(picker.cwd, name)
        let ry = y + i * 28
        let mut bg = Gfx_color(42, 42, 48, 0xff)
        if strcmp(full, picker.selected) == 0 || strcmp(name, picker.selected) == 0 {
            bg = Gfx_color(70, 110, 180, 0xff)
        }
        let mut label = name
        if is_dir(full) == 1 {
            label = strcat(name, "/")
        }
        Gui_button_draw(x, ry, w, 24, label, bg, Gfx_color(60, 60, 70, 0xff), Gfx_color(235, 235, 240, 0xff))
        i = i + 1
    }
}

fn Fm_row_clicked(x: i32, y: i32, w: i32, index: i32) -> i32 {
    return Gui_button_clicked(x, y + index * 28, w, 24)
}

fn FileManager_run(args) {
    let start = if args.len() == 1 { args.get(0) } else { "." }
    let mut picker = FilePicker_open(start)
    let mut preview = "Select a file to preview."
    let mut scroll = ScrollState_new(28)
    let bg = Gfx_color(32, 32, 36, 0xff)
    let panel = Gfx_color(24, 24, 28, 0xff)
    let border = Gfx_color(70, 70, 80, 0xff)
    let ink = Gfx_color(230, 230, 235, 0xff)
    let hint = Gfx_color(120, 120, 130, 0xff)
    Gfx_window_open(960, 640, "File Manager")
    while !WindowShouldClose() {
        if Gui_button_clicked(16, 12, 80, 28) == 1 {
            picker = FilePicker_up(picker)
            preview = "Select a file to preview."
        }
        if Gui_button_clicked(110, 12, 120, 28) == 1 {
            let path = FilePicker_selected_path(picker)
            if strlen(path) > 0 && exists(path) == 1 && is_dir(path) == 0 {
                preview = read_file_limit(path, PREVIEW_LIMIT)
            }
        }
        let mut count = picker.entries.len()
        if count > 18 {
            count = 18
        }
        let mut i = 0
        while i < count {
            if Fm_row_clicked(16, 56, 300, i) == 1 {
                picker = FilePicker_pick(picker, i)
                let path = FilePicker_selected_path(picker)
                if strlen(path) > 0 && is_dir(path) == 0 {
                    preview = read_file_limit(path, PREVIEW_LIMIT)
                } else {
                    preview = "Opened directory."
                }
            }
            i = i + 1
        }
        if IsKeyPressed(265) {
            scroll = ScrollState_scroll(scroll, -1, StrVec_from_lines(preview).len())
        }
        if IsKeyPressed(264) {
            scroll = ScrollState_scroll(scroll, 1, StrVec_from_lines(preview).len())
        }
        Gfx_frame_begin(bg)
        Gui_button_draw(16, 12, 80, 28, "Up", Gfx_color(58, 58, 66, 0xff), border, ink)
        Gui_button_draw(110, 12, 120, 28, "Open", Gfx_color(70, 130, 200, 0xff), border, ink)
        Gui_label(250, 18, strcat("cwd: ", picker.cwd), 16, hint)
        Gui_panel(16, 56, 300, 560, panel, border)
        Fm_draw_picker(16, 56, 300, picker)
        Gui_panel(336, 56, 608, 560, panel, border)
        Gui_text_area_draw_scrolled(352, 72, 576, 528, preview, scroll, Gfx_color(18, 18, 22, 0xff), border, ink)
        Gfx_frame_end()
    }
    Gfx_window_close()
    return 0
}
