import "../serialize/mod.ny"
import "../strings.ny"
import "../vec_str.ny"

struct RpcRequest {
    method: string
    params: string
    id: string
}

fn RpcRequest_new(method: string, params_json: string, id: string) -> RpcRequest {
    return RpcRequest { method: method, params: params_json, id: id }
}

fn rpc_encode(req: RpcRequest) -> string {
    let keys = Vec_str_new()
    Vec_str_push(keys, "jsonrpc")
    Vec_str_push(keys, "method")
    Vec_str_push(keys, "params")
    Vec_str_push(keys, "id")
    let vals = Vec_str_new()
    Vec_str_push(vals, "2.0")
    Vec_str_push(vals, req.method)
    Vec_str_push(vals, req.params)
    Vec_str_push(vals, req.id)
    return encode_object(keys, vals)
}

fn rpc_decode_method(json: string) -> string {
    return deserialize_json_field(json, "method")
}

fn rpc_decode_result(json: string) -> string {
    return deserialize_json_field(json, "result")
}

fn rpc_response_ok(result_json: string, id: string) -> string {
    let keys = Vec_str_new()
    Vec_str_push(keys, "jsonrpc")
    Vec_str_push(keys, "result")
    Vec_str_push(keys, "id")
    let vals = Vec_str_new()
    Vec_str_push(vals, "2.0")
    Vec_str_push(vals, result_json)
    Vec_str_push(vals, id)
    return encode_object(keys, vals)
}

fn rpc_response_err(code: i32, message: string, id: string) -> string {
    let err = strcat(strcat(strcat("{\"code\":", i32_to_string(code)), strcat(",\"message\":\"", message)), "\"}")
    let keys = Vec_str_new()
    Vec_str_push(keys, "jsonrpc")
    Vec_str_push(keys, "error")
    Vec_str_push(keys, "id")
    let vals = Vec_str_new()
    Vec_str_push(vals, "2.0")
    Vec_str_push(vals, err)
    Vec_str_push(vals, id)
    return encode_object(keys, vals)
}
