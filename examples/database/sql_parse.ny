// SQL parser — SELECT/INSERT/UPDATE/DELETE with WHERE expressions.

import "stdlib/db/sql_parse.ny"

fn main() {
    let sel = SqlParse_parse("SELECT email FROM users WHERE age >= 18")
    print(SqlParse_format(sel))
    let ins = SqlParse_parse("INSERT INTO logs (msg) VALUES ('ok')")
    print(SqlParse_format(ins))
    let upd = SqlParse_parse("UPDATE users SET active = 1 WHERE id = 42")
    print(SqlParse_format(upd))
    let del = SqlParse_parse("DELETE FROM sessions WHERE expired = 1")
    print(SqlParse_format(del))
}
