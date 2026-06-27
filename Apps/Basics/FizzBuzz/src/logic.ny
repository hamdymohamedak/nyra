fn FizzBuzz_run(limit){
    let mut i = 1
    while i <= limit {
        if i % 15 == 0 {
            print(`${i}: FizzBuzz`)
        } else {
            if i % 3 == 0 {
                print(`${i}: Fizz`)
            } else {
                if i % 5 == 0 {
                    print(`${i}: Buzz`)
                } else {
                    print(i)
                }
            }
        }
        i = i + 1
    }
}
