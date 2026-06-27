// Systems types tour — zero-types style (annotations inferred)

import "stdlib/vec.ny"
import "stdlib/map.ny"
import "stdlib/option.ny"

struct User {
    name: string
    active: bool
}

enum State {
    Ready
    Loading
    Error
}

fn twice(n) {
    return n + n
}

fn main() -> void {
    // Closures (Extended): (x) => …  — not Rust |x|
    // Escaping closures → fn pointers: see examples/closure_escape_smoke.ny
    let dbl = (x) => twice(x)
    print(dbl(21))

    // Raw pointer — unsafe only
    let mut slot: i32 = 7
    unsafe {
        let p = &slot as *mut i32
        *p = 9
        print(*p)
    }

    let user = User { name: "Ada", active: true }
    print(user.name)
    print(match State.Ready {
        State.Ready => 1
        State.Loading => 2
        State.Error => 3
    })

    // Option / Result (import stdlib/option.ny)
    let some = Option.Some(42)
    let err = Result.Err(0)
    print(match some {
        Option.Some(v) => v
        Option.None => 0
    })
    print(match err {
        Result.Ok(_) => 1
        Result.Err(_) => 0
    })

    // Vec + HashMap (stdlib monomorph names)
    let v: ptr = Vec_i32_new()
    Vec_i32_push(v, 10)
    print(Vec_i32_len(v))
    Vec_i32_free(v)

    let map = HashMap_str_i32_new()
    let map2 = map.insert("score", 99)
    print(map2.get("score"))
}
