import "../http/request.ny"

struct Url {
    raw: string
    host: string
    port: i32
    path: string
    query: string
}

fn Url_parse(raw: string) -> Url {
    let p = parse_http_url(raw)
    return Url { raw: raw, host: p.host, port: p.port, path: p.path, query: "" }
}

impl Url {
    fn host(self) -> string {
        return self.host
    }

    fn path(self) -> string {
        return self.path
    }

    fn query(self) -> string {
        return self.query
    }

    fn port(self) -> i32 {
        return self.port
    }
}

fn url_host(raw: string) -> string {
    let u = Url_parse(raw)
    return u.host
}

fn url_path(raw: string) -> string {
    let u = Url_parse(raw)
    return u.path
}
