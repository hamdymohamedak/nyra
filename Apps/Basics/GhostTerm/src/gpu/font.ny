import "@root/vendor/bindings/raylib.ny"

extern fn gpu_font_init() -> void
extern fn gpu_font_draw(text: string, x: i32, y: i32, size: i32, r: u8, g: u8, b: u8, a: u8) -> void
extern fn gpu_font_free() -> void

fn GpuFont_init(){
    gpu_font_init()
}

fn GpuFont_draw(text, x, y, size, color){
    gpu_font_draw(text, x, y, size, color.r, color.g, color.b, color.a)
}

fn GpuFont_unload(){
    gpu_font_free()
}
