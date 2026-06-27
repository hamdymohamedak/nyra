use std::ffi::{CStr, CString};
use std::os::raw::c_char;

extern "C" {
    fn add(a: i32, b: i32) -> i32;
    fn greet(name: *const c_char) -> *mut c_char;
    fn free(p: *mut c_char);
}

fn main() {
    assert_eq!(unsafe { add(20, 22) }, 42);

    let name = CString::new("Nyra").unwrap();
    let msg = unsafe { greet(name.as_ptr()) };
    assert!(!msg.is_null());
    let s = unsafe { CStr::from_ptr(msg) }.to_str().unwrap();
    assert_eq!(s, "Hello, Nyra");
    unsafe { free(msg) };
    println!("export_greet rust_host: ok");
}
