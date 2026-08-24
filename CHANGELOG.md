# Changelog

## 0.4.1

- Updated release validation to the stable MoonBit toolchain `0.1.20260824`
  with `moonc v0.10.10`.
- Preserved the deterministic benchmark checksum and refreshed public source
  and ecosystem documentation for package consumers.

## 0.4.0

- Added validated renal/hepatic, neurologic, trauma, emergency, perioperative,
  pediatric, obstetric, and acute-abdominal scoring modules.
- Added observation timelines, trend extraction, assessment ledgers, pathway
  escalation, audit events, report formatting, and instrument registry diffs.
- Expanded boundary and integration coverage to 50 tests with a native coverage
  run of 2,349/3,354 instrumented lines (70.0%).
- Added provenance entries for the new public scoring families and their
  implementation scope.
- Updated GitHub Actions checkout steps to the current Node 24-compatible
  checkout action major version.

## 0.1.0

- Added NEWS2 scoring with component explanations.
- Added qSOFA scoring and validation.
- Added Glasgow Coma Scale scoring.
- Added combined triage bundle API.
- Added runnable CLI example.
- Added black-box tests, boundary tests, README examples, CI, and generated API
  summaries.

## 0.3.0

- Added SIRS, MEWS, SOFA, PEWS, CURB-65, Shock Index, and ROX Index APIs.
- Added deterministic batch summaries and measurement-quality flags.
- Added a 10,000-iteration executable benchmark and native/all-target CI.
- Added a manual/tagged Mooncakes publication workflow.
- Added Wells PE, HEART, and CHA2DS2-VASc weighted-rule APIs.
- Added a dedicated provenance document with primary reference links and
  explicit implementation scope.
