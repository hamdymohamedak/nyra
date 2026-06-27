import "stdlib/parser/combinator.ny"
import "stdlib/strings/split.ny"

fn main() {
    print("=== parser combinator smoke ===", color: bold)
    let cur = ParseCursor_new("fn add 42", "demo.ny")
    let id = Comb_take_while(cur, 2)
    print(Comb_ok_value(id))
    let kw = Comb_or_literal(cur, "fn", "let")
    print(Comb_ok_value(kw))
    let nums = Comb_many(ParseCursor_new("1 2 3", "nums.ny"), 1)
    print(nums.len())
    let parts = String_split_quoted("SELECT * FROM t WHERE x=\"a,b\"", " ")
    let n = parts.len()
    let mut i = 0
    while i < n {
        print(parts.get(i))
        i = i + 1
    }
}
