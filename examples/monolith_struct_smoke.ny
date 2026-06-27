extern fn read_file(path: string) -> string
extern fn strcat(a: string, b: string) -> string

import "stdlib/box.ny"

struct UserRecord Send {
    id: i32
    name: string
    email: string
}

struct Message Send {
    topic: string
    body: string
}

struct Inbox Send {
    owner: string
    latest: Message
}

fn build_user(id: i32, name: string, email: string) -> UserRecord {
    return UserRecord { id: id, name: name, email: email }
}

fn load_message(path: string) -> Message {
    let text = read_file(path)
    let topic = strcat("file:", path)
    return Message { topic: topic, body: text }
}

fn wrap_name(name: string) -> Box<string> {
    return Box_new(name)
}

fn main() {
    let u = build_user(1, "Ada", "ada@nyra.dev")
    let msg = load_message("README.md")
    let inbox = Inbox { owner: u.email, latest: msg }

    let user_id = u.id
    let boxed: Box<string> = wrap_name("cached")

    print(user_id)
    print(inbox.owner)
    print(inbox.latest.topic)
    print(boxed.value)
}
