// Language gaps fixed in v1.17.0 (zero-types).

extern fn instant_now() -> i64

fn test_i64_to_string() {
    let ts = instant_now()
    let text = i64_to_string(ts)
    if strlen(text) == 0 {
        print("fail i64_to_string")
    }
}

fn dispatch(cmd) {
    return match cmd {
        "GET" => 1,
        "POST" => 2,
        _ => 0,
    }
}

fn test_match_string() {
    if dispatch("GET") != 1 {
        print("fail match GET")
    }
    if dispatch("POST") != 2 {
        print("fail match POST")
    }
    if dispatch("PUT") != 0 {
        print("fail match default")
    }
}

struct SourceLoc {
    file: string
    line: i32
    col: i32
}

struct ParseCursor {
    text: string
    pos: i32
    loc: SourceLoc
}

fn ParseCursor_advance(cur) {
    return ParseCursor {
        text: cur.text,
        pos: cur.pos + 1,
        loc: cur.loc
    }
}

fn test_struct_return_nested() {
    let loc = SourceLoc { file: "main.ny", line: 10, col: 4 }
    let c = ParseCursor { text: "ab", pos: 0, loc: loc }
    let c2 = ParseCursor_advance(c)
    if c2.pos != 1 {
        print("fail struct return pos", c2.pos)
    }
    if c2.loc.line != 10 {
        print("fail struct return nested", c2.loc.line)
    }
}

struct Point {
    x: i32
    y: i32
}

fn use_point(p) {
    return p.x + p.y
}

fn test_struct_inference_cross_fn() {
    let total = use_point(Point { x: 3, y: 4 })
    if total != 7 {
        print("fail struct infer", total)
    }
}

fn test_continue_multi_mut() {
    let mut i = 0
    let mut sum = 0
    let mut prod = 1
    while i < 5 {
        i = i + 1
        if i == 3 {
            continue
        }
        sum = sum + i
        prod = prod * i
    }
    if sum != 12 {
        print("fail continue sum", sum)
    }
    if prod != 40 {
        print("fail continue prod", prod)
    }
}

fn main() {
    test_i64_to_string()
    test_match_string()
    test_struct_return_nested()
    test_struct_inference_cross_fn()
    test_continue_multi_mut()
    print("language_gaps ok")
}
