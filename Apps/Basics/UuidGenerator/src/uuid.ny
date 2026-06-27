fn Uuid_usage(){
    print("usage: uuid [count]")
}

fn Uuid_run(args){
    let mut count = if args.len() == 0 { 1 } else { str_to_i32(args.get(0)) }
    if count <= 0 {
        count = 1
    }
    let mut i = 0
    while i < count {
        print(UUID_v4())
        i = i + 1
    }
    return 0
}
