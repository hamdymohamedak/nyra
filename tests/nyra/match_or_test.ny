enum Color {
    Red
    Green
    Blue
}

fn main() {
    let c = Color.Red
    let n = match c {
        Color.Red | Color.Blue => 1
        Color.Green => 2
    }
    print(n)
    let method = "POST"
    let code = match method {
        "GET" | "HEAD" => 200
        "POST" | "PUT" => 201
        _ => 400
    }
    print(code)
}
