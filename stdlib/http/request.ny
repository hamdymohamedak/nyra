import "../strings.ny"

fn parse_i32_digits(s: string) -> i32 {
    let mut n = 0
    let mut i = 0
    let len = strlen(s)
    while i < len {
        let c = char_at(s, i)
        if c >= 48 && c <= 57 {
            n = n * 10 + (c - 48)
        }
        i = i + 1
    }
    return n
}

struct HttpUrl {
    host: string
    port: i32
    path: string
    secure: bool
}

fn find_host_end(url: string, start: i32, n: i32) -> i32 {
    let mut host_end = start
    while host_end < n {
        let c = char_at(url, host_end)
        if c == 58 || c == 47 {
            return host_end
        }
        host_end = host_end + 1
    }
    return host_end
}

fn find_port_end(url: string, port_start: i32, n: i32) -> i32 {
    let mut port_end = port_start
    while port_end < n {
        let c = char_at(url, port_end)
        if c == 47 {
            return port_end
        }
        port_end = port_end + 1
    }
    return port_end
}

fn parse_http_url(url: string) -> HttpUrl {
    let mut i = 0
    let n = strlen(url)
    let mut secure = false
    if n >= 8 {
        if strcmp(substring(url, 0, 8), "https://") == 0 {
            secure = true
            i = 8
        }
    }
    if !secure && n >= 7 {
        if strcmp(substring(url, 0, 7), "http://") == 0 {
            i = 7
        }
    }
    let mut host = "localhost"
    let mut port = 80
    if secure {
        port = 443
    }
    let mut path = "/"
    let host_end = find_host_end(url, i, n)
    if host_end > i {
        host = substring(url, i, host_end - i)
    }
    let mut path_start = host_end
    if host_end < n && char_at(url, host_end) == 58 {
        let port_start = host_end + 1
        let port_end = find_port_end(url, port_start, n)
        let port_str = substring(url, port_start, port_end - port_start)
        port = parse_i32_digits(port_str)
        if port == 0 {
            if secure {
                port = 443
            } else {
                port = 80
            }
        }
        path_start = port_end
    }
    if path_start < n && char_at(url, path_start) == 47 {
        path = substring(url, path_start, n - path_start)
    }
    return HttpUrl { host: host, port: port, path: path, secure: secure }
}

fn parse_request_line(line: string) -> i32 {
    if strlen(line) < 3 {
        return 0
    }
    if strcmp(substring(line, 0, 3), "GET") == 0 {
        return 1
    }
    return 0
}
