fn Rsa_mod(n, d){
    return n - (n / d) * d
}

fn Rsa_mod_pow(base, exp, m){
    let mut result = 1
    let mut b = Rsa_mod(base, m)
    let mut e = exp
    while e > 0 {
        if Rsa_mod(e, 2) == 1 {
            result = Rsa_mod(result * b, m)
        }
        e = e / 2
        b = Rsa_mod(b * b, m)
    }
    return result
}

fn Rsa_encrypt(msg, e, n){
    return Rsa_mod_pow(msg, e, n)
}

fn Rsa_decrypt(cipher, d, n){
    return Rsa_mod_pow(cipher, d, n)
}

fn RSA_usage(){
    print("usage: rsa <message-code>")
    print("  demo key: p=61 q=53 e=17 (educational small primes)")
}

fn RSA_run(args){
    if args.len() != 1 {
        RSA_usage()
        return 1
    }
    let msg = str_to_i32(args.get(0))
    let p = 61
    let q = 53
    let n = p * q
    let e = 17
    let d = 2753
    let cipher = Rsa_encrypt(msg, e, n)
    let plain = Rsa_decrypt(cipher, d, n)
    print(`cipher: ${i32_to_string(cipher)}`)
    print(`plain:  ${i32_to_string(plain)}`)
    return 0
}
