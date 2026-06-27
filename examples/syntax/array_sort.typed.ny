fn main() -> void {
    let nums: [i32; 5] = [10, 1, 2, 8, 5]
    let sorted: [i32; 5] = nums.sort()
    for n in sorted {
        print(n)
    }
    // Original is unchanged (unlike JavaScript Array.sort).
    print(nums[0])
}
