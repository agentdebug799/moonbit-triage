# moonbit-triage

`moonbit-triage` is a dependency-free MoonBit library for explainable, auditable
clinical score computation in education, software validation, data-quality
pipelines, and prototype integrations. It returns component contributions and
structured range errors so a caller can inspect exactly how a result was made.

The library computes NEWS2, qSOFA, GCS, SIRS, MEWS, SOFA, PEWS, CURB-65, Shock
Index, ROX Index, Wells PE, HEART, and CHA2DS2-VASc. It also provides combined
reports, batch summaries, and measurement-quality flags.

## Core capabilities

- Typed inputs with explicit inclusive threshold functions.
- Component-level explanations and stable severity bands.
- First-error validation for common measurement ranges.
- Integer-scaled ratio APIs (`Shock Index x100`, `ROX Index x100`) for portable,
  deterministic results across MoonBit targets.
- Batch summaries and quality flags for form or data-pipeline integration.
- No external runtime dependencies; `wasm-gc` is the preferred target.

## Quick start

```bash
moon check
moon test
moon run cmd/main
```

The runnable CLI prints a combined NEWS2/qSOFA/GCS assessment and its summary.
For a deterministic workload used by the benchmark section, run:

```bash
moon run cmd/benchmark
```

## CLI

The example CLI is intentionally small and demonstrates the public API rather
than acting as a clinical decision system. Applications can construct records,
call `score_*`, inspect `ScoreReport.explanations`, and route validation errors
through their own forms or service boundaries.

## Minimal example

```mbt check
///|
test "README NEWS2 example" {
  let report = @moonbit-triage.score_news2({
    respiratory_rate: 16,
    oxygen_saturation: 98,
    spo2_scale: @moonbit-triage.Scale1,
    supplemental_oxygen: false,
    temperature_tenths_c: 370,
    systolic_bp: 120,
    heart_rate: 72,
    consciousness: @moonbit-triage.Alert,
  })
  inspect(report.score, content="0")
  debug_inspect(report.severity, content="Low")
}
```

## Architecture and API shape

The public API intentionally uses plain records and enums so that callers can
wire the library into CLI tools, web forms, or data-validation pipelines without
extra dependencies. Each `ScoreReport` includes:

- `instrument`: scoring instrument name.
- `score`: numeric total.
- `severity`: local library band for software routing.
- `interpretation`: short explanation of the band.
- `explanations`: component-level point contributions.
- `disclaimer`: safety boundary text.

The root package owns the public data types and scoring facade. Focused files
contain each instrument; `quality.mbt` handles measurement metadata and
`batch.mbt` handles deterministic aggregation. The generated
`pkg.generated.mbti` is checked in as a compact public API review surface.

## Sources and safety

The implementation follows publicly described scoring thresholds for NEWS2,
qSOFA, and GCS. The qSOFA criteria are also summarized by the public qSOFA
project: respiratory rate at least 22/min, systolic blood pressure at most
100 mmHg, and GCS below 15. Clinical scoring rules can be embedded in local
protocols differently, so downstream projects should review the thresholds
against their intended policy before use.

This project is for education, audit, and software validation. It is not a
medical device and must not replace clinician judgment.

Rule provenance, primary reference links, implementation scope, and explicit
non-claims are documented in [PROVENANCE.md](PROVENANCE.md).

Every score is a rule implementation, not a diagnosis. This package must not
be used as a substitute for clinician judgment, local policy, or a regulated
medical-device workflow. Downstream users are responsible for validating the
chosen thresholds, patient population, units, and escalation policy.

## Benchmarks

The checked-in benchmark runs 10,000 NEWS2 calculations and prints a checksum
and count, making correctness and workload size reproducible without claiming
hardware-independent latency. On the maintainer workstation with MoonBit
`0.1.20260807`, the command produced:

```text
iterations=10000
checksum=54000
critical_reports=4500
```

Measure wall-clock time locally with PowerShell (`Measure-Command { moon run
cmd/benchmark }`) or `/usr/bin/time` on Unix; report the machine and toolchain
when comparing runs.

## Tests and CI

The test suite covers threshold transitions, invalid ranges, aggregate scores,
quality flags, and deterministic summaries. GitHub Actions runs formatting,
all-target checks, public API generation, wasm-gc tests, native tests, and a
coverage summary on Linux, macOS, and Windows.

## Development notes

- MoonBit module: `agentdebug799/moonbit-triage`.
- License: Apache-2.0.
- Preferred target: `wasm-gc`.
- Validation used for release: `moon fmt --check`, `moon check --deny-warn`,
  `moon info`, `moon test --deny-warn`, and the benchmark command.

## License

Apache-2.0. See [LICENSE](LICENSE).
