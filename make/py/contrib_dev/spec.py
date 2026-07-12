from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
import re

# Reuse Nyra type parsing from builtin_dev.
from builtin_dev.spec import ArgSpec, NyraType  # noqa: F401 — re-exported


class ConformanceMode(str, Enum):
    PASS = "pass"
    FAIL = "fail"


class CliKind(str, Enum):
    SUBCOMMAND = "subcommand"
    FLAG = "flag"


@dataclass
class RecipeResult:
    title: str
    recipe: str
    marker: str
    patches: list  # patch.PatchResult
    user_tasks: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    usage_lines: list[str] = field(default_factory=list)

    def ok(self) -> bool:
        return any(getattr(p, "changed", False) for p in self.patches)


@dataclass
class StdlibFnSpec:
    fn_name: str
    args: list[ArgSpec]
    returns: NyraType
    ny_module: str
    rt_module: str | None = None
    stable_abi: bool = False
    abi_since: str = "1.0.0"
    wrap_extern: str | None = None
    ny_alias: str | None = None
    pure_body: str | None = None
    # Free-form Nyra source for multi-fn / struct modules (stdlib-module recipe).
    # When set, fn_name is used only as the marker slug (not a single fn).
    pure_source: str | None = None
    # Optional shared test/example topic override for module scaffolds.
    example_topic: str | None = None
    # Optional full C function body (lines inside `{ … }`, no signature).
    c_body: str | None = None

    def __post_init__(self) -> None:
        self.fn_name = self.fn_name.strip()
        if not self.fn_name:
            raise ValueError("function name is required")
        self.ny_module = normalize_ny_module(self.ny_module)
        if self.pure_source is None and self.rt_module is None and self.wrap_extern is None:
            self.rt_module = guess_rt_module(self.ny_module, self.fn_name)

    @property
    def marker(self) -> str:
        slug = self.ny_module.replace("/", "_").replace(".ny", "")
        return f"{self.fn_name}:{slug}"

    @property
    def stdlib_path(self) -> str:
        return f"stdlib/{self.ny_module}"


@dataclass
class TestExampleSpec:
    name: str
    example_topic: str = "syntax"
    with_typed: bool = True
    use_testing: bool = True
    import_path: str | None = None

    def __post_init__(self) -> None:
        self.name = self.name.strip().replace("-", "_")
        if not self.name:
            raise ValueError("feature name is required")
        self.example_topic = self.example_topic.strip() or "syntax"

    @property
    def marker(self) -> str:
        return f"test_example:{self.name}"

    @property
    def test_base(self) -> str:
        base = self.name if self.name.endswith("_test") else f"{self.name}_test"
        return base


@dataclass
class PkgSpec:
    name: str
    version: str = "0.1.0"
    module_name: str | None = None
    link_lib: str | None = None
    rt_file: str | None = None

    def __post_init__(self) -> None:
        self.name = self.name.strip()
        if not self.name:
            raise ValueError("package name is required")
        if self.module_name is None:
            self.module_name = self.name.replace("-", "_")
        if self.rt_file is None:
            self.rt_file = f"rt/{self.module_name}.c"

    @property
    def marker(self) -> str:
        return f"pkg:{self.name}"


@dataclass
class CliSpec:
    name: str
    kind: CliKind = CliKind.SUBCOMMAND
    description: str = "TODO: describe this command"

    def __post_init__(self) -> None:
        self.name = self.name.strip().replace("-", "_")
        if not self.name:
            raise ValueError("CLI name is required")

    @property
    def marker(self) -> str:
        return f"cli:{self.name}:{self.kind.value}"


@dataclass
class ConformanceSpec:
    name: str
    mode: ConformanceMode
    area: str = "edge"
    description: str = "TODO: describe contract"

    def __post_init__(self) -> None:
        self.name = self.name.strip().replace("-", "_")
        if not self.name:
            raise ValueError("conformance test name is required")
        self.area = self.area.strip() or "edge"

    @property
    def marker(self) -> str:
        return f"conformance:{self.mode.value}:{self.name}"


@dataclass
class SyntaxSpec:
    keyword: str
    feature_name: str
    description: str = "TODO: describe the syntax change"
    needs_expand: bool = True
    needs_const_eval: bool = False

    def __post_init__(self) -> None:
        self.keyword = self.keyword.strip()
        self.feature_name = self.feature_name.strip().replace("-", "_")
        if not self.keyword or not self.feature_name:
            raise ValueError("keyword and feature_name are required")

    @property
    def marker(self) -> str:
        return f"syntax:{self.feature_name}"


@dataclass
class CLibRegistrySpec:
    """Slim registry/c/*.toml entry — system PM installs; Nyra binds/links."""

    name: str
    headers: list[str]
    libs: list[str]
    description: str = ""
    pkg_config: str | None = None
    brew: str | None = None
    apt: str | None = None
    pacman: str | None = None
    dnf: str | None = None
    aliases: list[str] = field(default_factory=list)
    git: str | None = None
    depends: list[str] = field(default_factory=list)
    impl_define: str | None = None

    def __post_init__(self) -> None:
        self.name = self.name.strip().lower().replace(" ", "-")
        if not self.name:
            raise ValueError("C library name is required")
        if not re.fullmatch(r"[a-z][a-z0-9_+-]*", self.name):
            raise ValueError(
                f"invalid name {self.name!r} — use lowercase letters, digits, _, +, -"
            )
        self.headers = [h.strip().lstrip("/") for h in self.headers if h and h.strip()]
        if not self.headers:
            raise ValueError("at least one header is required (e.g. sodium.h)")
        self.libs = [lib.strip() for lib in self.libs if lib and lib.strip()]
        if not self.libs:
            raise ValueError("at least one link lib is required (e.g. sodium — no lib prefix)")
        self.description = (self.description or "").strip()
        self.pkg_config = _opt_str(self.pkg_config)
        self.brew = _opt_str(self.brew) or self.name
        self.apt = _opt_str(self.apt)
        self.pacman = _opt_str(self.pacman)
        self.dnf = _opt_str(self.dnf)
        self.git = _opt_str(self.git)
        self.impl_define = _opt_str(self.impl_define)
        self.aliases = [a.strip() for a in self.aliases if a and a.strip()]
        self.depends = [d.strip() for d in self.depends if d and d.strip()]

    @property
    def marker(self) -> str:
        return f"c_lib:{self.name}"

    @property
    def toml_relpath(self) -> str:
        return f"registry/c/{self.name}.toml"


def _opt_str(value: str | None) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    if not text or text.lower() in {"-", "skip", "none", "n/a"}:
        return None
    return text


def normalize_ny_module(raw: str) -> str:
    raw = raw.strip().replace("\\", "/")
    for prefix in ("stdlib/", "./stdlib/"):
        if raw.startswith(prefix):
            raw = raw[len(prefix) :]
    if raw.endswith(".ny.ny"):
        raw = raw[:-3]
    if raw.endswith(".ny"):
        return raw
    if raw.endswith("/mod") or raw.endswith("/mod.ny"):
        return raw.rstrip("/") + ("" if raw.endswith(".ny") else ".ny")
    if raw.endswith("mod"):
        return f"{raw}.ny"
    if "/" in raw:
        return f"{raw}.ny"
    return f"{raw}.ny"


def guess_rt_module(ny_module: str, fn_name: str | None = None) -> str:
    if fn_name and fn_name.startswith("map_str_str_"):
        return "rt_map_str_str.c"
    if fn_name and fn_name.startswith("map_str_i32_"):
        return "rt_map.c"
    stem = ny_module.split("/")[0].replace(".ny", "")
    mapping = {
        "json": "rt_json.c",
        "strings": "rt_strings.c",
        "crypto": "rt_crypto.c",
        "fs": "rt_fs.c",
        "net": "rt_net.c",
        "time": "rt_time.c",
        "random": "rt_random.c",
        "compress": "rt_compress.c",
        "process": "rt_process.c",
        "error": "rt_error.c",
        "encoding": "rt_strings.c",
        "strconv": "rt_strings.c",
        "math": "rt_math.c",
        "vec": "rt_vec.c",
        "map": "rt_map.c",
    }
    return mapping.get(stem, f"rt_{stem}.c")


def builtin_example_topic(ny_module: str) -> str:
    """Folder name under examples/builtins/ — never ends with `.ny`."""
    top = ny_module.split("/")[0]
    if top.endswith(".ny"):
        top = top[:-3]
    return top or "stdlib"


def stdlib_builtin_examples_dir(ny_module: str):
    from .paths import EXAMPLES

    return EXAMPLES / "builtins" / builtin_example_topic(ny_module)


def uses_stdlib_builtin_examples(ny_module: str) -> bool:
    root = ny_module.split("/")[0]
    if root.endswith(".ny"):
        return True
    return ny_module.split("/")[0] in {"encoding", "strconv"}
