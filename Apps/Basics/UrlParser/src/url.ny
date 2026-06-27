struct ParsedUrl {
    scheme: string
    host: string
    port: i32
    path: string
    query: string
}

fn Url_default_port(scheme){
    if strcmp(scheme, "https") == 0 {
        return 443
    }
    if strcmp(scheme, "http") == 0 {
        return 80
    }
    return 0
}

fn Url_find_char(s, ch){
    let len = strlen(s)
    let mut i = 0
    while i < len {
        if char_at(s, i) == ch {
            return i
        }
        i = i + 1
    }
    return -1
}

fn Url_parse(raw){
    let raw_len = strlen(raw)
    let marker = strstr_pos(raw, "://")
    let scheme = if marker >= 0 { substring(raw, 0, marker) } else { "" }
    let rest = if marker >= 0 {
        substring(raw, marker + 3, raw_len - marker - 3)
    } else {
        raw
    }
    let slash = Url_find_char(rest, 47)
    let qmark = Url_find_char(rest, 63)
    let host_port = if slash < 0 {
        if qmark < 0 { rest } else { substring(rest, 0, qmark) }
    } else {
        substring(rest, 0, slash)
    }
    let colon = Url_find_char(host_port, 58)
    let mut host = host_port
    let mut port = Url_default_port(scheme)
    if colon >= 0 {
        host = substring(host_port, 0, colon)
        port = str_to_i32(substring(host_port, colon + 1, strlen(host_port) - colon - 1))
    }
    let mut path = "/"
    let mut query = ""
    if slash >= 0 {
        let path_part = if qmark < 0 {
            substring(rest, slash, strlen(rest) - slash)
        } else {
            substring(rest, slash, qmark - slash)
        }
        path = path_part
        if qmark >= 0 {
            query = substring(rest, qmark + 1, strlen(rest) - qmark - 1)
        }
    }
    return ParsedUrl {
        scheme: scheme,
        host: host,
        port: port,
        path: path,
        query: query,
    }
}

fn Url_print(u){
    print(`scheme: ${u.scheme}`)
    print(`host:   ${u.host}`)
    print(`port:   ${u.port}`)
    print(`path:   ${u.path}`)
    print(`query:  ${u.query}`)
}

fn Url_usage(){
    print("usage: urlparse <url>")
}

fn Url_run(args){
    if args.len() != 1 {
        Url_usage()
        return 1
    }
    Url_print(Url_parse(args.get(0)))
    return 0
}
