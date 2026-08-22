///|
pub(all) struct CharlsonInput {
  age : Int
  myocardial_infarction : Bool
  congestive_heart_failure : Bool
  peripheral_vascular_disease : Bool
  cerebrovascular_disease : Bool
  dementia : Bool
  chronic_pulmonary_disease : Bool
  connective_tissue_disease : Bool
  peptic_ulcer_disease : Bool
  mild_liver_disease : Bool
  diabetes_without_complication : Bool
  diabetes_with_end_organ_damage : Bool
  hemiplegia : Bool
  moderate_or_severe_renal_disease : Bool
  any_tumor : Bool
  leukemia : Bool
  lymphoma : Bool
  moderate_or_severe_liver_disease : Bool
  metastatic_solid_tumor : Bool
  aids : Bool
} derive(Debug, Eq)

///|
pub fn validate_charlson(input : CharlsonInput) -> ValidationError? {
  validate_range("age", input.age, 0, 150)
}

///|
pub fn charlson_age_points(age : Int) -> Int {
  if age < 50 {
    0
  } else if age < 60 {
    1
  } else if age < 70 {
    2
  } else if age < 80 {
    3
  } else {
    4
  }
}

///|
pub fn charlson_bool_points(value : Bool, points : Int) -> Int {
  if value {
    points
  } else {
    0
  }
}

///|
pub fn charlson_vascular_points(input : CharlsonInput) -> Int {
  charlson_bool_points(input.myocardial_infarction, 1) +
  charlson_bool_points(input.congestive_heart_failure, 1) +
  charlson_bool_points(input.peripheral_vascular_disease, 1) +
  charlson_bool_points(input.cerebrovascular_disease, 1)
}

///|
pub fn charlson_common_points(input : CharlsonInput) -> Int {
  charlson_bool_points(input.dementia, 1) +
  charlson_bool_points(input.chronic_pulmonary_disease, 1) +
  charlson_bool_points(input.connective_tissue_disease, 1) +
  charlson_bool_points(input.peptic_ulcer_disease, 1) +
  charlson_bool_points(input.mild_liver_disease, 1) +
  charlson_bool_points(input.diabetes_without_complication, 1)
}

///|
pub fn charlson_systemic_points(input : CharlsonInput) -> Int {
  let diabetes = if input.diabetes_with_end_organ_damage { 2 } else { 0 }
  let hemiplegia = charlson_bool_points(input.hemiplegia, 2)
  let renal = charlson_bool_points(input.moderate_or_severe_renal_disease, 2)
  let tumor = charlson_bool_points(input.any_tumor, 2)
  let leukemia = charlson_bool_points(input.leukemia, 2)
  let lymphoma = charlson_bool_points(input.lymphoma, 2)
  diabetes + hemiplegia + renal + tumor + leukemia + lymphoma
}

///|
pub fn charlson_severe_points(input : CharlsonInput) -> Int {
  let liver = charlson_bool_points(input.moderate_or_severe_liver_disease, 3)
  let metastatic = charlson_bool_points(input.metastatic_solid_tumor, 6)
  let aids = charlson_bool_points(input.aids, 6)
  liver + metastatic + aids
}

///|
pub fn charlson_score(input : CharlsonInput) -> Int {
  charlson_age_points(input.age) +
  charlson_vascular_points(input) +
  charlson_common_points(input) +
  charlson_systemic_points(input) +
  charlson_severe_points(input)
}

///|
pub fn charlson_severity(score : Int) -> Severity {
  if score >= 6 {
    Critical
  } else if score >= 4 {
    High
  } else if score >= 2 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_charlson(input : CharlsonInput) -> ScoreReport {
  let age = charlson_age_points(input.age)
  let vascular = charlson_vascular_points(input)
  let common = charlson_common_points(input)
  let systemic = charlson_systemic_points(input)
  let severe = charlson_severe_points(input)
  let score = age + vascular + common + systemic + severe
  report(
    "Charlson Comorbidity Index",
    score,
    charlson_severity(score),
    "The Charlson index summarizes comorbidity burden for cohort adjustment and risk stratification; coding conventions must match the target population.",
    [
      explanation("Age", age, "Age-adjusted contribution"),
      explanation("Vascular", vascular, "Vascular and cerebrovascular disease"),
      explanation(
        "Common conditions", common, "Dementia, pulmonary, connective tissue, ulcer, liver, and diabetes domains",
      ),
      explanation(
        "Systemic disease", systemic, "Diabetes complication, hemiplegia, renal, and hematologic domains",
      ),
      explanation(
        "Severe disease", severe, "Severe liver, metastatic tumor, and AIDS domains",
      ),
    ],
  )
}

///|
pub(all) struct MeldNaInput {
  bilirubin_tenths_mg_dl : Int
  inr_hundredths : Int
  creatinine_tenths_mg_dl : Int
  sodium : Int
  dialysis_twice_last_week : Bool
} derive(Debug, Eq)

///|
pub fn validate_meld_na(input : MeldNaInput) -> ValidationError? {
  match
    validate_range(
      "bilirubin_tenths_mg_dl",
      input.bilirubin_tenths_mg_dl,
      1,
      500,
    ) {
    Some(err) => Some(err)
    None =>
      match validate_range("inr_hundredths", input.inr_hundredths, 100, 1000) {
        Some(err) => Some(err)
        None =>
          match
            validate_range(
              "creatinine_tenths_mg_dl",
              input.creatinine_tenths_mg_dl,
              1,
              100,
            ) {
            Some(err) => Some(err)
            None => validate_range("sodium", input.sodium, 100, 160)
          }
      }
  }
}

///|
pub fn meld_component_points(
  value : Int,
  low : Int,
  middle : Int,
  high : Int,
) -> Int {
  if value <= low {
    0
  } else if value <= middle {
    1
  } else if value <= high {
    2
  } else {
    3
  }
}

///|
pub fn meld_na_score(input : MeldNaInput) -> Int {
  let bilirubin = meld_component_points(
    input.bilirubin_tenths_mg_dl,
    10,
    40,
    100,
  )
  let inr = meld_component_points(input.inr_hundredths, 100, 170, 250)
  let creatinine = meld_component_points(
    input.creatinine_tenths_mg_dl,
    10,
    20,
    40,
  )
  let sodium = if input.sodium < 125 {
    3
  } else if input.sodium < 130 {
    2
  } else if input.sodium < 135 {
    1
  } else {
    0
  }
  let dialysis = if input.dialysis_twice_last_week { 4 } else { 0 }
  bilirubin * 3 + inr * 4 + creatinine * 3 + sodium + dialysis
}

///|
pub fn meld_na_severity(score : Int) -> Severity {
  if score >= 25 {
    Critical
  } else if score >= 15 {
    High
  } else if score >= 8 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_meld_na(input : MeldNaInput) -> ScoreReport {
  let score = meld_na_score(input)
  report(
    "MELD-Na",
    score,
    meld_na_severity(score),
    "MELD-Na is a laboratory-based liver disease severity aid; local allocation policy and current formulas must be checked.",
    [
      explanation(
        "Bilirubin",
        meld_component_points(input.bilirubin_tenths_mg_dl, 10, 40, 100) * 3,
        "Bilirubin component",
      ),
      explanation(
        "INR",
        meld_component_points(input.inr_hundredths, 100, 170, 250) * 4,
        "INR component",
      ),
      explanation(
        "Creatinine",
        meld_component_points(input.creatinine_tenths_mg_dl, 10, 20, 40) * 3,
        "Creatinine component",
      ),
      explanation(
        "Sodium",
        if input.sodium < 125 {
          3
        } else if input.sodium < 130 {
          2
        } else if input.sodium < 135 {
          1
        } else {
          0
        },
        "Sodium component",
      ),
      explanation(
        "Dialysis",
        if input.dialysis_twice_last_week {
          4
        } else {
          0
        },
        "Recent dialysis flag",
      ),
    ],
  )
}
