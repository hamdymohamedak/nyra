fn http_status(method: string) -> i32 {
    return match method {
        "GET" => 200,
        "POST" => 201,
        "DELETE" => 204,
        _ => 404,
    }
}

fn main() -> void {
    print(http_status("GET"))
    print(http_status("POST"))
    print(http_status("PATCH"))
}
