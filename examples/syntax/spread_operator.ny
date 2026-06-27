// JS-style `...` spread in array and object literals (also accepts Rust-style `..`).
fn main() {
    let user = { name: "Alex", role: "Admin" }
    let nums = [10, 20]
    let more = [...nums, 30, 40]
    let scores = { a: 1, b: 2 }
    let mixed = [...scores, 99]
    let updated = { ...user, role: "Editor" }
    print(more[0])
    print(mixed[0])
    print(mixed[2])
    print(updated.role)
}
