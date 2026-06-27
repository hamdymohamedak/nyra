// `progress for` prints a live progress bar and status line — zero boilerplate.
extern fn blackbox_i32(x: i32) -> i32

fn run(name: string) {
    blackbox_i32(name.length())
}

fn main() {
    let tests = ["lexer", "parser", "types", "codegen", "cli"]
    progress(label = "parser tests") for item in tests {
        run(item)
    }

    progress for i in 0..10 {
        blackbox_i32(i)
    }

    print(0)
}
