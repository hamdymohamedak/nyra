import "../http/client.ny"
import "../net/tcp.ny"

struct HttpClient {
    host: string
}

fn HttpClient_new(host: string) -> HttpClient {
    return HttpClient { host: host }
}

impl HttpClient {
    fn get(self, url: string) -> string {
        return http_get(url)
    }
}
