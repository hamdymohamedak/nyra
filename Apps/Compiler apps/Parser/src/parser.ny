fn Parser_is_digit(c){
    if c >= 48 && c <= 57 {
        return 1
    }
    return 0
}

fn Parser_is_space(c){
    if c == 32 || c == 9 {
        return 1
    }
    return 0
}

fn Parser_scan(expr){
    let len = strlen(expr)
    let mut i = 0
    while i < len && Parser_is_space(char_at(expr, i)) == 1 {
        i = i + 1
    }
    let start = i
    while i < len && Parser_is_digit(char_at(expr, i)) == 1 {
        i = i + 1
    }
    let lhs = substring(expr, start, i - start)
    while i < len && Parser_is_space(char_at(expr, i)) == 1 {
        i = i + 1
    }
    if i >= len {
        print(strcat("number: ", lhs))
        return
    }
    let op = substring(expr, i, 1)
    i = i + 1
    while i < len && Parser_is_space(char_at(expr, i)) == 1 {
        i = i + 1
    }
    let start2 = i
    while i < len && Parser_is_digit(char_at(expr, i)) == 1 {
        i = i + 1
    }
    let rhs = substring(expr, start2, i - start2)
    print(strcat(strcat(strcat(strcat(strcat(lhs, " "), op), " "), rhs), ""))
}

fn Parser_run(){
    print("=== Parser — flat expression scan ===", color: bold)
    print("expr: 1 + 2")
    Parser_scan("1 + 2")
    print("expr: 10 - 3")
    Parser_scan("10 - 3")
    print("expr: 4 * 5")
    Parser_scan("4 * 5")
}
