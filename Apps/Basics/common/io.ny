fn Io_cat_stdin(){
    let data = stdin_read_bytes(0)
    stdout_write_bytes(data)
    bytes_free(data)
}

fn Io_print_file(path){
    if exists(path) == 0 {
        print(strcat(strcat("cat: ", path), ": No such file"))
        return 1
    }
    let data = bytes_read_file(path)
    stdout_write_bytes(data)
    bytes_free(data)
    return 0
}
