fn main() {
    let obj = { age: 20 }
    let nums = [1, 4, 3]
    let from_obj = [...obj, 5, 6]
    let merged_arr = [...nums, ...obj, 7]
    let merged_obj = { ...obj, age: 21 }
    print(from_obj[0])
    print(from_obj[2])
    print(merged_arr[3])
    print(merged_arr[4])
    print(merged_obj.age)
}
