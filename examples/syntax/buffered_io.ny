// Buffered stdout: write/println batch into an internal buffer;
// flush() (or main exit) sends one write(2) syscall to stdout.
fn main() {
    write("lines:\n")
    println(1)
    println(2)
    println(3)
    flush()
}
