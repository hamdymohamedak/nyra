// JS-style `...` spread in array and object literals (also accepts Rust-style `..`).
fn main() -> void {
    let user = { name: "Alex", role: "Admin" }
    let nums: [i32; 2] = [10, 20]
    let more: [i32; 4] = [...nums, 30, 40]
    let scores = { a: 1, b: 2 }
    let mixed: [i32; 3] = [...scores, 99]
    let updated = { ...user, role: "Editor" }
    print(more[0])
    print(mixed[0])
    print(mixed[2])
    print(updated.role)
}
