# Escape Analysis — Nyra Compiler

> **الحالة:** المراحل 1–4 **مُنفَّذة** (2026). التحليل يعمل تلقائياً في كل بناء؛ استخدم `nyra build --verbose` (أو `-v`) لطباعة التقرير.

Nyra يبني **Escape Graph** على مستوى AST بعد فحص الاقتراض (borrow check) وقبل توليد LLVM IR. الهدف: إثبات أن قيم محلية لا «تهرب» خارج نطاق الدالة، ثم تقليل تخصيصات الـ heap والـ locks في codegen.

---

## التصميم المعماري

في المترجمات التقليدية غالباً يُؤجَّل التحليل إلى passes متأخرة في LLVM بعد فقدان هوية القيم. Nyra يربط التحليل مباشرة بقواعد الملكية (`&`, `mut`, `spawn`, `return`, `channel.send`).

### حالات الهروب (Escape States)

| الحالة | المعنى | أثر codegen |
|--------|--------|-------------|
| **NoEscape** | القيمة تُنشأ وتُستهلك داخل نفس الدالة | stack promotion، SROA، تخطّي clone/free غير ضروري |
| **ArgEscape** | تُمرَّر كمرجع لدالة أخرى دون إرجاع أو spawn | تبقى على stack الدالة الأم |
| **GlobalEscape** | `return`، `spawn` capture، أو قيمة تُرسَل عبر قناة | heap / runtime channel كالمعتاد |

التنفيذ: `compiler/ownership/src/escape.rs` — `EscapeGraph`, `analyze_escapes()`, `EscapePlan`.

---

## المراحل المنفَّذة

### المرحلة 1 — Escape Graph ✅

- تتبع `let`، الإسناد، `&` / `&mut`، `return`، `spawn`، `channel.send` / `recv`.
- `EscapePlan.bindings`: `func → name → EscapeState`.
- يعمل في `compiler/driver/src/lib.rs` بعد borrow/lifetime؛ يُمرَّر إلى codegen عبر `CompileOutput.escape_plan`.
- اختبارات: `compiler/ownership/src/escape.rs`, `compiler/driver/tests/escape_analysis.rs`.

### المرحلة 2 — Stack promotion & SROA ✅

في `compiler/codegen/src/llvm.rs`:

- **`binding_no_escape()`** — يقرأ `EscapePlan` لكل binding.
- **Struct literals NoEscape** — حقول `string` ثابتة بدون `nyra_str_clone`.
- **`no_escape_stack_safe`** — structs مركّبة NoEscape بدون `nyra_free` على الحقول.
- **SROA (`Binding::PromotedStruct`)** — structs من scalars قابلة للنسخ بالكامل → registers منفصلة (لا `%Point = alloca`).
- **استثناء:** struct literals مع spread (`..p`) لا تُروَّج (SROA معطّل).

### المرحلة 3 — LocalChannel ✅

- `EscapePlan.local_channels` — قنوات **NoEscape** غير مُلتقَطة في `spawn`.
- handle القناة لا يُعلَّم ArgEscape عند `send`/`recv` (القيم المُرسَلة فقط GlobalEscape).
- codegen: `%NyraLocalChannel_T` — ring buffer على stack (سعة 16)، بدون `rt_channel.c` / mutex.
- `Binding::LocalChannel` — IR مضمّن لـ send/recv.
- إذا أُرسِلت القناة إلى `spawn` → runtime channel كالمعتاد.

### المرحلة 4 — `#[no_escape]` ✅

```nyra
fn process(#[no_escape] data: &string) {
    print(data)
}

fn bad(#[no_escape] data: &string) -> &string {
    return data   // E0602
}
```

- Lexer: `TokenKind::AttrNoEscape`
- Parser: `Param.no_escape`
- Typecheck **E0601**: `#[no_escape]` فقط على `&T`
- Escape analysis: **E0602** إذا المعامل GlobalEscape (return / spawn / send)
- Codegen: المعامل يُعامَل كـ NoEscape عند الالتزام

الملفات: `compiler/ownership/src/no_escape.rs`, parser/lexer/ast/typecheck.

---

## واجهة المطوّر

### تقرير verbose

```bash
nyra build --verbose file.ny
# أو
nyra build -v .
```

مثال مخرجات:

```text
   Checking  escape analysis
  escape: main::user → NoEscape
  escape: main::chan → NoEscape
  local channel: main::chan → LocalChannel (stack ring buffer)
  no_escape param: process::data (must not return/spawn/send)
```

### مثال Nyra

```nyra
struct User {
    id: i32,
    name: string,
}

fn main() {
    let user = User { id: 101, name: "Hamdy" }

    let chan = Channel::new()
    chan.send(user.id)
    let active_id = chan.recv()

    println("Active User ID: {}", active_id)
}
```

مع `--verbose`: `user` و `chan` → NoEscape؛ `chan` → LocalChannel.

---

## خط أنابيب التجميع

```text
parse → typecheck → borrow/lifetime → analyze_escapes()
       → check_no_escape() → monomorph → codegen (EscapePlan)
```

---

## القيود الحالية

- SROA للـ structs فقط عند all-copy scalar fields وبدون spread.
- LocalChannel: sequential فقط، سعة ثابتة 16، لا spawn.
- Strings الديناميكية (غير literal) ما زالت heap-owned عند GlobalEscape.
- التقرير verbose اختياري؛ التحسينات تُطبَّق صامتاً في release/debug.

---

## المراجع

| الموضوع | المسار |
|---------|--------|
| Escape graph | `compiler/ownership/src/escape.rs` |
| `#[no_escape]` | `compiler/ownership/src/no_escape.rs` |
| Codegen | `compiler/codegen/src/llvm.rs` |
| Driver | `compiler/driver/src/lib.rs` |
| اختبارات | `compiler/driver/tests/escape_analysis.rs` |
| توثيق الويب | `webDocs/escape-analysis.html` |

---

## الخلاصة

بعد تنفيذ هذه المراحل، Nyra يقلّل تخصيصات heap و locks **استاتيكياً** حيث يثبت borrow checker + escape analysis أن القيم محلية — دون تغيير syntax يومي للمطوّر. يُكمّل PGO و release flags في `webDocs/performance.html`.

**Roadmap أوسع:** [`PERFORMANCE_ROADMAP.md`](PERFORMANCE_ROADMAP.md) — SSA للحلقات، PGO في CI، generics، SIMD، ecosystem.
