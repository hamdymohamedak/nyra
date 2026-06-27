fn Cli_usage(tool, text) {
    print(strcat(strcat("usage: ", tool), text))
}

fn PortScanner_probe(host, port) {
    let stream = tcp_connect_timeout(host, port, 800)
    if stream.fd >= 0 {
        tcp_close_stream(stream)
        return 1
    }
    return 0
}

fn PortScanner_run(args) {
    let n = args.len()
    if n < 3 {
        Cli_usage("PortScanner", " HOST START_PORT END_PORT")
        return 1
    }
    let host = args.get(0)
    let start = str_to_i32(args.get(1))
    let end = str_to_i32(args.get(2))
    if end < start {
        print("end port must be >= start port")
        return 1
    }
    print(strcat(strcat("scanning ", host), " (800ms timeout per port)"))
    let mut port = start
    let mut open_count = 0
    while port <= end {
        if PortScanner_probe(host, port) == 1 {
            print(strcat("open ", i32_to_string(port)))
            open_count = open_count + 1
        }
        port = port + 1
    }
    print(strcat("done — open ports: ", i32_to_string(open_count)))
    return 0
}
