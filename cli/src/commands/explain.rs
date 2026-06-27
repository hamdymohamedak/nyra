use errors::{explain, format_explain, list_codes};

pub(crate) fn explain_cmd(code: Option<&str>, list: bool) -> Result<(), String> {
    if list {
        for c in list_codes() {
            if let Some(entry) = explain(c) {
                println!("{} — {}", entry.code, entry.title);
            }
        }
        return Ok(());
    }
    let Some(code) = code else {
        return Err("usage: nyra explain <CODE>  (e.g. E003, P001)  or  nyra explain --list".into());
    };
    let Some(entry) = explain(code) else {
        return Err(format!(
            "unknown diagnostic code '{code}' — run `nyra explain --list` for all codes"
        ));
    };
    print!("{}", format_explain(entry));
    Ok(())
}
