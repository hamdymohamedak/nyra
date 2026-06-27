// Legacy entry — re-exports Core stdlib/net/http (client + raw server).
import "../net/http/mod.ny"
import "../net/http/server.ny"

struct HttpServer {
    host: string
    port: i32
}

fn HttpServer_new(host: string, port: i32) -> HttpServer {
    return HttpServer { host: host, port: port }
}

impl HttpServer {
    fn listen_once(self, body: string) -> i32 {
        return serve_once(self.host, self.port, body)
    }
}
