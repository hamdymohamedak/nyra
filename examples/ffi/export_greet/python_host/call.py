#!/usr/bin/env python3
"""Load Nyra cdylib built with: nyra build ../main.ny -o libnyra_greet --cdylib"""
import ctypes
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIB = ROOT / "target" / "debug" / "libnyra_greet.dylib"
if not LIB.exists():
    LIB = ROOT / "target" / "debug" / "libnyra_greet.so"
if not LIB.exists():
    subprocess.check_call(
        [
            "cargo",
            "run",
            "-q",
            "-p",
            "cli",
            "--",
            "build",
            str(Path(__file__).resolve().parents[1] / "main.ny"),
            "-o",
            "libnyra_greet",
            "--cdylib",
        ],
        cwd=ROOT,
    )

lib = ctypes.CDLL(str(LIB))
lib.add.argtypes = [ctypes.c_int, ctypes.c_int]
lib.add.restype = ctypes.c_int
lib.greet.argtypes = [ctypes.c_char_p]
lib.greet.restype = ctypes.c_void_p
lib.free.argtypes = [ctypes.c_void_p]
lib.free.restype = None

assert lib.add(10, 32) == 42
raw = lib.greet(b"World")
msg = ctypes.string_at(raw).decode()
lib.free(raw)
assert msg == "Hello, World"
print("export_greet python_host: ok")
