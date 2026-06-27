import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

fn PDFViewer_run(args) {
    let path = if args.len() == 1 { args.get(0) } else { "sample.txt" }
    let mut text = "PDF Viewer\nLoad a .txt file as scrollable pages.\nLine 3\nLine 4"
    if exists(path) == 1 {
        text = read_file(path)
    }
    let lines = StrVec_from_lines(text)
    Gfx_window_open(800, 600, "PDF Viewer")
    let mut scroll = 0
    while !WindowShouldClose() {
        if IsKeyPressed(265) {
            scroll = scroll - 1
        }
        if IsKeyPressed(264) {
            scroll = scroll + 1
        }
        if scroll < 0 {
            scroll = 0
        }
        Gfx_frame_begin(Gfx_color(240, 240, 235, 0xff))
        DrawRectangle(80, 40, 640, 520, Gfx_color(0xff, 0xff, 0xff, 0xff))
        let n = lines.len()
        let mut i = 0
        let mut row = 0
        while i < n {
            if i >= scroll && row < 24 {
                let y = 60 + row * 20
                DrawText(lines.get(i), 100, y, 16, Gfx_color(30, 30, 30, 0xff))
                row = row + 1
            }
            i = i + 1
        }
        DrawText("up/down scroll", 10, 10, 14, Gfx_color(60, 60, 60, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
    return 0
}
