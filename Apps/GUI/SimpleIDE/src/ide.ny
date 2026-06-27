import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"
import "../../shared/widgets.ny"

const IDE_MAX = 4096

fn Ide_list_source_files(dir) {
    let entries = list_dir_entries(dir)
    let mut out = StrVec_new()
    let n = entries.len()
    let mut i = 0
    while i < n {
        let name = entries.get(i)
        let full = Gui_path_join(dir, name)
        if is_dir(full) == 0 {
            let dot = strstr_pos(name, ".")
            if dot >= 0 {
                let ext = substring(name, dot, strlen(name) - dot)
                if strcmp(ext, ".ny") == 0 {
                    out.push(name)
                }
            }
        }
        i = i + 1
    }
    return out
}

fn Ide_row_clicked(x: i32, y: i32, index: i32) -> i32 {
    return Gui_button_clicked(x, y + index * 28, 220, 24)
}

fn Ide_file_count(files: StrVec) -> i32 {
    let n = files.len()
    if n > 16 {
        return 16
    }
    return n
}

fn Ide_draw_files(x, y, files, active) {
    let n = files.len()
    let mut i = 0
    while i < n && i < 16 {
        let name = files.get(i)
        let mut bg = Gfx_color(42, 42, 48, 0xff)
        if strcmp(name, active) == 0 {
            bg = Gfx_color(70, 110, 180, 0xff)
        }
        Gui_button_draw(x, y + i * 28, 220, 24, name, bg, Gfx_color(60, 60, 70, 0xff), Gfx_color(235, 235, 240, 0xff))
        i = i + 1
    }
}

fn SimpleIDE_run(args) {
    let root = if args.len() == 1 { args.get(0) } else { "." }
    let mut files = Ide_list_source_files(root)
    let mut active = if files.len() > 0 { files.get(0) } else { "" }
    let mut path = if strlen(active) > 0 { Gui_path_join(root, active) } else { "" }
    let mut text = if strlen(path) > 0 && exists(path) == 1 { read_file_limit(path, IDE_MAX) } else { "// open a .ny file from the sidebar\n" }
    let mut status = "Simple IDE"
    let mut scroll = ScrollState_new(30)
    let bg = Gfx_color(28, 28, 32, 0xff)
    let panel = Gfx_color(22, 22, 26, 0xff)
    let border = Gfx_color(70, 70, 80, 0xff)
    let ink = Gfx_color(220, 230, 240, 0xff)
    let keyword = Gfx_color(120, 170, 255, 0xff)
    let string_c = Gfx_color(180, 220, 140, 0xff)
    let comment = Gfx_color(140, 150, 160, 0xff)
    let number_c = Gfx_color(220, 180, 120, 0xff)
    let hint = Gfx_color(120, 120, 130, 0xff)
    Gfx_window_open(1000, 680, "Simple IDE")
    while !WindowShouldClose() {
        files = Ide_list_source_files(root)
        let n = Ide_file_count(files)
        let mut i = 0
        while i < n {
            if Ide_row_clicked(16, 96, i) == 1 {
                active = files.get(i)
                path = Gui_path_join(root, active)
                if exists(path) == 1 {
                    text = read_file_limit(path, IDE_MAX)
                    status = strcat("Opened ", active)
                    scroll = ScrollState_new(30)
                }
            }
            i = i + 1
        }
        text = Gui_text_poll(text, IDE_MAX)
        if Gui_button_clicked(16, 12, 88, 32) == 1 && strlen(path) > 0 {
            write_file(path, text)
            status = strcat("Saved ", active)
        }
        if IsKeyDown(341) && IsKeyPressed(83) && strlen(path) > 0 {
            write_file(path, text)
            status = strcat("Saved ", active)
        }
        if IsKeyPressed(265) {
            scroll = ScrollState_scroll(scroll, -1, StrVec_from_lines(text).len())
        }
        if IsKeyPressed(264) {
            scroll = ScrollState_scroll(scroll, 1, StrVec_from_lines(text).len())
        }
        Gfx_frame_begin(bg)
        Gui_button_draw(16, 12, 88, 32, "Save", Gfx_color(70, 130, 200, 0xff), border, ink)
        Gui_label(120, 20, strcat("project: ", root), 16, hint)
        Gui_label(120, 40, status, 14, hint)
        Gui_panel(16, 80, 236, 580, panel, border)
        Ide_draw_files(16, 96, files, active)
        Gui_text_area_syntax_draw(268, 80, 716, 580, text, scroll, Gfx_color(16, 16, 20, 0xff), border, ink, keyword, string_c, comment, number_c)
        Gfx_frame_end()
    }
    Gfx_window_close()
    return 0
}
