fn main() -> void {
    let obj = AgeOnly { age: 20 }
    let nums: [i32; 6] = [...obj, 1, 4, 3, 5, 2]
    print(nums)
    let floats: [f64; 2] = [1.5, 2.5]
    print(floats)
    let labels: [string; 2] = ["a", "b"]
    print(labels)
}

struct AgeOnly {
    age: i32
}

test fn test_print_i32_array() -> void {
    let xs: [i32; 3] = [10, 20, 30]
    print(xs)
    assert_eq(xs[1], 20)
}

test fn test_print_spread_array() -> void {
    let obj = AgeOnly { age: 20 }
    let nums: [i32; 3] = [...obj, 1, 4]
    print(nums)
    assert_eq(nums[0], 20)
    assert_eq(nums[2], 4)
}
