fn main() {
    let obj = { age: 20 }
    let nums = [...obj, 1, 4, 3, 5, 2]
    print(nums)
    print([1.5, 2.5])
    print(["a", "b"])
}

test fn test_print_i32_array() {
    let xs = [10, 20, 30]
    print(xs)
    assert_eq(xs[1], 20)
}

test fn test_print_spread_array() {
    let obj = { age: 20 }
    let nums = [...obj, 1, 4]
    print(nums)
    assert_eq(nums[0], 20)
    assert_eq(nums[2], 4)
}
