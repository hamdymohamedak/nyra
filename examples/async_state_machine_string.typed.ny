// Cooperative async state-machine returning string (typed)
import "stdlib/async/future.ny"

async fn label() -> string {
    let h = async_promise_new()
    spawn {
        async_promise_complete_ptr(h, "ready")
    }
    let f: Future_string = Future_from_handle_string(h)
    return await f
}

fn main() {
    let f: Future_string = label()
    let s: string = await f
    print(s)
}
