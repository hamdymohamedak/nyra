fn Sort_print(nums: [i32; 6], len){
    let mut i = 0
    while i < len {
        print(nums[i])
        i = i + 1
    }
}

fn Sorting_run(){
    let mut nums = [10, 1, 2, 8, 5, 3]
    let len = nums.len()
    print("bubble sort demo:")
    Sort_print(nums, len)
    let mut n = len
    while n > 1 {
        let mut j = 0
        while j < n - 1 {
            if nums[j] > nums[j + 1] {
                let tmp = nums[j]
                nums[j] = nums[j + 1]
                nums[j + 1] = tmp
            }
            j = j + 1
        }
        n = n - 1
    }
    print("sorted:")
    Sort_print(nums, len)
}
