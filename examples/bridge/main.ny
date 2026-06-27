import "stdlib/bridge/mod.ny"

fn main() {
    print("=== Nyra language bridge demo ===")

    let py_req = bridge_op_add(19, 23)
    let py_raw = bridge_exec("workers/run_python.sh", py_req)
    print("python raw:")
    print(py_raw)
    print("python result:")
    print(bridge_result(py_raw))

    let node_req = bridge_op_eval("6*7")
    let node_raw = bridge_exec("workers/run_node.sh", node_req)
    print("node raw:")
    print(node_raw)
    print("node result:")
    print(bridge_result(node_raw))

    let java_req = bridge_op_add(100, 23)
    let java_raw = bridge_exec("workers/bridge_java.sh", java_req)
    print("java raw:")
    print(java_raw)
    print("java result:")
    print(bridge_result(java_raw))
}
