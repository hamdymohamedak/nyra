#!/usr/bin/env python3
"""Generate docs/ar/ملحق-ب-فهرس-الملفات.md — Arabic file index for the Nyra repo."""

from __future__ import annotations

import os
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "docs" / "ar" / "ملحق-ب-فهرس-الملفات.md"

SKIP_DIRS = {
    ".git",
    "target",
    "node_modules",
    ".cursor",
    "__pycache__",
}

# Exact path -> (type_ar, description_ar, section_ref)
KNOWN: dict[str, tuple[str, str, str]] = {
    "Cargo.toml": ("إعداد", "جذر workspace Rust — أعضاء المشروع", "10"),
    "README.md": ("توثيق", "نظرة عامة على Nyra بالإنجليزية", "00"),
    "CONTRIBUTING.md": ("توثيق", "دليل المساهمة", "10"),
    "CHANGELOG.md": ("توثيق", "سجل الإصدارات", "10"),
    "LICENSE": ("قانوني", "ترخيص المشروع", "10"),
    "install.md": ("توثيق", "دليل التثبيت", "05"),
    "settings.md": ("إعداد", "ربط *.ny بالمحرر", "10"),
    "cli/src/main.rs": ("Rust", "نقطة دخول أمر nyra — كل subcommands", "08"),
    "cli/src/link.rs": ("Rust", "ربط LLVM IR + C runtime عبر clang", "08"),
    "cli/src/target.rs": ("Rust", "cross-compilation وأهداف LLVM", "08"),
    "cli/src/artifacts.rs": ("Rust", "مسارات target/debug و release", "08"),
    "cli/src/fmt.rs": ("Rust", "منسّق المصدر nyra fmt", "08"),
    "compiler/driver/src/lib.rs": ("Rust", "Orchestrator خط أنابيب المترجم", "07"),
    "compiler/driver/src/features.rs": ("Rust", "أعلام الميزات FeatureSet", "07"),
    "compiler/driver/src/stability.rs": ("Rust", "تحذيرات Core/Extended W001", "07"),
    "compiler/errors/src/lib.rs": ("Rust", "NyraError, Span, ErrorReporter", "07"),
    "compiler/ast/src/lib.rs": ("Rust", "تعريفات AST كاملة", "07"),
    "compiler/ast/src/span.rs": ("Rust", "مساعدات span على العقد", "07"),
    "compiler/lexer/src/lib.rs": ("Rust", "Lexer::tokenize — تقطيع لرموز", "07"),
    "compiler/parser/src/lib.rs": ("Rust", "Parser — بناء AST", "07"),
    "compiler/parser/src/recovery.rs": ("Rust", "استرداد أخطاء التحليل", "07"),
    "compiler/parser/src/lang_features.rs": ("Rust", "صياغة Extended", "07"),
    "compiler/resolve/src/lib.rs": ("Rust", "load_program — دمج imports", "07"),
    "compiler/resolve/src/paths.rs": ("Rust", "اكتشاف main.ny", "07"),
    "compiler/resolve/src/stdlib.rs": ("Rust", "حل مسارات stdlib", "07"),
    "compiler/expand/src/lib.rs": ("Rust", "توسيع الماكرو", "07"),
    "compiler/monomorph/src/lib.rs": ("Rust", "monomorphize generics", "07"),
    "compiler/const_eval/src/lib.rs": ("Rust", "تقييم وتجميع الثوابت", "07"),
    "compiler/types/src/lib.rs": ("Rust", "IR داخلي للأنواع", "07"),
    "compiler/typecheck/src/lib.rs": ("Rust", "TypeChecker الرئيسي", "07"),
    "compiler/typecheck/src/lang.rs": ("Rust", "قواعد أنواع Nyra", "07"),
    "compiler/typecheck/src/ffi.rs": ("Rust", "فحص FFI و repr(C)", "07"),
    "compiler/ownership/src/lib.rs": ("Rust", "analyze_program و check_lifetimes", "07"),
    "compiler/ownership/src/context.rs": ("Rust", "OwnershipCtx", "07"),
    "compiler/ownership/src/drop.rs": ("Rust", "DropPlan", "07"),
    "compiler/ownership/src/kind.rs": ("Rust", "Copy vs Move", "07"),
    "compiler/ownership/src/nll.rs": ("Rust", "Non-lexical lifetimes", "07"),
    "compiler/ownership/src/lifetime.rs": ("Rust", "التحقق من معاملات العمر", "07"),
    "compiler/ownership/src/send_sync.rs": ("Rust", "Send/Sync لـ spawn", "07"),
    "compiler/ownership/src/subtype.rs": ("Rust", "توافق الأنواع", "07"),
    "compiler/borrowck/src/lib.rs": ("Rust", "فحص القروض والنقل", "07"),
    "compiler/codegen/src/lib.rs": ("Rust", "تصدير Codegen و RuntimeProfile", "07"),
    "compiler/codegen/src/llvm.rs": ("Rust", "توليد LLVM IR", "07"),
    "compiler/codegen/src/runtime_map.rs": ("Rust", "ربط ميزات → ملفات C", "07"),
    "lsp/src/lib.rs": ("Rust", "خادم LSP — tower-lsp", "08"),
    "pkg/src/lib.rs": ("Rust", "API NyraPkg", "08"),
    "pkg/src/lockfile.rs": ("Rust", "nyra.lock", "08"),
    "pkg/src/registry.rs": ("Rust", "حل حزم محلي", "08"),
    "pkg/src/registry_client.rs": ("Rust", "عميل HTTP للسجل", "08"),
    "pkg/src/semver.rs": ("Rust", "تحليل إصدارات semver", "08"),
    "pkg-registry/src/main.rs": ("Rust", "سجل HTTP محلي للتطوير", "08"),
    "rt/src/lib.rs": ("Rust", "runtime تجريبي Rust", "08"),
    "stdlib/nyra_rt.c": ("C", "مجمّع runtime الأصلي", "06"),
    "stdlib/nyra_rt_wasi.c": ("C", "مجمّع runtime Wasm", "06"),
    "stdlib/nyra_rt.h": ("C", "رأس API الـ runtime", "06"),
    "stdlib/vec.ny": ("Nyra", "Vec_i32 auto-prelude", "06"),
    "App/main.ny": ("Nyra", "تطبيق مرجعي hello world", "09"),
    "grammar/nyra.tmLanguage.json": ("JSON", "قواعد TextMate للتلوين", "10"),
    "examples/syntax/hello.ny": ("Nyra", "مثال print أساسي", "09"),
    "examples/syntax/math.ny": ("Nyra", "مثال حساب", "09"),
    "tests/corpus/manifest.toml": ("TOML", "قائمة corpus لـ CI", "09"),
    "benchmarks/ci-baseline.json": ("JSON", "حدود أداء CI", "10"),
    "docs/abi-manifest.toml": ("TOML", "رموز ABI المتوقعة", "10"),
    "scripts/install.sh": ("Shell", "مثبّت المستخدمين", "10"),
    "scripts/test-all.sh": ("Shell", "تشغيل كل الاختبارات", "10"),
    "scripts/gen-ar-file-index.py": ("Python", "يولّد هذا الفهرس", "10"),
    "webDocs/index.html": ("HTML", "صفحة رئيسية للتوثيق", "10"),
}

# Prefix -> (type_ar, description_template, section_ref)
PREFIX_RULES: list[tuple[str, str, str, str]] = [
    ("compiler/driver/tests/snapshots/", "Snapshot", "لقطة Insta للمترجم", "07"),
    ("compiler/driver/tests/", "اختبار", "اختبار تكامل المترجم", "07"),
    ("compiler/", "Rust", "جزء من المترجم", "07"),
    ("cli/", "Rust", "أداة nyra CLI", "08"),
    ("stdlib/rt_wasi/", "C", "runtime Wasm WASI", "06"),
    ("stdlib/rt/", "C", "وحدة runtime أصلية", "06"),
    ("stdlib/", "Nyra", "مكتبة قياسية Nyra", "06"),
    ("examples/syntax/", "Nyra", "مثال صياغة اللغة", "09"),
    ("examples/projects/", "Nyra", "مشروع متعدد الملفات", "09"),
    ("examples/ffi/", "Nyra/Host", "مثال FFI", "09"),
    ("examples/comparison/", "Benchmark", "مقارنة أداء بلغات", "09"),
    ("examples/", "Nyra", "مثال أو عينة", "09"),
    ("tests/", "اختبار", "اختبار Nyra أو corpus", "09"),
    ("scripts/", "Shell/Python", "سكربت تطوير أو CI", "10"),
    ("webDocs/scripts/", "Script", "بناء موقع التوثيق", "10"),
    ("webDocs/", "HTML/CSS/JS", "موقع توثيق ثابت", "10"),
    ("docs/ar/", "توثيق عربي", "فصل من الدليل العربي", "README"),
    ("docs/", "توثيق", "وثائق تقنية", "10"),
    ("skills/", "تصميم", "ملاحظة تصميم داخلية", "10"),
    ("fuzz/", "Fuzz", "هدف libFuzzer", "08"),
    (".github/workflows/", "CI", "workflow GitHub Actions", "10"),
    ("grammar/", "Grammar", "تلوين صياغة المحرر", "10"),
]


def file_type(path: str) -> str:
    ext = Path(path).suffix.lower()
    return {
        ".rs": "Rust",
        ".ny": "Nyra",
        ".c": "C",
        ".h": "C",
        ".md": "Markdown",
        ".html": "HTML",
        ".json": "JSON",
        ".toml": "TOML",
        ".sh": "Shell",
        ".py": "Python",
        ".mjs": "JavaScript",
        ".js": "JavaScript",
        ".css": "CSS",
        ".xml": "XML",
        ".snap": "Snapshot",
        ".java": "Java",
        ".go": "Go",
        ".cpp": "C++",
        ".yml": "YAML",
        ".yaml": "YAML",
    }.get(ext, "ملف")


def describe(rel: str) -> tuple[str, str, str]:
    rel_posix = rel.replace("\\", "/")
    if rel_posix in KNOWN:
        return KNOWN[rel_posix]
    for prefix, typ, desc, section in PREFIX_RULES:
        if rel_posix.startswith(prefix):
            name = Path(rel_posix).name
            if desc.endswith(")"):
                return typ, f"{desc}: {name}", section
            return typ, f"{desc} — {name}", section
    return file_type(rel_posix), f"ملف في {Path(rel_posix).parent or '/'}", "—"


def section_link(section: str) -> str:
    if section == "README":
        return "[README](README.md)"
    if section == "—":
        return "—"
    mapping = {
        "00": "00-مقدمة.md",
        "05": "05-أدوات-nyra.md",
        "06": "06-المكتبة-القياسية.md",
        "07": "07-المترجم-ملف-بملف.md",
        "08": "08-الأدوات-ملف-بملف.md",
        "09": "09-الأمثلة-والاختبارات.md",
        "10": "10-البنية-التحتية.md",
    }
    fname = mapping.get(section, f"{section}-*.md")
    return f"[{section}]({fname})"


def collect_files() -> list[str]:
    files: list[str] = []
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = sorted(d for d in dirnames if d not in SKIP_DIRS)
        for name in sorted(filenames):
            full = Path(dirpath) / name
            rel = full.relative_to(ROOT).as_posix()
            files.append(rel)
    return files


def main() -> int:
    files = collect_files()
    lines = [
        "# ملحق ب — فهرس الملفات",
        "",
        f"> **مُولَّد تلقائياً** بـ `scripts/gen-ar-file-index.py` — {date.today().isoformat()}",
        f"> **عدد الملفات:** {len(files)}",
        "",
        "فهرس شامل لملفات المستودع. للتفاصيل راجع القسم المرتبط.",
        "",
        "| المسار | النوع | الوظيفة في سطر واحد | القسم التفصيلي |",
        "|--------|-------|---------------------|----------------|",
    ]
    for rel in files:
        typ, desc, section = describe(rel)
        desc = desc.replace("|", "\\|")
        lines.append(f"| `{rel}` | {typ} | {desc} | {section_link(section)} |")

    lines.extend(
        [
            "",
            "---",
            "",
            "لإعادة التوليد:",
            "",
            "```bash",
            "python3 scripts/gen-ar-file-index.py",
            "```",
            "",
        ]
    )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {len(files)} entries to {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
