import "../../shared/cli.ny"

fn Fuzzer_pick_char(alphabet) {
    let n = strlen(alphabet)
    let idx = random_range(0, n - 1)
    return substring(alphabet, idx, 1)
}

fn Fuzzer_mutate(seed) {
    let alphabet = "abcdefghijklmnopqrstuvwxyz0123456789_"
    let n = strlen(seed)
    let mut out = ""
    let mut i = 0
    while i < n {
        let roll = random_range(0, 9)
        if roll == 0 {
            out = strcat(out, Fuzzer_pick_char(alphabet))
        } else {
            out = strcat(out, substring(seed, i, 1))
        }
        i = i + 1
    }
    if random_range(0, 3) == 0 {
        out = strcat(out, Fuzzer_pick_char(alphabet))
    }
    return out
}

fn Fuzzer_parse_i32_strict(s) {
    let n = strlen(s)
    if n == 0 {
        return -1
    }
    let mut i = 0
    let mut sign = 1
    if char_at(s, 0) == 45 {
        sign = -1
        i = 1
    }
    if i >= n {
        return -1
    }
    let mut acc = 0
    while i < n {
        let c = char_at(s, i)
        if c < 48 || c > 57 {
            return -1
        }
        acc = acc * 10 + (c - 48)
        i = i + 1
    }
    return acc * sign
}

fn Fuzzer_run(args) {
    let listed = DevCli_paths(args)
    let n = DevPathList_len(listed)
    let mut rounds = 50
    if n >= 1 {
        rounds = str_to_i32(DevPathList_at(listed, 0))
    }
    if rounds <= 0 {
        rounds = 50
    }
    let seed = if n >= 2 { DevPathList_at(listed, 1) } else { "12345" }
    print(`ny-fuzz: ${rounds} mutations from seed "${seed}"`)
    let mut crashes = 0
    let mut i = 0
    while i < rounds {
        let input = Fuzzer_mutate(seed)
        let parsed = Fuzzer_parse_i32_strict(input)
        if parsed < -1 {
            crashes = crashes + 1
            print(strcat("crash on: ", input))
        }
        i = i + 1
    }
    print(`rounds=${rounds} parse-errors=${crashes}`)
    print("gap: no coverage-guided fuzzing, no subprocess crash harness, no sanitizer hook")
    return 0
}
