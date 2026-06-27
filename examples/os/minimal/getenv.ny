import "../../../stdlib/os.ny"

fn main() {
    let home = os_getenv("HOME")
    print(home)
}
