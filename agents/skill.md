---
name: nyra-lang-release
description: >-
  Nyra language update workflow: bump minor version (0.2.0 → 0.3.0, middle
  number only) and sync all webDocs when compiler syntax, stdlib, CLI, or ABI
  changes. Use when implementing language features, stdlib, FFI, docs, or any
  Nyra release prep.
---

> **Always-on checklist:** `.cursor/rules/nyra-guidelines.mdc` (tests, examples, webDocs, test-all.sh). This skill adds version bump + webDocs release details.

# Nyra language update & webDocs sync

Apply this skill **whenever you change Nyra language behavior** (compiler, stdlib, CLI flags, ABI, or user-visible semantics). Do not ship language work without version + docs.

## Version rule (mandatory) (MAJOR.MINOR.PATCH)

**Bump only the middle (minor) number. Reset patch to `0`.**

| Before | After | OK? |
|--------|-------|-----|
| `0.2.0` | `0.3.0` | Yes — default for language updates |
| `0.2.0` | `0.2.1` | No — patch-only is for tooling/docs typos without language change |
| `0.2.0` | `1.0.0` | Yes — when user explicitly requests Nyra 1.0 (major release) |
| `1.0.0` | `1.1.0` | Default for non-breaking language updates after 1.0 |

Format: **`MAJOR.MINOR.PATCH`** → after **1.0**, increment **MINOR** for language updates; **MAJOR** only for breaking Core/ABI changes (RFC required).

### Source of truth

1. **[`Cargo.toml`](../../Cargo.toml)** — `[workspace.package] version = "0.x.0"`
2. CLI reads it via `NYRA_VERSION` (`env!("CARGO_PKG_VERSION")`) — no duplicate constant elsewhere.

After editing `Cargo.toml`, grep and update stale literals:

```bash
rg '0\.2\.0|v0\.2\.0' --glob '!target/**' --glob '!**/node_modules/**'
```

Common files (update when version examples appear):

- [`CHANGELOG.md`](../../CHANGELOG.md) — new `## v0.3.0 (YYYY-MM-DD)` section
- [`docs/status.md`](../../docs/status.md) — feature depth (same PR as behavior change)
- [`docs/CHANGELOG-spec.md`](../../docs/CHANGELOG-spec.md) — if spec/parser/ABI touched
- [`README.md`](../../README.md), [`CONTRIBUTING.md`](../../CONTRIBUTING.md), [`install.md`](../../install.md)
- [`grammar/nyra.tmLanguage.json`](../../grammar/nyra.tmLanguage.json) uuid/version if grammar keywords changed
- Release/install examples in `webDocs/` (see below)

**Do not** bump minor version for pure refactors, internal Rust cleanup, or comment-only edits with zero user-visible language change.

---

## webDocs rule (mandatory)

**Every language update must be reflected in [`webDocs/`](../../webDocs/).**

### What counts as a language update

- New/changed syntax, types, keywords (`ptr`, `repr(C)`, `async`, …)
- Stdlib API (`stdlib/**/*.ny`, runtime C symbols)
- CLI flags (`nyra build --link-lib`, `--cdylib`, …)
## ABI (stable v0.4.0)

- Manifest: [`docs/abi-manifest.toml`](../../docs/abi-manifest.toml)
- Regenerate header: `make gen-abi-header` → `stdlib/nyra_rt.h`
- Tests: `abi_manifest.rs`, `make test-abi-roundtrip`
- Policy: [`docs/abi-policy.md`](../../docs/abi-policy.md)
- NyraPkg manifest fields (`link`, `link-arg`, …)
- Examples that demonstrate new surface

### Minimum webDocs checklist

| Change type | Update these |
|-------------|----------------|
| Syntax / types | [`webDocs/language.html`](../../webDocs/language.html), [`reference.html`](../../webDocs/reference.html), [`types.html`](../../webDocs/types.html) |
| Stdlib | [`webDocs/stdlib.html`](../../webDocs/stdlib.html) |
| FFI | [`webDocs/ffi-abi.html`](../../webDocs/ffi-abi.html) |
| CLI / install | [`webDocs/tooling.html`](../../webDocs/tooling.html), [`install.html`](../../webDocs/install.html), [`getting-started.html`](../../webDocs/getting-started.html) |
| Packages | [`webDocs/packages.html`](../../webDocs/packages.html), [`modules.html`](../../webDocs/modules.html) |
| Roadmap / status | [`webDocs/roadmap.html`](../../webDocs/roadmap.html), [`changelog.html`](../../webDocs/changelog.html) |
| AI / agents reference | [`webDocs/nyra-skill.md`](../../webDocs/nyra-skill.md) — **canonical** language reference for LLMs |

Also update [`docs/`](../../docs/) mirrors when they exist (`abi-policy.md`, RFCs, `status.md`, `roadmap-gaps.md`).

### After editing HTML / nyra-skill

From repo root:

```bash
# Sync skills/skill.md from webDocs/nyra-skill.md
node webDocs/scripts/build-nyra-skill.mjs

# Rebuild search index (required if any .html body changed)
node webDocs/scripts/build-search-index.mjs
```

If you add a new doc page, use [`webDocs/scripts/generate-pages.py`](../../webDocs/scripts/generate-pages.py) / [`sync-nav.py`](../../webDocs/scripts/sync-nav.py) patterns and add it to [`webDocs/sitemap.html`](../../webDocs/sitemap.html).

### nyra-skill.md content rules

When updating [`webDocs/nyra-skill.md`](../../webDocs/nyra-skill.md):

1. Set **Version baseline: `v0.x.0`** to match `Cargo.toml`.
2. Document only **shipped** behavior — match [`docs/status.md`](../../docs/status.md) (Core vs Extended).
3. Do not invent syntax; copy from compiler tests or `examples/`.
4. Run `node webDocs/scripts/build-nyra-skill.mjs` so [`skills/skill.md`](../../skills/skill.md) stays in sync.

---

## End-to-end workflow

Copy and track:

```
Language update PR checklist:
- [ ] Compiler/stdlib/tests green: cargo test --workspace
- [ ] docs/status.md updated (feature depth)
- [ ] webDocs pages updated (see checklist above)
- [ ] webDocs/nyra-skill.md + node webDocs/scripts/build-nyra-skill.mjs
- [ ] node webDocs/scripts/build-search-index.mjs
- [ ] Cargo.toml minor bump (0.x.0) + CHANGELOG.md entry
- [ ] Grep for old version strings (0.(x-1).0)
- [ ] examples/ added or updated if user-visible
```

### Parser / ABI breaking changes

Per [`CONTRIBUTING.md`](../../CONTRIBUTING.md): RFC under `docs/rfc/`, entry in `docs/CHANGELOG-spec.md`, **minor** bump (e.g. `0.2.0` → `0.3.0`).

---

## Related paths

| Path | Role |
|------|------|
| [`agents/skill.md`](skill.md) | This workflow (maintainers / Cursor agents) |
| [`webDocs/nyra-skill.md`](../../webDocs/nyra-skill.md) | Canonical language reference for AI |
| [`skills/skill.md`](../../skills/skill.md) | Generated copy of nyra-skill.md |
| [`Cargo.toml`](../../Cargo.toml) | Version source of truth |

---

## Examples

**Added `ptr` type and `--link-lib`**

- Bump `0.2.0` → `0.3.0` in `Cargo.toml`
- Update `webDocs/types.html`, `ffi-abi.html`, `tooling.html`, `nyra-skill.md`
- CHANGELOG: `## v0.3.0` with FFI + linking bullets
- Run both webDocs scripts

**Fixed typo in webDocs install page only**

- No version bump
- Run `build-search-index.mjs` if HTML body changed
