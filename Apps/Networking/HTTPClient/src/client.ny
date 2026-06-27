fn HTTPClient_run(args) {
    let head_only = HTTPClient_has_flag(args, "-I")
    let pooled = HTTPClient_has_flag(args, "-P")
    let n = HTTPClient_arg_count(args)
    if n < 2 {
        print("usage: HTTPClient [-I] [-P] METHOD URL [BODY]")
        return 1
    }
    let method = HTTPClient_arg_at(args, 0)
    let url = HTTPClient_arg_at(args, 1)
    if pooled == 1 && strcmp(method, "GET") == 0 {
        let mut pool = HttpPool_new()
        let r1 = HttpPool_get(pool, url)
        pool = r1.pool
        print(r1.resp.body)
        let r2 = HttpPool_get(pool, url)
        print(strcat("pooled status: ", i32_to_string(r2.resp.status)))
        return 0
    }
    if head_only == 1 || strcmp(method, "HEAD") == 0 {
        let resp = head(url)
        print(strcat("status: ", i32_to_string(resp.status)))
        return 0
    }
    if strcmp(method, "GET") == 0 {
        let body = get(url)
        print(body)
        return 0
    }
    if strcmp(method, "POST") == 0 {
        let payload = if n >= 3 { HTTPClient_arg_at(args, 2) } else { "{}" }
        let resp = post(url, payload)
        print(strcat("status: ", i32_to_string(resp.status)))
        if strlen(resp.body) > 0 {
            print(resp.body)
        }
        return 0
    }
    if strcmp(method, "PUT") == 0 {
        let payload = if n >= 3 { HTTPClient_arg_at(args, 2) } else { "{}" }
        let resp = put(url, payload)
        print(strcat("status: ", i32_to_string(resp.status)))
        return 0
    }
    if strcmp(method, "DELETE") == 0 {
        let resp = delete(url)
        print(strcat("status: ", i32_to_string(resp.status)))
        return 0
    }
    print("unsupported method — try GET POST PUT DELETE HEAD")
    return 1
}

fn HTTPClient_has_flag(args, flag) {
    let n = args.len()
    let mut i = 0
    while i < n {
        if strcmp(args.get(i), flag) == 0 {
            return 1
        }
        i = i + 1
    }
    return 0
}

fn HTTPClient_arg_at(args, index) {
    let n = args.len()
    let mut pos = 0
    let mut i = 0
    while i < n {
        let a = args.get(i)
        if strlen(a) == 0 || char_at(a, 0) != 45 {
            if pos == index {
                return a
            }
            pos = pos + 1
        }
        i = i + 1
    }
    return ""
}

fn HTTPClient_arg_count(args) {
    let n = args.len()
    let mut count = 0
    let mut i = 0
    while i < n {
        let a = args.get(i)
        if strlen(a) == 0 || char_at(a, 0) != 45 {
            count = count + 1
        }
        i = i + 1
    }
    return count
}
