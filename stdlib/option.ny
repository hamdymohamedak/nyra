// Generic Option<T> and Result<T, E> (v2.4) — monomorphized at compile time.
// Use `??` for Option defaulting, `?.` for optional chaining, `?` on let-bindings for Result propagation.

enum Option<T> {
    None,
    Some(T),
}

enum Result<T, E> {
    Ok(T),
    Err(E),
}
