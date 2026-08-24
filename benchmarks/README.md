# Reproducible benchmark

The benchmark is a normal MoonBit executable rather than a synthetic source
counter. It performs 10,000 NEWS2 calculations, accumulates the returned score,
and counts critical reports.

```bash
moon run cmd/benchmark
```

Expected deterministic output with the current input generator:

```text
iterations=10000
checksum=54000
critical_reports=4500
```

The checksum is a regression signal for the workload. It is not a clinical
metric and is not a substitute for correctness tests. To collect wall-clock
data, run the command on the target machine with the installed stable MoonBit
version and record the operating system, CPU, target, and command line.

One local Windows PowerShell run on 2026-08-24 measured five warm-cache
invocations at 129.10, 120.08, 122.17, 123.39, and 147.53 ms (arithmetic mean:
128.45 ms), using MoonBit `0.1.20260824` and the native host runner. These are
machine-specific observations, not portable performance guarantees.
