extern fn read_file(path: string) -> string
extern fn strlen(s: string) -> i32
extern fn write_file(path: string, content: string) -> i32

fn main() {
    let msg = "hello from nyra fs\n"
    let w = write_file("/tmp/nyra_test_out.txt", msg)
    print(w)
    let content = read_file("/tmp/nyra_test_out.txt")
    print(strlen(content))
}
