struct CalcState {
    value: i32
}

fn CalcState_new(){
    return CalcState { value: 0 }
}

fn CalcState_add(c, n){
    return CalcState { value: c.value + n }
}

fn CalcState_sub(c, n){
    return CalcState { value: c.value - n }
}

fn CalcState_mul(c, n){
    return CalcState { value: c.value * n }
}

fn CalcState_div(c, n){
    return CalcState { value: c.value / n }
}

fn Calc_apply(c, op, n){
    if strcmp(op, "+") == 0 {
        return CalcState_add(c, n)
    }
    if strcmp(op, "-") == 0 {
        return CalcState_sub(c, n)
    }
    if strcmp(op, "*") == 0 {
        return CalcState_mul(c, n)
    }
    return CalcState_div(c, n)
}

fn Calc_usage(){
    print("usage: calc <a> <op> <b>   (op: + - * /)")
    print("       calc demo            (struct demo)")
}

fn Calc_run_demo(){
    let mut c = CalcState_new()
    c = CalcState_add(c, 10)
    c = CalcState_mul(c, 3)
    c = CalcState_sub(c, 5)
    c = CalcState_div(c, 5)
    print(`(0 + 10) * 3 - 5) / 5 = ${c.value}`)
}

fn Calc_run(args){
    let n = args.len()
    if n == 1 && strcmp(args.get(0), "demo") == 0 {
        Calc_run_demo()
        return 0
    }
    if n != 3 {
        Calc_usage()
        return 1
    }
    let a = str_to_i32(args.get(0))
    let op = args.get(1)
    let b = str_to_i32(args.get(2))
    let c = Calc_apply(CalcState { value: a }, op, b)
    print(c.value)
    return 0
}
