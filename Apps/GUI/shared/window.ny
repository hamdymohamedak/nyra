fn Gfx_window_open(width, height, title) {
    InitWindow(width, height, title)
    SetTargetFPS(60)
}

fn Gfx_window_close() {
    CloseWindow()
}

fn Gfx_frame_begin(bg) {
    BeginDrawing()
    ClearBackground(bg)
}

fn Gfx_frame_end() {
    EndDrawing()
}
