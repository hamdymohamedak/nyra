/// Return the closest candidate name within `max_distance` edits (Levenshtein).
pub fn did_you_mean<'a>(
    name: &str,
    candidates: impl IntoIterator<Item = &'a str>,
    max_distance: usize,
) -> Option<String> {
    let mut best: Option<(usize, &str)> = None;
    for cand in candidates {
        if cand == name {
            return None;
        }
        let d = levenshtein(name, cand);
        if d == 0 || d > max_distance {
            continue;
        }
        if best.map(|(bd, _)| d < bd).unwrap_or(true) {
            best = Some((d, cand));
        }
    }
    best.map(|(_, s)| s.to_string())
}

fn levenshtein(a: &str, b: &str) -> usize {
    let a: Vec<char> = a.chars().collect();
    let b: Vec<char> = b.chars().collect();
    let mut prev: Vec<usize> = (0..=b.len()).collect();
    for (i, ca) in a.iter().enumerate() {
        let mut cur = vec![i + 1];
        for (j, cb) in b.iter().enumerate() {
            let ins = cur[j] + 1;
            let del = prev[j + 1] + 1;
            let sub = prev[j] + usize::from(ca != cb);
            cur.push(ins.min(del).min(sub));
        }
        prev = cur;
    }
    prev[b.len()]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn suggests_close_name() {
        let names = ["withoutTypes", "wt_id", "main"];
        assert_eq!(
            did_you_mean("withoutType", names, 2).as_deref(),
            Some("withoutTypes")
        );
    }
}
