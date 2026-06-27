
fn Zip_run(args) {
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if n < 2 {
        Cli_usage("zip", " archive.nyc source")
        return 1
    }
    let archive = paths.get(0)
    let source = paths.get(1)
    if exists(source) == 0 {
        print(strcat(strcat("zip: ", source), ": not found"))
        return 1
    }
    if is_dir(source) == 1 {
        print("zip: source must be a file")
        return 1
    }
    if zip_create(archive, source) != 0 {
        print("zip: create failed")
        return 1
    }
    print(strcat(strcat("created ", archive), strcat(" <- ", source)))
    return 0
}
