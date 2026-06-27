// run-stdout: ok

fn main() {
    let mut log = StrVec_new()
    log = log.push("a")
    log = log.push("b")
    log = log.push("c")
    if log.len() == 3 {
        print("ok")
    }
}
