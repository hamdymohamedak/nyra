// Capture stdout/stderr from a subprocess — exec() / Command.output().
// nyra run examples/process_exec.ny

fn main() {
    let args = StrVec_new().push("-c").push("echo hello-from-exec")
    let out = exec("/bin/sh", args)
    print(out.code)
    print(out.stdout)
}
