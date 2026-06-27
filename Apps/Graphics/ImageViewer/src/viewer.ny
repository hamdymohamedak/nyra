import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

fn ImageViewer_load_texture(path) {
    let blank = GenImageColor(64, 64, Gfx_color(40, 40, 40, 0xff))
    let mut tex = LoadTextureFromImage(blank)
    if path != "" && exists(path) == 1 {
        let img = LoadImage(path)
        tex = LoadTextureFromImage(img)
        UnloadImage(img)
    }
    return tex
}

fn ImageViewer_run(args) {
    let path = if args.len() == 1 { args.get(0) } else { "" }
    Gfx_window_open(800, 600, "Image Viewer")
    let mut tex = ImageViewer_load_texture(path)
    let mut zoom = 1.0
    let white = Gfx_color(0xff, 0xff, 0xff, 0xff)
    let hint = Gfx_color(200, 200, 200, 0xff)
    while !WindowShouldClose() {
        if IsKeyPressed(61) {
            zoom = zoom + 0.1
        }
        if IsKeyPressed(45) {
            zoom = zoom - 0.1
        }
        if zoom < 0.25 {
            zoom = 0.25
        }
        if zoom > 4.0 {
            zoom = 4.0
        }
        Gfx_frame_begin(Gfx_color(20, 20, 30, 0xff))
        let tw = tex.width
        let th = tex.height
        let sw = tw * zoom
        let sh = th * zoom
        let x = (800.0 - sw) / 2.0
        let y = (600.0 - sh) / 2.0
        DrawTextureEx(tex, Vector2 { x: x, y: y }, 0.0, zoom, white)
        DrawText("+/- zoom  ESC close", 10, 10, 16, hint)
        Gfx_frame_end()
    }
    UnloadTexture(tex)
    Gfx_window_close()
    return 0
}
