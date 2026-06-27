fn HashMap_run(){
    let mut scores = HashMap_str_i32_new()
    scores = scores.insert("alice", 95)
    scores = scores.insert("bob", 87)
    scores = scores.insert("carol", 91)
    print(`alice: ${scores.get("alice")}`)
    print(`bob: ${scores.get("bob")}`)
    print(`carol: ${scores.get("carol")}`)
    print(`has dave: ${scores.contains("dave")}`)
    print(`has bob: ${scores.contains("bob")}`)
}
