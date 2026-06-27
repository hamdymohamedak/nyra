struct AgeOnly {
    age: i32
}

fn main() {
    let obj = AgeOnly { age: 20 }
    let nums: [i32; 3] = [1, 4, 3]
    let from_obj: [i32; 3] = [...obj, 5, 6]
    let merged_arr: [i32; 5] = [...nums, ...obj, 7]
    let merged_obj = AgeOnly { ...obj, age: 21 }
    print(from_obj[0])
    print(from_obj[2])
    print(merged_arr[3])
    print(merged_arr[4])
    print(merged_obj.age)
}
