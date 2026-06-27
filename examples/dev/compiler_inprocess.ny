import "stdlib/compiler.ny"

fn main() {
    let rc = check_inprocess("examples/database/btree_map.ny")
    print(rc)
    let json = diag_json_inprocess("examples/database/btree_map.ny")
    print(strlen(json))
}
