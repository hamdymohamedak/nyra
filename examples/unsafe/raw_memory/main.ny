fn main() {
    mut x = 99
    unsafe {
        let p = &x as *i32
        print(*p)
    }
}
