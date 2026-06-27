// Language gaps fixed in v1.17.0 (explicit types).

extern fn instant_now() -> i64

fn test_i64_to_string() -> void {
    let ts: i64 = instant_now()
    let text: string = i64_to_string(ts)
    if strlen(text) == 0 {
        print("fail i64_to_string")
    }
}

fn dispatch(cmd: string) -> i32 {
    return match cmd {
        "GET" => 1,
        "POST" => 2,
        _ => 0,
    }
}

fn test_match_string() -> void {
    assert_eq(dispatch("GET"), 1)
    assert_eq(dispatch("POST"), 2)
    assert_eq(dispatch("PUT"), 0)
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

fn ParseCursor_advance(cur: ParseCursor) -> ParseCursor {
    return ParseCursor {
        text: cur.text,
        pos: cur.pos + 1,
        loc: cur.loc
    }
}

fn test_struct_return_nested() -> void {
    let loc: SourceLoc = SourceLoc { file: "main.ny", line: 10, col: 4 }
    let c: ParseCursor = ParseCursor { text: "ab", pos: 0, loc: loc }
    let c2: ParseCursor = ParseCursor_advance(c)
    assert_eq(c2.pos, 1)
    assert_eq(c2.loc.line, 10)
}

struct Point {
    x: i32
    y: i32
}

fn use_point(p: Point) -> i32 {
    return p.x + p.y
}

fn test_struct_inference_cross_fn() -> void {
    let total: i32 = use_point(Point { x: 3, y: 4 })
    assert_eq(total, 7)
}

fn test_continue_multi_mut() -> void {
    let mut i: i32 = 0
    let mut sum: i32 = 0
    let mut prod: i32 = 1
    while i < 5 {
        i = i + 1
        if i == 3 {
            continue
        }
        sum = sum + i
        prod = prod * i
    }
    assert_eq(sum, 12)
    assert_eq(prod, 40)
}

fn main() -> void {
    test_i64_to_string()
    test_match_string()
    test_struct_return_nested()
    test_struct_inference_cross_fn()
    test_continue_multi_mut()
    print("language_gaps typed ok")
}
