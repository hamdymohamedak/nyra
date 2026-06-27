import "vendor/bindings/raylib.ny"

fn main() {
    InitWindow(800, 450, "Nyra Graphics Engine with Raylib")
    SetTargetFPS(60)

    let r: u8 = 255
    let g: u8 = 255
    let b: u8 = 255
    let a: u8 = 255
    let white = Color { r: r, g: g, b: b, a: a }
    let r2: u8 = 255
    let g2: u8 = 0
    let b2: u8 = 0
    let a2: u8 = 255
    let red = Color { r: r2, g: g2, b: b2, a: a2 }

    while !WindowShouldClose() {
        BeginDrawing()
        ClearBackground(white)
        DrawText("Congrats! Nyra is Drawing Graphics!", 140, 200, 20, red)
        DrawCircle(400, 300, 50.0, red)
        EndDrawing()
    }

    CloseWindow()
}
