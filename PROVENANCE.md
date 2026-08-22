# Rule provenance and implementation scope

This project implements threshold calculations from publicly described scoring
systems. It does not copy source code, patient data, or proprietary tables.
The links below are the references used when reviewing the rule definitions;
the implementation remains a software-validation aid and must be checked
against the local protocol and population before clinical use.

| Instrument | Primary reference | Scope in this repository |
| --- | --- | --- |
| NEWS2 | [Royal College of Physicians NEWS2](https://www.rcp.ac.uk/resources/national-early-warning-score-news-2/) | NEWS2 vital-sign bands, oxygen scale 1/2, oxygen add-on, ACVPU flag |
| qSOFA | [Sepsis-3 consensus, JAMA](https://jamanetwork.com/journals/jama/fullarticle/2492881) | Respiratory rate, systolic pressure, and GCS criteria |
| SIRS | [Sepsis-3 assessment, JAMA](https://jamanetwork.com/journals/jama/fullarticle/2492875) | Temperature, pulse, respiration, white-cell/immature-neutrophil criteria |
| SOFA | [Vincent et al. SOFA paper](https://doi.org/10.1007/BF01709751) | Six organ domains represented with integer units |
| GCS | [Glasgow Coma Scale overview](https://www.glasgowcomascale.org/) | Eye, verbal, and motor components |
| CURB-65 | [NICE pneumonia guidance](https://www.nice.org.uk/guidance/cg191) | Confusion, urea, respiration, pressure, and age criteria |
| Shock Index | [Shock index PubMed record](https://pubmed.ncbi.nlm.nih.gov/8922013/) | Heart rate / systolic pressure, scaled by 100 |
| ROX Index | [ROX Index PubMed record](https://pubmed.ncbi.nlm.nih.gov/33039213/) | SpO2 / FiO2 / respiratory rate, scaled by 100 |
| Wells PE | [NICE venous thromboembolic disease guidance](https://www.nice.org.uk/guidance/ng158) | Weighted pre-test probability criteria, scaled by 10 |
| HEART | [HEART score review, PubMed](https://pubmed.ncbi.nlm.nih.gov/24240112/) | Five 0–2 component inputs |
| CHA2DS2-VASc | [European Society of Cardiology AF guideline](https://academic.oup.com/eurheartj/article/42/5/373/5899003) | Risk-factor point aggregation |

## Explicit non-claims

- Scores are not diagnoses, treatment recommendations, or disposition rules.
- Threshold variations between institutions are expected; this package exposes
  the chosen rule version rather than claiming universal clinical authority.
- No score is calibrated to a local patient cohort by this repository.
- Numeric ratios use integer scaling to make cross-target behavior deterministic.

## License and attribution

The MoonBit implementation is licensed under Apache-2.0. The references above
are linked for provenance and are not bundled as copied code or redistributable
clinical chart artwork.
