fn Ping_usage() {
    print("usage: Ping HOST [PORT]")
}

fn Ping_run(args) {
    let n = args.len()
    if n < 1 {
        Ping_usage()
        return 1
    }
    let host = args.get(0)
    let port = if n >= 2 { str_to_i32(args.get(1)) } else { 80 }
    print("ping_auto_verbose: ICMP when root, else TCP with hint")
    let mut i = 0
    let mut ok = 0
    while i < 4 {
        let ms = ping_auto_verbose(host, port, 3000)
        if ms >= 0 {
            print(strcat(strcat(strcat(host, ":"), i32_to_string(port)), strcat(" ", strcat(i32_to_string(ms), "ms"))))
            ok = ok + 1
        } else {
            print(strcat(strcat("unreachable ", host), strcat(":", i32_to_string(port))))
        }
        i = i + 1
    }
    if ok == 0 {
        return 1
    }
    return 0
}
