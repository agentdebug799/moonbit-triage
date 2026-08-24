# Sources And Originality

## Ecosystem context

The package provides a dependency-free MoonBit implementation for explainable
triage scoring, longitudinal observations, audit trails, and data-quality
pipelines. Its public records, validation errors, explanations, and registry
metadata are designed for reuse by CLI tools, forms, services, and other
MoonBit packages.

## Scoring Sources

Detailed links, scope, and non-claims are maintained in
[PROVENANCE.md](PROVENANCE.md).

- NEWS2: public NEWS2 scoring tables as commonly published by clinical early
  warning score materials.
- qSOFA: public qSOFA description: respiratory rate >= 22/min, systolic blood
  pressure <= 100 mmHg, and altered mentation represented by GCS < 15.
- Glasgow Coma Scale: public eye, verbal, and motor component score ranges.
- SIRS: consensus threshold definition using temperature, pulse, respiratory
  rate, white-cell count, and immature neutrophils.
- MEWS: public early-warning band definitions for pressure, pulse, breathing,
  temperature, and AVPU state.
- SOFA: public six-domain organ-dysfunction bands, including PaO2/FiO2,
  platelets, bilirubin, circulation, GCS, and renal measurements.
- PEWS: a conservative, explicitly local-policy-dependent pediatric early
  warning representation; the implementation documents its chosen domains and
  does not claim universal age-specific thresholds.
- CURB-65, Shock Index, and ROX Index: public rule definitions represented as
  integer arithmetic where ratios are scaled by 100.

No third-party source code is copied into this repository. The implementation
is an original MoonBit expression of published scoring concepts; downstream
users must verify thresholds against the protocol and population they intend
to support.

## Originality and attribution

The implementation is an original MoonBit expression of publicly described
scoring concepts. No third-party source code, patient data, proprietary tables,
fictional contributors, or generated co-authors are included in this repository.

## Safety Boundary

This project computes scoring rules for software validation, education, and
audit workflows. It is not a medical device and does not provide diagnosis,
treatment advice, or patient disposition.
