// Enum payloads + pattern matching — nyra run examples/enum_payload_match.ny
// nyra test tests/nyra/enum_payload_match_test.ny

import "stdlib/option.ny"

enum Color { Red, Green, Blue }

fn color_score(c: Color) -> i32 {
    return match c {
        Color.Red => 1,
        Color.Green => 2,
        Color.Blue => 3,
    }
}

fn option_double(x: Option<i32>) -> i32 {
    return match x {
        Option.Some(v) => v * 2,
        Option.None => 0,
    }
}

fn result_guarded(r: Result<i32, i32>) -> i32 {
    return match r {
        Result.Ok(v) if v > 0 => v,
        Result.Ok(_v) => 0,
        Result.Err(e) => e,
    }
}

fn main() {
    print(color_score(Color.Green))
    print(option_double(Option.Some(21)))
    print(result_guarded(Result.Ok(7)))
}
