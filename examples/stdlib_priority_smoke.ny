import "stdlib/strconv/mod.ny"
import "stdlib/flag/mod.ny"
import "stdlib/bufio/mod.ny"
import "stdlib/context/mod.ny"
import "stdlib/sync/mod.ny"
import "stdlib/encoding/csv.ny"
import "stdlib/mime/mod.ny"

fn main() {
    print(atoi("42"))
    print(itoa(99))
    print(format_i32(7))
    print(format_f64(parse_f64("3.14")))

    let mut set = FlagSet_new("demo", " [options]")
    set = Flag_parse(set)
    if set.help() != 0 {
        Flag_print_usage(set)
        return
    }

    let mut sc = Scanner_new("a\nb\nc")
  let mut sc2 = sc
    sc2 = Scanner_scan(sc2)
    print(Scanner_text(sc2))

    let ctx = Context_with_timeout(Context_background(), 100)
    print(context_done(ctx))

    let mu = Mutex_new()
    let locked = mu.lock()
    let _unlocked = locked.unlock()

    let mut row = StrVec_new()
    row = row.push("name")
    row = row.push("value")
    print(csv_format_row(row))

    print(mime_content_type_multipart("abc123"))
}
