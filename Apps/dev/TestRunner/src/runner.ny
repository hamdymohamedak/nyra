import "../../shared/cli.ny"
import "../../shared/walk.ny"

fn TestRunner_is_test_file(path) {
    if strstr_pos(path, "_test.ny") >= 0 {
        return 1
    }
    if strstr_pos(path, "/test_") >= 0 {
        return 1
    }
    return 0
}

fn TestRunner_file_has_test_fn(path) {
    let text = read_file(path)
    if strstr_pos(text, "test fn ") >= 0 {
        return 1
    }
    return 0
}

fn TestRunner_discover(root) {
    let found = DevWalk_collect_ny(root, DevFileList { files: StrVec_new() })
    let n = DevFileList_len(found)
    let mut tests = StrVec_new()
    let mut i = 0
    while i < n {
        let path = DevFileList_at(found, i)
        if TestRunner_is_test_file(path) == 1 || TestRunner_file_has_test_fn(path) == 1 {
            tests = tests.push(path)
        }
        i = i + 1
    }
    return tests
}

fn TestRunner_run_one(path) {
    let bin = compiler_nyra_bin()
    let args = StrVec_new().push("test").push(path)
    let result = exec(bin, args)
    print(strcat(strcat(path, " => "), i32_to_string(result.code)))
    if strlen(result.stderr) > 0 {
        print(result.stderr)
    }
    return result.code
}

fn TestRunner_run(args) {
    let listed = DevCli_paths(args)
    let n = DevPathList_len(listed)
    if n == 0 {
        DevCli_usage("ny-test-runner", " [-v] <project-dir>")
        return 1
    }
    let root = DevPathList_at(listed, 0)
    let verbose = DevCli_has_flag(args, "-v")
    let tests = TestRunner_discover(root)
    let tc = tests.len()
    if tc == 0 {
        print("no tests discovered")
        return 1
    }
    let mut failures = 0
    let mut i = 0
    while i < tc {
        let path = tests.get(i)
        if verbose == 1 {
            print(strcat("run: nyra test ", path))
        }
        let code = TestRunner_run_one(path)
        if code != 0 {
            failures = failures + 1
        }
        i = i + 1
    }
    print(`ran ${tc} test file(s), failures=${failures}`)
    if failures > 0 {
        return 1
    }
    return 0
}
