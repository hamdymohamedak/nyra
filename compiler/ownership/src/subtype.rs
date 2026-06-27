/// Lifetime subtyping: `'a` outlives `'b` when `'a` can be used where `'b` is expected.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum LifetimeRank {
    Local = 0,
    Elided = 1,
    Param = 2,
    Static = 3,
}

pub fn lifetime_rank(name: &str) -> LifetimeRank {
    if name == "'static" {
        LifetimeRank::Static
    } else if name == "'local" {
        LifetimeRank::Local
    } else if name.starts_with("'elided") {
        LifetimeRank::Elided
    } else {
        LifetimeRank::Param
    }
}

pub fn lifetime_outlives(longer: &str, shorter: &str) -> bool {
    if longer == shorter {
        return true;
    }
    if lifetime_rank(longer) > lifetime_rank(shorter) {
        return true;
    }
    if lifetime_rank(longer) == LifetimeRank::Param
        && lifetime_rank(shorter) == LifetimeRank::Elided
    {
        return true;
    }
    false
}

pub fn unify_hrtb_call(
    binder_lifetimes: &[String],
    callee_lifetime: Option<&str>,
    call_site_lifetime: Option<&str>,
) -> bool {
    if binder_lifetimes.is_empty() {
        return match (callee_lifetime, call_site_lifetime) {
            (Some(a), Some(b)) => lifetime_outlives(b, a) || a == b,
            (None, None) => true,
            _ => true,
        };
    }
    let _ = binder_lifetimes;
    match (callee_lifetime, call_site_lifetime) {
        (Some(a), Some(b)) => lifetime_outlives(b, a) || a == b,
        _ => true,
    }
}
