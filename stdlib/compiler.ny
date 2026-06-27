import "process.ny"
import "env/mod.ny"

extern fn nyra_check_file(path: string) -> i32
extern fn nyra_check_source(source: string, file: string) -> i32
extern fn nyra_diag_json_file(path: string) -> string
extern fn nyra_diag_json_source(source: string, file: string) -> string
extern fn nyra_compiler_free(p: ptr) -> void

fn compiler_nyra_bin() -> string {
    let home = env_get("NYRA_HOME")
    if strlen(home) > 0 {
        return strcat(strcat(home, "/bin/"), "nyra")
    }
    return "nyra"
}

fn check_inprocess(path: string) -> i32 {
    return nyra_check_file(path)
}

fn check_source_inprocess(source: string, file: string) -> i32 {
    return nyra_check_source(source, file)
}

fn diag_json_inprocess(path: string) -> string {
    return nyra_diag_json_file(path)
}

fn diag_json_source_inprocess(source: string, file: string) -> string {
    return nyra_diag_json_source(source, file)
}

fn check(path: string) -> i32 {
    let rc = nyra_check_file(path)
    if rc >= 0 {
        return rc
    }
    let args = StrVec_new().push("check").push(path)
    let result = exec(compiler_nyra_bin(), args)
    return result.code
}

fn diag_json(path: string) -> string {
    let json = nyra_diag_json_file(path)
    if strlen(json) > 0 {
        return json
    }
    let args = StrVec_new().push("diag").push(path).push("--json")
    let result = exec(compiler_nyra_bin(), args)
    return result.stdout
}

fn build(path: string) -> i32 {
    let args = StrVec_new().push("build").push(path)
    let result = exec(compiler_nyra_bin(), args)
    return result.code
}

fn fmt(path: string) -> i32 {
    let args = StrVec_new().push("fmt").push(path)
    let result = exec(compiler_nyra_bin(), args)
    return result.code
}

fn run(path: string) -> i32 {
    let args = StrVec_new().push("run").push(path)
    let result = exec(compiler_nyra_bin(), args)
    return result.code
}
