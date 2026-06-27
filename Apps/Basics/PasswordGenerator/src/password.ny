const LOWER = "abcdefghijklmnopqrstuvwxyz"
const UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const DIGITS = "0123456789"
const SYMBOLS = "!@#$%^&*"

fn Password_pick(pool){
    let len = strlen(pool)
    let idx = random_range(0, len - 1)
    return substring(pool, idx, 1)
}

fn Password_build_pool(use_symbols){
    let mut pool = strcat(LOWER, UPPER)
    pool = strcat(pool, DIGITS)
    if use_symbols == 1 {
        pool = strcat(pool, SYMBOLS)
    }
    return pool
}

fn Password_generate(length, use_symbols){
    let pool = Password_build_pool(use_symbols)
    let mut out = ""
    let mut i = 0
    while i < length {
        out = strcat(out, Password_pick(pool))
        i = i + 1
    }
    return out
}

fn Password_usage(){
    print("usage: passgen <length> [--symbols]")
}

fn Password_run(args){
    let n = args.len()
    if n < 1 || n > 2 {
        Password_usage()
        return 1
    }
    let length = str_to_i32(args.get(0))
    if length < 4 {
        print("length must be >= 4")
        return 1
    }
    let mut symbols = 0
    if n == 2 && strcmp(args.get(1), "--symbols") == 0 {
        symbols = 1
    }
    print(Password_generate(length, symbols))
    return 0
}
