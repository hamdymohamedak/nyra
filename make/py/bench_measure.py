#!/usr/bin/env python3
"""Measure a subprocess: wall time, peak RSS, CPU, and optional GPU usage."""
from __future__ import annotations

import platform
import resource
import shutil
import subprocess
import sys
import threading
import time


def _rss_kb(maxrss: int) -> int:
    if platform.system() == "Darwin":
        return int(maxrss / 1024)
    return int(maxrss)


def _gpu_sampler(samples: list[tuple[float, float]], stop: threading.Event) -> None:
    if not shutil.which("nvidia-smi"):
        return
    while not stop.is_set():
        try:
            out = subprocess.check_output(
                [
                    "nvidia-smi",
                    "--query-gpu=utilization.gpu,memory.used",
                    "--format=csv,noheader,nounits",
                ],
                text=True,
                timeout=2,
            )
            for line in out.strip().splitlines():
                parts = [p.strip() for p in line.split(",")]
                if len(parts) >= 2:
                    samples.append((float(parts[0]), float(parts[1])))
        except (subprocess.SubprocessError, ValueError, OSError):
            pass
        stop.wait(0.05)


def measure_once(cmd: list[str]) -> dict[str, float]:
    gpu_samples: list[tuple[float, float]] = []
    gpu_stop = threading.Event()
    gpu_thread = threading.Thread(
        target=_gpu_sampler, args=(gpu_samples, gpu_stop), daemon=True
    )
    gpu_thread.start()

    start = time.perf_counter()
    subprocess.run(cmd, stdout=subprocess.DEVNULL, check=True)
    wall_ms = (time.perf_counter() - start) * 1000.0

    gpu_stop.set()
    gpu_thread.join(timeout=1.0)

    ru = resource.getrusage(resource.RUSAGE_CHILDREN)
    user_ms = ru.ru_utime * 1000.0
    sys_ms = ru.ru_stime * 1000.0
    cpu_ms = user_ms + sys_ms
    cpu_pct = (cpu_ms / wall_ms * 100.0) if wall_ms > 0 else 0.0

    gpu_util = max((s[0] for s in gpu_samples), default=0.0)
    gpu_mem_mb = max((s[1] for s in gpu_samples), default=0.0)

    return {
        "wall_ms": wall_ms,
        "peak_rss_kb": _rss_kb(ru.ru_maxrss),
        "cpu_user_ms": user_ms,
        "cpu_sys_ms": sys_ms,
        "cpu_pct": cpu_pct,
        "minflt": float(ru.ru_minflt),
        "majflt": float(ru.ru_majflt),
        "vol_ctx": float(ru.ru_nvcsw),
        "invol_ctx": float(ru.ru_nivcsw),
        "gpu_util_pct": gpu_util,
        "gpu_mem_mb": gpu_mem_mb,
    }


def main() -> None:
    if len(sys.argv) < 2:
        print("usage: bench_measure.py <command...>", file=sys.stderr)
        sys.exit(2)
    m = measure_once(sys.argv[1:])
    # wall_ms peak_rss_kb cpu_user_ms cpu_sys_ms cpu_pct minflt majflt vol_ctx invol_ctx gpu_util_pct gpu_mem_mb
    print(
        f"{m['wall_ms']:.6f} {int(m['peak_rss_kb'])} "
        f"{m['cpu_user_ms']:.4f} {m['cpu_sys_ms']:.4f} {m['cpu_pct']:.2f} "
        f"{int(m['minflt'])} {int(m['majflt'])} "
        f"{int(m['vol_ctx'])} {int(m['invol_ctx'])} "
        f"{m['gpu_util_pct']:.2f} {m['gpu_mem_mb']:.2f}"
    )


if __name__ == "__main__":
    main()
