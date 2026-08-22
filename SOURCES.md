# Sources And Originality

## Ecosystem Check

Before implementation, mooncakes.io and web search were checked with keywords
including `NEWS2`, `qSOFA`, `Glasgow Coma Scale`, and `triage MoonBit`. No mature
MoonBit package with the same emergency-score scope was found.

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

## Authorship

The repository is developed as a single-author competition project. There are no
fictional contributors, generated co-authors, or copied source files from another
MoonBit package.

## Safety Boundary

This project computes scoring rules for software validation, education, and
audit workflows. It is not a medical device and does not provide diagnosis,
treatment advice, or patient disposition.
