#!/usr/bin/env python3
"""JSON line worker for Nyra bridge — read one line stdin, write one line stdout."""
import json
import sys


def handle(req: dict) -> str:
    op = req.get("op")
    if op == "eval":
        expr = str(req.get("expr", "0"))
        allowed = set("0123456789+-*/() ")
        if not all(c in allowed for c in expr):
            return "0"
        return str(eval(expr, {"__builtins__": {}}, {}))
    if op == "add":
        return str(int(req.get("a", 0)) + int(req.get("b", 0)))
    if op == "pip_install_hint":
        return "use pip in worker venv — see docs/bridge.md"
    return "error"


def main() -> None:
    line = sys.stdin.readline()
    if not line:
        print(json.dumps({"ok": False, "error": "empty stdin"}), flush=True)
        return
    try:
        req = json.loads(line.strip())
        result = handle(req)
        print(json.dumps({"ok": True, "result": result}), flush=True)
    except Exception as exc:  # noqa: BLE001 — worker boundary
        print(json.dumps({"ok": False, "error": str(exc)}), flush=True)


if __name__ == "__main__":
    main()
