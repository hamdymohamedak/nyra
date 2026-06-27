import "process.ny"
import "env/mod.ny"

fn pkg_nyra_bin() -> string {
    let home = env_get("NYRA_HOME")
    if strlen(home) > 0 {
        return strcat(strcat(home, "/bin/"), "nyra")
    }
    return "nyra"
}

fn pkg_verify(path: string) -> i32 {
    let args = StrVec_new().push("pkg").push("verify").push(path)
    let result = exec(pkg_nyra_bin(), args)
    return result.code
}

fn pkg_install(path: string) -> i32 {
    let args = StrVec_new().push("pkg").push("install").push(path)
    let result = exec(pkg_nyra_bin(), args)
    return result.code
}

fn pkg_publish(path: string) -> i32 {
    let args = StrVec_new().push("pkg").push("publish").push(path)
    let result = exec(pkg_nyra_bin(), args)
    return result.code
}

fn pkg_add(path: string, name: string) -> i32 {
    let args = StrVec_new().push("pkg").push("add").push(name).push(path)
    let result = exec(pkg_nyra_bin(), args)
    return result.code
}
