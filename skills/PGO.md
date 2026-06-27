# 🚀 Next-Gen Performance in Nyra: Automated PGO, One Command

Modern app performance is about smart, real-world optimization—not just faster CPUs or bigger frameworks. Nyra brings this to every developer with effortless, fully automated Profile-Guided Optimization. One command. No trade-offs.

---

## Why Profile-Guided Optimization (PGO)?

Traditionally, compilers "guess" which parts of your code are hot, but they can't know how your app really runs in production. JIT engines (like in JavaScript or Java) do adapt, but at the cost of higher memory and complexity.

**PGO brings the best of both:**  
- Near-JIT intelligence, zero runtime bloat  
- Lean, predictable, compiled binaries

---

## 🛠️ How Nyra’s Automatic PGO Pipeline Works

Run:

```sh
nyra build --pgo .
```

and behind the scenes, Nyra orchestrates five seamless stages:

1. **Instrumented Build:**  
   Nyra injects ultra-lightweight performance probes as it builds a temporary "spy" binary.

2. **Automatic Training:**  
   That instrumented binary runs (using your tests or `main()`), capturing live performance data.

3. **Profile Data Merge:**  
   LLVM tools crunch the data into a compact, optimized `nyra.profdata`.

4. **Optimized Final Build:**  
   Leveraging that profile, Nyra re-builds for the *real* world: smarter inlining, superior memory layout, better branch prediction, and ThinLTO for maximum speed.

5. **Smart Cache:**  
   If your code hasn't changed, Nyra skips training and reuses the last-good profile for blazing fast iterative builds.

---

## 💡 What You Get

- **Real-World Speed**: Loops, math, and branch-heavy code run up to _10–30% faster_.
- **Intelligent Inlining**: Critical functions are inlined only if it matters—automatically.
- **Better Memory Use**: No bulky JIT engines; just your data, pure and simple.
- **Optimal Code Layout**: Hot paths are grouped for maximum CPU cache efficiency.
- **Fewer Surprises**: The compiler adapts to your *actual* workloads, not just what’s on paper.

---

## 🚦 Getting Started

Just run:

```sh
nyra build --pgo .
```

Nyra takes care of the rest—no manual steps, no extra config.  
> **Tip:** Make sure your machine has the full LLVM toolchain (including `llvm-profdata` and `opt`) for best results.

---

**The barrier between smart and fast is gone. Build your best, with Nyra and PGO.**  
Curious about your results? Share your wins and benchmarks — the future is here!