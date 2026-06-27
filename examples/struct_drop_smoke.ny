extern fn read_file(path: string) -> string
extern fn strcat(a: string, b: string) -> string

struct Packet Send {
    id: i32
    body: string
}

fn load_packet(path: string) -> Packet {
    let text = read_file(path)
    return Packet { id: 1, body: text }
}

fn main() {
    let p = load_packet("README.md")
    let label = strcat("id=", "1")
    print(p.id)
    print(label)
}
