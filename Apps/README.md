# Apps

Nyra applications and sample projects — **not** part of the compiler, stdlib, or language toolchain.

## Projects

| Path | Description |
|------|-------------|
| `GhostTerm/` | GPU + CLI terminal (PTY, tabs, raylib) |
| `Calculator/` | Calculator sample |
| `FizzBuzz/` | FizzBuzz sample |
| `Fibonacci/` | Fibonacci sample |
| `Factorial/` | Factorial sample |
| `Prime_Numbers/` | Prime numbers sample |
| `Binary_Search/` | Binary search sample |
| `Hash_Map/` | Hash map sample |
| `Linked_List/` | Linked list sample |
| `Sorting/` | Sorting sample |
| `MiniEdit/` | Console text editor |
| `FileCopy/` | Chunked file copy |
| `NyCompress/` | File compression (RLE) |
| `MiniHTTP/` | HTTP/1.1 server |
| `NyChat/` | TCP chat (server/client) |
| `TaskCLI/` | Task manager CLI |

See `plan.md` for Phase 1 (language smoke tests) and Phase 2 (console programs).

## GhostTerm

```bash
# CLI shell
cd Apps/GhostTerm && nyra run .

# GPU window (requires raylib)
cd Apps/GhostTerm/gpu && nyra run .
```

See `GhostTerm/projectPlan` for the full feature roadmap.
