import "../../shared/cli.ny"
import "stdlib/pkg.ny"

struct PkgManifest {
    module_name: string
    link_lines: StrVec
}

fn Pkg_trim_line(line) {
    let n = strlen(line)
    let mut start = 0
    while start < n && (char_at(line, start) == 32 || char_at(line, start) == 9) {
        start = start + 1
    }
    if start >= n {
        return ""
    }
    let mut end = n
    while end > start {
        let c = char_at(line, end - 1)
        if c != 32 && c != 9 {
            break
        }
        end = end - 1
    }
    return substring(line, start, end - start)
}

fn Pkg_parse_mod(path) {
    let raw = read_file(path)
    let lines = StrVec_from_lines(raw)
    let n = lines.len()
    let mut module_name = ""
    let mut links = StrVec_new()
    let mut i = 0
    while i < n {
        let line = Pkg_trim_line(lines.get(i))
        if strlen(line) == 0 {
            i = i + 1
        } else {
            if strstr_pos(line, "module ") == 0 {
                module_name = substring(line, 7, strlen(line) - 7)
            } else {
                if strstr_pos(line, "link ") == 0 {
                    links = links.push(line)
                }
            }
            i = i + 1
        }
    }
    return PkgManifest { module_name: module_name, link_lines: links }
}

fn Pkg_verify_files(root) {
    let mut ok = 1
    let mod_path = strcat(root, "/nyra.mod")
    let lock_path = strcat(root, "/nyra.lock")
    let sum_path = strcat(root, "/nyra.sum")
    if exists(mod_path) == 0 {
        print("missing nyra.mod")
        ok = 0
    }
    if exists(lock_path) == 0 {
        print("missing nyra.lock — run nyra pkg verify")
        ok = 0
    }
    if exists(sum_path) == 0 {
        print("missing nyra.sum")
        ok = 0
    }
    return ok
}

fn Pkg_run(args) {
    let listed = DevCli_paths(args)
    let n = DevPathList_len(listed)
    if n == 0 {
        DevCli_usage("ny-pkg", " <project-dir>")
        return 1
    }
    let root = DevPathList_at(listed, 0)
    if Pkg_verify_files(root) == 0 {
        return 1
    }
    let manifest = Pkg_parse_mod(strcat(root, "/nyra.mod"))
    print(`module: ${manifest.module_name}`)
    let lc = manifest.link_lines.len()
    print(`link lines: ${lc}`)
    let mut i = 0
    while i < lc {
        print(manifest.link_lines.get(i))
        i = i + 1
    }
    let verify_rc = pkg_verify(root)
    print(`pkg_verify -> ${verify_rc}`)
    print("stdlib/pkg.ny — verify/install/publish via exec(nyra, …)")
    return verify_rc
}
