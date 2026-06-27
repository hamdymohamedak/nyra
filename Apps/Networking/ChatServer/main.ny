import "src/server.ny"

fn main() {
    print("=== ChatServer — TCP chat ===", color: bold)
    ChatServer_run()
}
