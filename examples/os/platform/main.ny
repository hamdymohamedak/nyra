import "../../../stdlib/os.ny"

fn main() {
    print(platform_name())
    print(platform_id())
    print(page_size())
    let home = os_getenv("HOME")
    print(home)
    print(os_getpid())
}
