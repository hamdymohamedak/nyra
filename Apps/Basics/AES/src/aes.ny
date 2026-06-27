fn AES_usage(){
    print("usage: aes enc <32-byte-key> <plaintext>")
    print("       aes dec <32-byte-key> <hex-ciphertext>")
}

fn AES_run(args){
    if args.len() != 3 {
        AES_usage()
        return 1
    }
    let mode = args.get(0)
    let key = args.get(1)
    let text = args.get(2)
    if strcmp(mode, "enc") == 0 {
        print(aes_encrypt(key, text))
        return 0
    }
    if strcmp(mode, "dec") == 0 {
        print(aes_decrypt(key, text))
        return 0
    }
    AES_usage()
    return 1
}
