
extern fn http_get(url: string) -> string

fn Curl_head(url) {
    let body = http_get(url)
    print(strcat("bytes: ", i32_to_string(strlen(body))))
}

fn Curl_run(args) {
    let show_head = Cli_has_flag(args, "-I")
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if n == 0 {
        Cli_usage("curl", " [-I] url")
        return 1
    }
    let url = paths.get(n - 1)
    if show_head == 1 {
        Curl_head(url)
        return 0
    }
    let body = http_get(url)
    if strlen(body) == 0 {
        print("curl: empty response or request failed")
        return 1
    }
    print(body)
    return 0
}
