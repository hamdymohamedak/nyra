fn main() {
    let s = "moved"
    let t = s
    print(s) //~ ERROR was moved
}
