// Cooperative async state-machine returning string (zero-types)
import "stdlib/async/future.ny"

async fn label() -> string {
    let h = async_promise_new()
    spawn {
        async_promise_complete_ptr(h, "ready")
    }
    return await Future_from_handle_string(h)
}

fn main() {
    let f = label()
    print(await f)
}
