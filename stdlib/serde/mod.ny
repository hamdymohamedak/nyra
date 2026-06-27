// Official serde traits — Serialize / Deserialize (v1.31+)
// Compiler auto-implements for eligible structs ({Struct}_json_encode/decode).

trait Serialize {
    fn to_json(self) -> string
    fn to_bytes(self) -> ptr
}

trait Deserialize {
    fn from_json(json: string) -> Self
}
