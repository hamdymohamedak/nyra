// raygui widgets — requires `link raylib` and `nyra pkg c add raygui`.
// Define RAYGUI_IMPLEMENTATION in a project C file or use raylib's raygui amalgamation.

struct Rectangle repr(C) {
    x: f64
    y: f64
    width: f64
    height: f64
}

struct Vector2 repr(C) {
    x: f64
    y: f64
}

extern fn GuiEnable() -> void
extern fn GuiDisable() -> void
extern fn GuiButton(bounds: Rectangle, text: string) -> i32
extern fn GuiLabel(bounds: Rectangle, text: string) -> void
extern fn GuiTextBox(bounds: Rectangle, text: string, max_len: i32) -> i32
extern fn GuiCheckBox(bounds: Rectangle, text: string, checked: ptr) -> i32
extern fn GuiSlider(bounds: Rectangle, text_left: string, text_right: string, value: ptr, min_val: f64, max_val: f64) -> i32
extern fn GuiDropdownBox(bounds: Rectangle, text: string, active: ptr, edit_mode: i32) -> i32
extern fn GuiListView(bounds: Rectangle, text: string, scroll_index: ptr, active: ptr) -> i32

fn Raygui_rect(x, y, w, h) {
    return Rectangle { x: x, y: y, width: w, height: h }
}

fn Raygui_button(x, y, w, h, label) {
    return GuiButton(Raygui_rect(x, y, w, h), label)
}

fn Raygui_label(x, y, w, h, label) {
    GuiLabel(Raygui_rect(x, y, w, h), label)
}

fn Raygui_text_box(x, y, w, h, text, max_len) {
    return GuiTextBox(Raygui_rect(x, y, w, h), text, max_len)
}

fn Raygui_enable() {
    GuiEnable()
}

fn Raygui_disable() {
    GuiDisable()
}
