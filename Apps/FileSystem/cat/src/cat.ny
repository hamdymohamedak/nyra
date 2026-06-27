
fn Cat_run(args) {
    let files = Cli_strip_flags(args)
    let n = files.len()
    if n == 0 {
        let data = stdin_read_bytes(0)
        stdout_write_bytes(data)
        bytes_free(data)
        return 0
    }
    let mut i = 0
    while i < n {
        let path = files.get(i)
        if strcmp(path, "-") == 0 {
            let data = stdin_read_bytes(0)
            stdout_write_bytes(data)
            bytes_free(data)
        } else {
            if exists(path) == 0 {
                print(strcat(strcat("cat: ", path), ": No such file"))
                return 1
            }
            let data = bytes_read_file(path)
            stdout_write_bytes(data)
            bytes_free(data)
        }
        i = i + 1
    }
    return 0
}
