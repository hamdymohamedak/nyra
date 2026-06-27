fn Fibonacci_iter(n){
    if n <= 0 {
        return 0
    }
    if n == 1 {
        return 1
    }
    let mut a = 0
    let mut b = 1
    let mut i = 2
    while i <= n {
        let t = a + b
        a = b
        b = t
        i = i + 1
    }
    return b
}

fn Fibonacci_run(count){
    let mut i = 0
    while i < count {
        print(`fib(${i}) = ${Fibonacci_iter(i)}`)
        i = i + 1
    }
}
