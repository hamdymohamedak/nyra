"""Recipe: add a slim C library entry under registry/c/ + wire cli BUILTIN."""
from __future__ import annotations

from .. import patch
from ..paths import C_REGISTRY, C_REGISTRY_RS
from ..spec import CLibRegistrySpec, RecipeResult


def render_toml(spec: CLibRegistrySpec) -> str:
    lines = [
        f'name = "{spec.name}"',
    ]
    if spec.description:
        lines.append(f'description = "{_escape_toml(spec.description)}"')
    lines.append(f"headers = {_toml_str_list(spec.headers)}")
    lines.append(f"libs = {_toml_str_list(spec.libs)}")
    if spec.pkg_config:
        lines.append(f'pkg_config = "{spec.pkg_config}"')
    if spec.brew:
        lines.append(f'brew = "{spec.brew}"')
    if spec.apt:
        lines.append(f'apt = "{spec.apt}"')
    if spec.pacman:
        lines.append(f'pacman = "{spec.pacman}"')
    if spec.dnf:
        lines.append(f'dnf = "{spec.dnf}"')
    if spec.aliases:
        lines.append(f"aliases = {_toml_str_list(spec.aliases)}")
    if spec.git:
        lines.append(f'git = "{spec.git}"')
    if spec.depends:
        lines.append(f"depends = {_toml_str_list(spec.depends)}")
    if spec.impl_define:
        lines.append(f'impl_define = "{spec.impl_define}"')
    if spec.defines:
        lines.append(f"defines = {_toml_str_list(spec.defines)}")
    if spec.force_include:
        lines.append(f"force_include = {_toml_str_list(spec.force_include)}")
    if spec.cxx:
        lines.append("cxx = true")
    if spec.platforms:
        lines.append(f"platforms = {_toml_str_list(spec.platforms)}")
    lines.append("")
    return "\n".join(lines)


def registry_rs_entry(spec: CLibRegistrySpec) -> str:
    return f'    ("{spec.name}", include_str!("../../registry/c/{spec.name}.toml")),'


def apply(spec: CLibRegistrySpec, *, force: bool = False) -> RecipeResult:
    marker = spec.marker
    res = RecipeResult(
        title="C Library Registry Entry",
        recipe="c-lib-registry",
        marker=marker,
        patches=[],
    )

    toml_path = C_REGISTRY / f"{spec.name}.toml"
    body = patch.wrap_scaffold(render_toml(spec), marker, lang="toml")
    res.patches.append(patch.write_new_file(toml_path, body, marker, force=force))

    entry = registry_rs_entry(spec)
    wrapped = "\n".join(
        [
            patch.marker_start(marker, lang="rust"),
            entry,
            patch.marker_end(marker, lang="rust"),
        ]
    )

    def add_builtin(content: str) -> tuple[str, bool]:
        if f'("{spec.name}", include_str!' in content:
            return content, False
        # Insert before the closing `];` of the BUILTIN table.
        needle = "];\n\npub fn load_registry"
        if needle not in content:
            needle = "];"
        insertion = wrapped + "\n"
        return patch.insert_before(content, needle, insertion)

    res.patches.append(patch.patch_file(C_REGISTRY_RS, add_builtin))

    res.user_tasks = [
        f"Confirm the OS package installs: brew install {spec.brew}",
        "If apt/dnf/pacman were skipped, add them later when you know the package names",
        f"Smoke: brew install {spec.brew} && nyra bind {spec.name}",
        "Commit registry/c/*.toml + cli/src/c_registry.rs",
    ]
    res.usage_lines = [
        f"brew install {spec.brew}",
        f"nyra bind {spec.name}",
        f'import "vendor/bindings/{_header_stem(spec.headers[0])}.ny"',
    ]
    if not any(p.changed for p in res.patches):
        res.warnings.append("Entry already present — use --force to overwrite the toml.")
    return res


def _toml_str_list(items: list[str]) -> str:
    inner = ", ".join(f'"{_escape_toml(x)}"' for x in items)
    return f"[{inner}]"


def _escape_toml(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def _header_stem(header: str) -> str:
    name = header.rsplit("/", 1)[-1]
    if name.endswith(".h"):
        return name[:-2]
    return name
