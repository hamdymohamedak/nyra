import "../../shared/cli.ny"
import "../../shared/walk.ny"

fn Lint_scan_file(path) {
    let text = read_file(path)
    let mut issues = StrVec_new()
    let mut line_no = 1
    let mut start = 0
    let n = strlen(text)
    while start <= n {
        let rest = substring(text, start, n - start)
        let nl = strstr_pos(rest, "\n")
        let line = if nl < 0 { rest } else { substring(rest, 0, nl) }
        if strlen(line) > 100 {
            issues = issues.push(`${path}:${line_no}: line-length: line exceeds 100 chars`)
        }
        if strstr_pos(line, "\t") >= 0 {
            issues = issues.push(`${path}:${line_no}: no-tabs: tab character in source`)
        }
        let line_len = strlen(line)
        if line_len > 0 {
            let last = char_at(line, line_len - 1)
            if last == 32 || last == 9 {
                issues = issues.push(`${path}:${line_no}: no-trailing-space: trailing whitespace`)
            }
        }
        if strstr_pos(line, "TODO") >= 0 || strstr_pos(line, "FIXME") >= 0 {
            issues = issues.push(`${path}:${line_no}: todo: TODO/FIXME marker`)
        }
        if nl < 0 {
            break
        }
        start = start + nl + 1
        line_no = line_no + 1
    }
    return issues
}

fn Lint_merge(all, chunk) {
    let mut merged = all
    let n = chunk.len()
    let mut i = 0
    while i < n {
        merged = merged.push(chunk.get(i))
        i = i + 1
    }
    return merged
}

fn Lint_run(args) {
    let listed = DevCli_paths(args)
    let n = DevPathList_len(listed)
    if n == 0 {
        DevCli_usage("ny-lint", " [-v] [--check] <dir>")
        return 1
    }
    let root = DevPathList_at(listed, 0)
    let verbose = DevCli_has_flag(args, "-v")
    let use_check = DevCli_has_flag(args, "--check")
    if exists(root) == 0 {
        print(strcat(strcat("ny-lint: ", root), ": not found"))
        return 1
    }
    if use_check == 1 {
        let code = check(root)
        print(`nyra check ${root} => ${code}`)
        return code
    }
    let found = DevWalk_collect_ny(root, DevFileList { files: StrVec_new() })
    let fc = DevFileList_len(found)
    let mut issues = StrVec_new()
    let mut i = 0
    while i < fc {
        let path = DevFileList_at(found, i)
        if verbose == 1 {
            print(strcat("scan ", path))
        }
        issues = Lint_merge(issues, Lint_scan_file(path))
        i = i + 1
    }
    let ic = issues.len()
    let mut j = 0
    while j < ic {
        print(issues.get(j))
        j = j + 1
    }
    print(`ny-lint: ${fc} files, ${ic} style issues`)
    print("tip: ny-lint --check <dir> uses stdlib/compiler.ny check()")
    if ic > 0 {
        return 1
    }
    return 0
}
