// Run external programs — like Rust std::process::Command (POSIX MVP).
// nyra run examples/process_command.ny

fn main() {
    let code = Command_new("true").run()
    print(code)

    let ls = Command_new("ls").arg("-la").arg("/tmp").run()
    print(ls)

    let sh = Command_new("/bin/sh").arg("-c").arg("echo hello from sh").run()
    print(sh)
}
