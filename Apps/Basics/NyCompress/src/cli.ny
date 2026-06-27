fn NyCompress_run(){
    print("1 = compress file   2 = decompress archive")
    let mode = input("Mode: ")
    if strcmp(mode, "1") == 0 {
        let src = input("Source file: ")
        if exists(src) == 0 {
            print("source not found")
            return
        }
        let dst = input("Archive path (.nyc): ")
        let before = file_size(src)
        let ok = zip_create(dst, src)
        if ok != 0 {
            print("compress failed")
            return
        }
        let after = file_size(dst)
        print(`${before as i32} bytes -> ${after as i32} bytes (${dst})`)
    } else {
        if strcmp(mode, "2") == 0 {
            let src = input("Archive path: ")
            if exists(src) == 0 {
                print("archive not found")
                return
            }
            let dst = input("Output file: ")
            let ok = zip_extract(src, dst)
            if ok != 0 {
                print("decompress failed")
                return
            }
            let out_size = file_size(dst)
            print(`restored -> ${dst} (${out_size as i32} bytes)`)
        } else {
            print("unknown mode")
        }
    }
}
