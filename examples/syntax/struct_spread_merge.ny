// Merge fields from multiple structs into one target struct (JS-style spread).
struct User {
    name: string
    role: string
}

struct Settings {
    theme: string
    notifications: bool
}

struct Profile {
    name: string
    role: string
    theme: string
    notifications: bool
}

fn main() {
    let user = User { name: "Alex", role: "Admin" }
    let settings = Settings { theme: "dark", notifications: true }
    let merged = Profile { ..user, ..settings }
    print(`User ${merged.name} (${merged.role}), theme=${merged.theme}`)
    print(merged.notifications)
}
