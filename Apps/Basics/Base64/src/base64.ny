fn Base64_usage(){
    print("usage: base64 encode <text>")
    print("       base64 decode <text>")
}

fn Base64_run(args){
    if args.len() != 2 {
        Base64_usage()
        return 1
    }
    let mode = args.get(0)
    let text = args.get(1)
    if strcmp(mode, "encode") == 0 {
        print(base64_encode(text))
        return 0
    }
    if strcmp(mode, "decode") == 0 {
        print(base64_decode(text))
        return 0
    }
    Base64_usage()
    return 1
}
