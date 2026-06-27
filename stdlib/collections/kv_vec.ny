import "../vec_str.ny"

struct KvVec {
    keys: StrVec
    values: StrVec
}

fn KvVec_new(){
    return KvVec { keys: StrVec_new(), values: StrVec_new() }
}

fn KvVec_push(kv, key, value){
    return KvVec {
        keys: kv.keys.push(key),
        values: kv.values.push(value)
    }
}

fn KvVec_len(kv){
    return kv.keys.len()
}

fn KvVec_get_key(kv, index: i32){
    return kv.keys.get(index)
}

fn KvVec_get_value(kv, index: i32){
    return kv.values.get(index)
}

fn KvVec_contains_key(kv, key){
    let n = KvVec_len(kv)
    let mut i = 0
    while i < n {
        if strcmp(kv.keys.get(i), key) == 0 {
            return 1
        }
        i = i + 1
    }
    return 0
}
