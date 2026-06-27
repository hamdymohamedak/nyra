import "../../../stdlib/os.ny"

fn main() {
    unsafe {
        asm "nop"
    }
    cpu_nop()
    print(os_getpid())
}
