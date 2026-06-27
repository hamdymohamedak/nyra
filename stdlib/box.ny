// Generic heap box (v2.4) — monomorphized; composite drop frees string fields automatically.

struct Box<T> Send {
    value: T
}

fn Box_new(value: string) -> Box<string> {
    return Box<string> { value: value }
}
