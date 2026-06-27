#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Version {
    pub major: u64,
    pub minor: u64,
    pub patch: u64,
}

#[derive(Debug, Clone)]
pub enum Req {
    Exact(Version),
    Caret(Version),
    Tilde(Version),
    Gte(Version),
}

impl Version {
    pub fn compare(&self, other: &Version) -> std::cmp::Ordering {
        (self.major, self.minor, self.patch).cmp(&(other.major, other.minor, other.patch))
    }
}

pub fn parse_version(s: &str) -> Result<Version, String> {
    let s = s.trim();
    if s.is_empty() {
        return Err("empty version".into());
    }
    let parts: Vec<_> = s.split('.').collect();
    if parts.len() != 3 {
        return Err(format!("invalid version: {s}"));
    }
    Ok(Version {
        major: parts[0].parse::<u64>().map_err(|e| e.to_string())?,
        minor: parts[1].parse::<u64>().map_err(|e| e.to_string())?,
        patch: parts[2].parse::<u64>().map_err(|e| e.to_string())?,
    })
}

pub fn parse_req(s: &str) -> Result<Req, String> {
    let s = s.trim();
    if let Some(rest) = s.strip_prefix('^') {
        return Ok(Req::Caret(parse_version(rest)?));
    }
    if let Some(rest) = s.strip_prefix('~') {
        return Ok(Req::Tilde(parse_version(rest)?));
    }
    if let Some(rest) = s.strip_prefix(">=") {
        return Ok(Req::Gte(parse_version(rest)?));
    }
    Ok(Req::Exact(parse_version(s)?))
}

pub fn satisfies(req: &Req, ver: &Version) -> bool {
    match req {
        Req::Exact(w) => w == ver,
        Req::Caret(w) => {
            ver.major == w.major
                && (ver.minor > w.minor || (ver.minor == w.minor && ver.patch >= w.patch))
        }
        Req::Tilde(w) => {
            ver.major == w.major && ver.minor == w.minor && ver.patch >= w.patch
        }
        Req::Gte(w) => ver.compare(w) != std::cmp::Ordering::Less,
    }
}

/// Pick the highest version that satisfies `req`.
pub fn best_match<'a>(req: &Req, versions: impl IntoIterator<Item = &'a Version>) -> Option<Version> {
    versions
        .into_iter()
        .filter(|v| satisfies(req, v))
        .max_by(|a, b| a.compare(b))
        .cloned()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn v(major: u64, minor: u64, patch: u64) -> Version {
        Version { major, minor, patch }
    }

    #[test]
    fn caret_allows_compatible_minor() {
        let req = Req::Caret(v(1, 2, 0));
        assert!(satisfies(&req, &v(1, 2, 5)));
        assert!(satisfies(&req, &v(1, 9, 0)));
        assert!(!satisfies(&req, &v(2, 0, 0)));
        assert!(!satisfies(&req, &v(1, 1, 9)));
    }

    #[test]
    fn tilde_locks_minor() {
        let req = Req::Tilde(v(1, 2, 0));
        assert!(satisfies(&req, &v(1, 2, 9)));
        assert!(!satisfies(&req, &v(1, 3, 0)));
    }

    #[test]
    fn gte_allows_newer() {
        let req = Req::Gte(v(1, 0, 0));
        assert!(satisfies(&req, &v(2, 0, 0)));
        assert!(!satisfies(&req, &v(0, 9, 9)));
    }

    #[test]
    fn best_match_picks_highest() {
        let req = Req::Caret(v(1, 0, 0));
        let candidates = [v(1, 0, 1), v(1, 2, 0), v(1, 1, 0)];
        assert_eq!(best_match(&req, candidates.iter()), Some(v(1, 2, 0)));
    }
}
