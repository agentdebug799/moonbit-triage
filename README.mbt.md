# moonbit-triage

Explainable emergency triage scoring primitives for MoonBit.

`moonbit-triage` implements small, auditable scoring functions for emergency
triage and risk-score software. It currently covers NEWS2, qSOFA, and Glasgow
Coma Scale. The package computes public scoring rules, returns component-level
explanations, and validates common input ranges. It does not diagnose disease,
recommend treatment, or decide patient disposition.

## Scope

- NEWS2 total score with SpO2 scale 1/2, oxygen add-on, vital-sign bands, and
  ACVPU consciousness scoring.
- qSOFA score from respiratory rate, systolic blood pressure, and GCS total.
- Glasgow Coma Scale component total with eye, verbal, and motor explanations.
- A combined triage bundle that preserves the individual score reports.
- First-error validation helpers for measured ranges.

## Install And Run

```bash
moon check
moon test
moon run cmd/main
```

The sample command prints a small combined assessment:

```text
moonbit-triage sample
NEWS2: 8
qSOFA: 1
GCS: 15
Summary: At least one score is in its highest concern band. Use local escalation policy and clinical judgment.
```

## Minimal Example

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

## API Shape

The public API intentionally uses plain records and enums so that callers can
wire the library into CLI tools, web forms, or data-validation pipelines without
extra dependencies. Each `ScoreReport` includes:

- `instrument`: scoring instrument name.
- `score`: numeric total.
- `severity`: local library band for software routing.
- `interpretation`: short explanation of the band.
- `explanations`: component-level point contributions.
- `disclaimer`: safety boundary text.

## Sources And Safety

The implementation follows publicly described scoring thresholds for NEWS2,
qSOFA, and GCS. The qSOFA criteria are also summarized by the public qSOFA
project: respiratory rate at least 22/min, systolic blood pressure at most
100 mmHg, and GCS below 15. Clinical scoring rules can be embedded in local
protocols differently, so downstream projects should review the thresholds
against their intended policy before use.

This project is for education, audit, and software validation. It is not a
medical device and must not replace clinician judgment.

## Development Notes

- MoonBit module: `agentdebug799/moonbit-triage`.
- License: Apache-2.0.
- Preferred target: `wasm-gc`.
- Validation used for release: `moon fmt --check`, `moon check --deny-warn`,
  `moon info`, and `moon test --deny-warn`.
