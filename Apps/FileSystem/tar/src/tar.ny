
fn Tar_run(args) {
    let create = Cli_has_flag(args, "-c")
    let extract = Cli_has_flag(args, "-x")
    let paths = Cli_strip_flags(args)
    let n = paths.len()
    if create == 1 && n >= 2 {
        let archive = paths.get(0)
        let mut files = StrVec_new()
        let mut i = 1
        while i < n {
            files = files.push(paths.get(i))
            i = i + 1
        }
        if tar_pack(archive, files) != 0 {
            print("tar: create failed")
            return 1
        }
        return 0
    }
    if extract == 1 && n >= 1 {
        let archive = paths.get(0)
        let out_dir = if n >= 2 { paths.get(1) } else { "." }
        if tar_unpack(archive, out_dir) != 0 {
            print("tar: extract failed")
            return 1
        }
        print(strcat("extracted to ", out_dir))
        return 0
    }
    Cli_usage("tar", " -c archive file [file...]  |  tar -x archive [dir]")
    return 1
}
