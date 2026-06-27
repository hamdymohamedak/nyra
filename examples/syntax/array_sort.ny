fn main() {
    let nums = [10, 1, 2, 8, 5]
    let sorted = nums.sort()
    for n in sorted {
        print(n)
    }
    // Original is unchanged (unlike JavaScript Array.sort).
    print(nums[0])
}
