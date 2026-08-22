# moonbit-triage Acceptance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the existing MoonBit scoring library into a maintainable, testable, publishable August Hackathon project with real clinical-rule coverage, reproducible benchmarks, CI, and release metadata.

**Architecture:** Keep the root package as the public facade and split new behavior into focused files: additional scoring instruments, validation/quality utilities, batch aggregation, and deterministic benchmark helpers. Public records and enums remain in the root package; tests exercise every threshold and invalid-input boundary. Documentation describes only implemented behavior and cites sources separately.

**Tech Stack:** MoonBit stable toolchain, `wasm-gc` and native test targets, GitHub Actions, Mooncakes module publishing, Apache-2.0.

---

### Task 1: Establish a failing acceptance baseline

**Files:**
- Create: `docs/superpowers/plans/2026-08-22-moonbit-triage-acceptance.md`
- Test: `moonbit-triage_test.mbt`

- [ ] Record current `moon check`, `moon test`, `moon fmt --check`, `moon info`, and production/test LOC.
- [ ] Add failing public API tests for SIRS, MEWS, SOFA, PEWS, and deterministic batch summaries before implementation.
- [ ] Run the targeted tests and verify they fail because the requested APIs do not exist.

### Task 2: Implement additional scoring instruments

**Files:**
- Create: `sirs.mbt`
- Create: `mews.mbt`
- Create: `sofa.mbt`
- Create: `pews.mbt`
- Modify: `moonbit-triage_test.mbt`
- Modify: `moonbit-triage_wbtest.mbt`

- [ ] Implement typed inputs, range validation, component functions, score reports, and boundary behavior for each instrument.
- [ ] Keep clinical interpretation conservative and avoid diagnostic or treatment claims.
- [ ] Add threshold-pair, minimum/maximum, invalid-input, and combined-score tests.
- [ ] Run `moon check` and `moon test` after each instrument.

### Task 3: Add integration and data-quality utilities

**Files:**
- Create: `quality.mbt`
- Create: `batch.mbt`
- Create: `audit.mbt`
- Modify: `moonbit-triage_test.mbt`

- [ ] Add missingness/measurement-quality flags, stable validation summaries, batch scoring, severity histograms, and deterministic audit records.
- [ ] Test empty batches, repeated records, invalid records, ordering, and large synthetic batches.

### Task 4: Add reproducible benchmark and engineering documentation

**Files:**
- Create: `benchmarks/README.md`
- Create: `benchmarks/bench.mbt`
- Modify: `README.mbt.md`
- Modify: `SOURCES.md`
- Modify: `CHANGELOG.md`

- [ ] Make the benchmark executable with `moon run benchmarks/bench.mbt` or an equivalent checked-in MoonBit command package.
- [ ] Record measured commands, toolchain version, dataset generation method, and observed results; do not invent performance numbers.
- [ ] Restructure README into positioning, capabilities, quick start, CLI, architecture, benchmarks, tests/CI, license, and safety.

### Task 5: Harden CI and publication metadata

**Files:**
- Modify: `.github/workflows/test.yml`
- Modify: `.github/workflows/copilot-setup-steps.yml`
- Create: `.github/workflows/publish.yml`
- Modify: `moon.mod`

- [ ] Use the current stable MoonBit installer, check formatting, all-target type checking, API-info cleanliness, tests, native tests, and coverage summary.
- [ ] Add a manual/tagged Mooncakes publish workflow without storing credentials in the repository.
- [ ] Validate that the module namespace, repository, license, and README metadata are publishable.

### Task 6: Final verification and delivery

- [ ] Run `moon info && moon fmt`, inspect generated interface diffs, then run the complete check/test/build/run matrix.
- [ ] Count effective production MoonBit lines and report the exact command and result.
- [ ] Run the local `osc2026-guide` acceptance checklist against the August Hackathon requirements.
- [ ] Commit in meaningful milestones, push `main` to GitHub, verify GitHub Actions, and publish to Mooncakes if the authenticated CLI accepts the package.

