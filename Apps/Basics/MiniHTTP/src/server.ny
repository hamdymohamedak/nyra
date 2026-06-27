fn MiniHTTP_run(){
    let host_in = input("Host [127.0.0.1]: ")
    let host = if strlen(host_in) == 0 { "127.0.0.1" } else { host_in }
    print("Routes: GET /  GET /health  POST /echo")
    print("Try: curl http://127.0.0.1:8080/health")
    serve_loop(host, 8080, 50)
}
