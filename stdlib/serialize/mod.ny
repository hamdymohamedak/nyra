import "../json/mod.ny"
import "../strings.ny"
import "../vec_str.ny"

enum SerializeFormat {
    Json,
    Toml,
    Yaml,
    Binary,
}

extern fn json_encode_object(keys: ptr, values: ptr) -> string

fn serialize_json_field(key: string, value: string) -> string {
    return encode_field(key, value)
}

fn deserialize_json_field(json: string, key: string) -> string {
    return decode_string(json, key)
}

fn encode_object(keys: ptr, values: ptr) -> string {
    return json_encode_object(keys, values)
}

fn toml_encode_field(key: string, value: string) -> string {
    return strcat(strcat(strcat(key, " = \""), value), "\"\n")
}

fn toml_encode_object(keys: ptr, values: ptr) -> string {
    let mut out = ""
    let n = Vec_str_len(keys)
    let mut i = 0
    while i < n {
        out = strcat(out, toml_encode_field(Vec_str_get(keys, i), Vec_str_get(values, i)))
        i = i + 1
    }
    return out
}

fn yaml_encode_field(key: string, value: string) -> string {
    return strcat(strcat(strcat(strcat(key, ": \""), value), "\""), "\n")
}

fn yaml_encode_object(keys: ptr, values: ptr) -> string {
    let mut out = ""
    let n = Vec_str_len(keys)
    let mut i = 0
    while i < n {
        out = strcat(out, yaml_encode_field(Vec_str_get(keys, i), Vec_str_get(values, i)))
        i = i + 1
    }
    return out
}

fn toml_decode_field(text: string, key: string) -> string {
    let needle = strcat(key, " = \"")
    let pos = strstr_pos(text, needle)
    if pos < 0 {
        return ""
    }
    let start = pos + strlen(needle)
    let end = strstr_pos(substring(text, start, strlen(text) - start), "\"")
    if end < 0 {
        return ""
    }
    return substring(text, start, end)
}

fn yaml_decode_field(text: string, key: string) -> string {
    let needle = strcat(strcat(key, ": \""), "")
    let pos = strstr_pos(text, needle)
    if pos < 0 {
        return ""
    }
    let start = pos + strlen(needle)
    let end = strstr_pos(substring(text, start, strlen(text) - start), "\"")
    if end < 0 {
        return ""
    }
    return substring(text, start, end)
}

fn serialize(format: SerializeFormat, keys: ptr, values: ptr) -> string {
    return match format {
        SerializeFormat.Json => encode_object(keys, values)
        SerializeFormat.Toml => toml_encode_object(keys, values)
        SerializeFormat.Yaml => yaml_encode_object(keys, values)
        SerializeFormat.Binary => encode_object(keys, values)
    }
}

fn deserialize(format: SerializeFormat, text: string, key: string) -> string {
    return match format {
        SerializeFormat.Json => decode_string(text, key)
        SerializeFormat.Toml => toml_decode_field(text, key)
        SerializeFormat.Yaml => yaml_decode_field(text, key)
        SerializeFormat.Binary => decode_string(text, key)
    }
}

fn serialize_toml(key: string, value: string) -> string {
    return toml_encode_field(key, value)
}

fn serialize_yaml(key: string, value: string) -> string {
    return yaml_encode_field(key, value)
}
