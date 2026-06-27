import "../net/http/client.ny"

fn http_get(url: string) -> string {
    return get(url)
}

fn fetch(url: string) -> string {
    return get(url)
}
