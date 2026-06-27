fn SHA256_usage(){
    print("usage: sha256 <text>")
}

fn SHA256_run(args){
    if args.len() != 1 {
        SHA256_usage()
        return 1
    }
    print(sha256(args.get(0)))
    return 0
}
