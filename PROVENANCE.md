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
| PESI | [NICE venous thromboembolic disease guidance](https://www.nice.org.uk/guidance/ng158) | Age, comorbidity, physiology, mentation, and oxygenation points |
| BODE | [BODE index PubMed search](https://pubmed.ncbi.nlm.nih.gov/?term=BODE+index+COPD) | BMI, airflow obstruction, dyspnea, and exercise-capacity bands |
| qCSI | [qCSI PubMed search](https://pubmed.ncbi.nlm.nih.gov/?term=quick+COVID-19+severity+index) | Respiratory rate, oxygen saturation, and oxygen-flow bands |
| Hestia | [NICE venous thromboembolic disease guidance](https://www.nice.org.uk/guidance/ng158) | Outpatient pulmonary-embolism exclusion flags |
| RTS / ISS | [Injury Severity Score PubMed](https://pubmed.ncbi.nlm.nih.gov/4854191/) | Revised Trauma Score components and top-three AIS region squares |
| NIHSS | [NINDS NIH Stroke Scale booklet](https://www.ninds.nih.gov/sites/default/files/migrate-documents/nih_stroke_scale_booklet_508c.pdf) | Fifteen item fields with range validation and component explanations |
| FOUR | [FOUR score original paper](https://pubmed.ncbi.nlm.nih.gov/16395292/) | Eye, motor, brainstem, and respiration domains |
| ABCD2 | [ABCD2 PubMed search](https://pubmed.ncbi.nlm.nih.gov/?term=ABCD2+TIA+score) | Age, pressure, clinical features, duration, and diabetes |
| Canadian CT Head / C-spine | [Canadian CT Head Rule PubMed](https://pubmed.ncbi.nlm.nih.gov/11597285/) | Explicit high- and medium-risk criteria |
| NEXUS C-spine | [NEXUS cervical-spine validation PubMed](https://pubmed.ncbi.nlm.nih.gov/10891516/) | Five clinical clearance criteria |
| PECARN Head Injury | [PECARN pediatric head trauma PubMed](https://pubmed.ncbi.nlm.nih.gov/19758692/) | High- and intermediate-risk feature counts |
| APACHE II | [APACHE II original paper PubMed](https://pubmed.ncbi.nlm.nih.gov/7063222/) | Acute physiology, age, GCS, and chronic-health points |
| SMART-COP | [SMART-COP PubMed](https://pubmed.ncbi.nlm.nih.gov/19416302/) | Pneumonia support-risk domains |
| Child-Pugh | [Pugh classification PubMed](https://pubmed.ncbi.nlm.nih.gov/3610046/) | Bilirubin, albumin, INR, ascites, and encephalopathy bands |
| Glasgow-Blatchford | [Original Glasgow-Blatchford score](https://pubmed.ncbi.nlm.nih.gov/11073021/) | Upper gastrointestinal bleeding intervention-risk variables |
| Caprini / Padua | [Padua prediction score](https://pubmed.ncbi.nlm.nih.gov/20738765/), [Caprini validation](https://pubmed.ncbi.nlm.nih.gov/30939898/) | VTE risk-factor aggregation with explicit weighting |
| STOP-Bang / ARISCAT | [STOP-Bang PubMed](https://pubmed.ncbi.nlm.nih.gov/21168755/), [ARISCAT PubMed](https://pubmed.ncbi.nlm.nih.gov/21704142/) | Sleep-apnea screening and postoperative pulmonary-risk bands |
| BISAP / Ranson / Alvarado | [BISAP PubMed](https://pubmed.ncbi.nlm.nih.gov/17964470/), [Alvarado PubMed](https://pubmed.ncbi.nlm.nih.gov/7042080/) | Acute pancreatitis and appendicitis rule components |
| Bishop | [Bishop score PubMed search](https://pubmed.ncbi.nlm.nih.gov/?term=Bishop+score+cervical+scoring) | Cervical dilation, effacement, station, consistency, and position |

## Explicit non-claims

- Scores are not diagnoses, treatment recommendations, or disposition rules.
- Threshold variations between institutions are expected; this package exposes
  the chosen rule version rather than claiming universal clinical authority.
- No score is calibrated to a local patient cohort by this repository.
- Numeric ratios use integer scaling to make cross-target behavior deterministic.
- Some implementations intentionally expose a compact, integer-scaled rule
  representation. They are software-validation aids, not claims that every
  institution uses identical cutoffs or a complete bedside instrument.

## License and attribution

The MoonBit implementation is licensed under Apache-2.0. The references above
are linked for provenance and are not bundled as copied code or redistributable
clinical chart artwork.
