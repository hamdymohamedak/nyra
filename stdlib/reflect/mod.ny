// Reflection MVP — compile-time types only; no runtime RTTI until post-1.0.

enum TypeKind {
    I32,
    Bool,
    String,
    Void,
    Unknown,
}

fn typeof_i32(_x: i32) -> TypeKind {
    return TypeKind.I32
}

fn typeof_bool(_x: bool) -> TypeKind {
    return TypeKind.Bool
}

fn typeof_string(_x: string) -> TypeKind {
    return TypeKind.String
}

fn type_name_i32() -> string {
    return "i32"
}

fn type_name_bool() -> string {
    return "bool"
}

fn type_name_string() -> string {
    return "string"
}

fn type_name_vec_i32() -> string {
    return "Vec_i32"
}

fn type_name_hashmap_str_i32() -> string {
    return "HashMap_str_i32"
}
