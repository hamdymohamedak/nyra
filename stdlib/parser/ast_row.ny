import "../vec_str.ny"

struct AstRow {
    kinds: StrVec
    texts: StrVec
}

fn AstRow_new(){
    return AstRow { kinds: StrVec_new(), texts: StrVec_new() }
}

fn AstRow_push(row, kind, text){
    return AstRow {
        kinds: row.kinds.push(kind),
        texts: row.texts.push(text)
    }
}

fn AstRow_len(row){
    return row.kinds.len()
}

fn AstRow_kind(row, index){
    return row.kinds.get(index)
}

fn AstRow_text(row, index){
    return row.texts.get(index)
}
