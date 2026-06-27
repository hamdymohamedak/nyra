
fn Unzip_run(args) {
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if n < 2 {
        Cli_usage("gunzip", " archive.gz output")
        return 1
    }
    let archive = paths.get(0)
    let dest = paths.get(1)
    if exists(archive) == 0 {
        print(`gunzip: ${archive}: not found`)
        return 1
    }
    if gzip_decompress_file(archive, dest) != 0 {
        print("gunzip: decompress failed")
        return 1
    }
    let sz = file_size(dest)
    print(`extracted -> ${dest} (${sz as i32} bytes)`)
    return 0
}
