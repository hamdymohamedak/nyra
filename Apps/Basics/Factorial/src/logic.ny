fn Factorial_iter(n){
    if n < 0 {
        return 0
    }
    let mut out = 1
    let mut i = 2
    while i <= n {
        out = out * i
        i = i + 1
    }
    return out
}

fn Factorial_rec(n){
    if n <= 1 {
        return 1
    }
    return n * Factorial_rec(n - 1)
}

fn Factorial_run(n){
    print(`factorial_iter(${n}) = ${Factorial_iter(n)}`)
    print(`factorial_rec(${n}) = ${Factorial_rec(n)}`)
}
