// run-stdout: 0

fn main() {
    let mut cmd = Command_new("true")
    let code = cmd.run()
    print(code)
}
