//! Compile-time feature flags for gradual rollout (see `docs/rfcs/README.md`).

/// Language/compiler features that may be toggled per compilation.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct FeatureSet {
    pub traits: bool,
    pub macros: bool,
    pub async_fns: bool,
    pub spawn: bool,
    pub defer: bool,
    pub generics: bool,
    pub adt_payloads: bool,
    pub struct_spread: bool,
    pub custom_drop: bool,
}

impl Default for FeatureSet {
    fn default() -> Self {
        Self {
            traits: true,
            macros: true,
            async_fns: true,
            spawn: true,
            defer: true,
            generics: true,
            adt_payloads: true,
            struct_spread: true,
            custom_drop: true,
        }
    }
}

impl FeatureSet {
    /// Core v1.0 stable surface only (Extended features disabled).
    pub fn core_only() -> Self {
        Self {
            traits: false,
            macros: false,
            async_fns: false,
            spawn: false,
            defer: false,
            generics: false,
            adt_payloads: false,
            struct_spread: false,
            custom_drop: false,
        }
    }

    pub fn is_enabled(&self, feature: &str) -> bool {
        match feature {
            "traits" => self.traits,
            "macros" => self.macros,
            "async" => self.async_fns,
            "spawn" => self.spawn,
            "defer" => self.defer,
            "generics" => self.generics,
            "adt_payloads" => self.adt_payloads,
            "struct_spread" => self.struct_spread,
            "custom_drop" => self.custom_drop,
            _ => true,
        }
    }
}
