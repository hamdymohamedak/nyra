import "stdlib/async.ny"

allow_extended
fn main() -> void {
    let h = async_promise_new()
    spawn {
        async_promise_complete(h, 42)
    }
    print(await h)
}
