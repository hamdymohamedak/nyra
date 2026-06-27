fn main() {
    let a = "moved"
    let b = a
    print(a) //~ ERROR was moved
}
