import "../../../stdlib/os.ny"

fn main() {
    let pct = battery_percent()
    if pct < 0 {
        print("Battery: unavailable")
    } else {
        print(pct)
    }
    print(platform_name())
}
