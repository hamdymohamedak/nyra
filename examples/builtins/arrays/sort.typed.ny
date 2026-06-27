fn main() -> void {
    let nums: [i32; 5] = [10, 1, 2, 8, 5]
    let sorted: [i32; 5] = nums.sort()
    for n in sorted {
        print(n)
    }
    print(nums[0])
}
