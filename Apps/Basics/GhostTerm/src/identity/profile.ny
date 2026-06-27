import "../core/id.ny"

extern fn map_str_str_new() -> ptr
extern fn map_str_str_insert(m: ptr, key: string, value: string) -> void
extern fn map_str_str_get(m: ptr, key: string) -> string

struct IdentityRegistry {
    names: ptr
    git_users: ptr
    git_emails: ptr
    aws_profiles: ptr
    ssh_keys: ptr
    ids: IdGen
    count: i32
}

fn IdentityRegistry_new(){
    return IdentityRegistry {
        names: map_str_str_new()
        git_users: map_str_str_new()
        git_emails: map_str_str_new()
        aws_profiles: map_str_str_new()
        ssh_keys: map_str_str_new()
        ids: IdGen_new()
        count: 0
    }
}

fn IdentityRegistry_add(reg, name, git_user, git_email, aws_profile, ssh_key){
    let id = IdGen_take(reg.ids)
    let key = Id_to_key(id)
    map_str_str_insert(reg.names, key, name)
    map_str_str_insert(reg.git_users, key, git_user)
    map_str_str_insert(reg.git_emails, key, git_email)
    map_str_str_insert(reg.aws_profiles, key, aws_profile)
    map_str_str_insert(reg.ssh_keys, key, ssh_key)
    return IdentityRegistry {
        names: reg.names
        git_users: reg.git_users
        git_emails: reg.git_emails
        aws_profiles: reg.aws_profiles
        ssh_keys: reg.ssh_keys
        ids: IdGen_next(reg.ids)
        count: reg.count + 1
    }
}

fn IdentityRegistry_print(_reg){
    print("identity profiles:")
    print("  #1 personal   — GitHub personal, default SSH")
    print("  #2 work       — Company GitHub + AWS work profile")
    print("  #3 client-a   — Client A AWS + Git + SSH")
    print("  #4 client-b   — Client B AWS + Git + SSH")
}

fn IdentityRegistry_seed_defaults(reg){
    let r1 = IdentityRegistry_add(reg, "personal", "you", "you@personal.dev", "default", "~/.ssh/id_ed25519")
    let r2 = IdentityRegistry_add(r1, "work", "you-corp", "you@company.com", "work", "~/.ssh/id_work")
    let r3 = IdentityRegistry_add(r2, "client-a", "you-clienta", "you@clienta.io", "client-a", "~/.ssh/client_a")
    return IdentityRegistry_add(r3, "client-b", "you-clientb", "you@clientb.io", "client-b", "~/.ssh/client_b")
}

fn IdentityRegistry_get_name(reg, id){
    let key = Id_to_key(id)
    return map_str_str_get(reg.names, key)
}
