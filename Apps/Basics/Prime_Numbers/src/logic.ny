fn Prime_is_prime(n){
    if n < 2 {
        return 0
    }
    if n == 2 {
        return 1
    }
    if n % 2 == 0 {
        return 0
    }
    let mut d = 3
    while d * d <= n {
        if n % d == 0 {
            return 0
        }
        d = d + 2
    }
    return 1
}

fn Prime_run(limit){
    let mut n = 2
    let mut count = 0
    while n <= limit {
        if Prime_is_prime(n) == 1 {
            print(n)
            count = count + 1
        }
        n = n + 1
    }
    print(`primes up to ${limit}: ${count}`)
}
