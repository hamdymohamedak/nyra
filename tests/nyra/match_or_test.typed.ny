enum Color {
    Red
    Green
    Blue
}

fn main() {
    let c: Color = Color.Red
    let n: i32 = match c {
        Color.Red | Color.Blue => 1
        Color.Green => 2
    }
    print(n)
    let method: string = "POST"
    let code: i32 = match method {
        "GET" | "HEAD" => 200
        "POST" | "PUT" => 201
        _ => 400
    }
    print(code)
}
