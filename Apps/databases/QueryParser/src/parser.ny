import "stdlib/db/sql_parse.ny"

fn QueryParser_demo(sql: string) {
    let ast = SqlParse_parse(sql)
    print(`sql: ${sql}`)
    print(`ast: ${SqlParse_format(ast)}`)
    print("---")
}

fn QueryParser_run() {
    QueryParser_demo("SELECT name FROM users")
    QueryParser_demo("SELECT id FROM orders WHERE status = 'open'")
    QueryParser_demo("INSERT INTO t (id, name) VALUES (1, 'nyra')")
    QueryParser_demo("UPDATE users SET name = 'nyra' WHERE id = 1")
    QueryParser_demo("DELETE FROM users WHERE id = 99")
}
