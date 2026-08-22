///|
pub(all) struct WellsPeInput {
  clinical_dvt_signs : Bool
  pe_most_likely : Bool
  heart_rate : Int
  surgery_or_immobilization : Bool
  previous_dvt_or_pe : Bool
  hemoptysis : Bool
  malignancy : Bool
} derive(Debug, Eq)

///|
pub fn validate_wells_pe(input : WellsPeInput) -> ValidationError? {
  validate_range("heart_rate", input.heart_rate, 0, 300)
}

///|
pub fn wells_pe_dvt_points(value : Bool) -> Int {
  if value {
    30
  } else {
    0
  }
}

///|
pub fn wells_pe_likely_points(value : Bool) -> Int {
  if value {
    30
  } else {
    0
  }
}

///|
pub fn wells_pe_rate_points(value : Int) -> Int {
  if value > 100 {
    10
  } else {
    0
  }
}

///|
pub fn wells_pe_immobilization_points(value : Bool) -> Int {
  if value {
    10
  } else {
    0
  }
}

///|
pub fn wells_pe_previous_event_points(value : Bool) -> Int {
  if value {
    15
  } else {
    0
  }
}

///|
pub fn wells_pe_hemoptysis_points(value : Bool) -> Int {
  if value {
    10
  } else {
    0
  }
}

///|
pub fn wells_pe_malignancy_points(value : Bool) -> Int {
  if value {
    10
  } else {
    0
  }
}

///|
pub fn wells_pe_severity(score : Int) -> Severity {
  if score >= 65 {
    Critical
  } else if score >= 40 {
    High
  } else if score > 0 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_wells_pe(input : WellsPeInput) -> ScoreReport {
  let dvt = wells_pe_dvt_points(input.clinical_dvt_signs)
  let likely = wells_pe_likely_points(input.pe_most_likely)
  let rate = wells_pe_rate_points(input.heart_rate)
  let immobilization = wells_pe_immobilization_points(
    input.surgery_or_immobilization,
  )
  let previous = wells_pe_previous_event_points(input.previous_dvt_or_pe)
  let hemoptysis = wells_pe_hemoptysis_points(input.hemoptysis)
  let malignancy = wells_pe_malignancy_points(input.malignancy)
  let score = dvt +
    likely +
    rate +
    immobilization +
    previous +
    hemoptysis +
    malignancy
  report(
    "Wells PE x10",
    score,
    wells_pe_severity(score),
    "Wells PE is a pre-test probability aid; it does not determine imaging or treatment.",
    [
      explanation(
        "Clinical DVT signs", dvt, "Clinical signs of deep-vein thrombosis",
      ),
      explanation(
        "PE most likely", likely, "Pulmonary embolism judged most likely diagnosis",
      ),
      explanation("Heart rate", rate, "Heart rate above 100/min"),
      explanation(
        "Surgery or immobilization", immobilization, "Recent surgery or immobilization",
      ),
      explanation("Previous DVT/PE", previous, "Previous thromboembolic event"),
      explanation("Hemoptysis", hemoptysis, "Hemoptysis criterion"),
      explanation("Malignancy", malignancy, "Active malignancy criterion"),
    ],
  )
}

///|
pub(all) struct HeartInput {
  history : Int
  ecg : Int
  age : Int
  risk_factors : Int
  troponin : Int
} derive(Debug, Eq)

///|
pub fn validate_heart(input : HeartInput) -> ValidationError? {
  match validate_range("history", input.history, 0, 2) {
    Some(err) => Some(err)
    None =>
      match validate_range("ecg", input.ecg, 0, 2) {
        Some(err) => Some(err)
        None =>
          match validate_range("age", input.age, 0, 2) {
            Some(err) => Some(err)
            None =>
              match validate_range("risk_factors", input.risk_factors, 0, 2) {
                Some(err) => Some(err)
                None => validate_range("troponin", input.troponin, 0, 2)
              }
          }
      }
  }
}

///|
pub fn heart_severity(score : Int) -> Severity {
  if score >= 7 {
    Critical
  } else if score >= 4 {
    High
  } else if score >= 1 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_heart(input : HeartInput) -> ScoreReport {
  let score = input.history +
    input.ecg +
    input.age +
    input.risk_factors +
    input.troponin
  report(
    "HEART",
    score,
    heart_severity(score),
    "HEART is a chest-pain risk-stratification aid and requires local clinical context.",
    [
      explanation("History", input.history, "History component from 0 to 2"),
      explanation("ECG", input.ecg, "Electrocardiogram component from 0 to 2"),
      explanation("Age", input.age, "Age component from 0 to 2"),
      explanation(
        "Risk factors",
        input.risk_factors,
        "Risk-factor component from 0 to 2",
      ),
      explanation("Troponin", input.troponin, "Troponin component from 0 to 2"),
    ],
  )
}

///|
pub(all) struct Cha2ds2VascInput {
  congestive_failure : Bool
  hypertension : Bool
  age : Int
  diabetes : Bool
  stroke_or_tia : Bool
  vascular_disease : Bool
  sex_female : Bool
} derive(Debug, Eq)

///|
pub fn validate_cha2ds2_vasc(input : Cha2ds2VascInput) -> ValidationError? {
  validate_range("age", input.age, 0, 2)
}

///|
pub fn cha2ds2_vasc_age_points(value : Int) -> Int {
  if value == 2 {
    2
  } else if value == 1 {
    1
  } else {
    0
  }
}

///|
pub fn cha2ds2_vasc_flag_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn cha2ds2_vasc_stroke_points(value : Bool) -> Int {
  if value {
    2
  } else {
    0
  }
}

///|
pub fn cha2ds2_vasc_severity(score : Int) -> Severity {
  if score >= 6 {
    Critical
  } else if score >= 2 {
    High
  } else if score == 1 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_cha2ds2_vasc(input : Cha2ds2VascInput) -> ScoreReport {
  let failure = cha2ds2_vasc_flag_points(input.congestive_failure)
  let hypertension = cha2ds2_vasc_flag_points(input.hypertension)
  let age = cha2ds2_vasc_age_points(input.age)
  let diabetes = cha2ds2_vasc_flag_points(input.diabetes)
  let stroke = cha2ds2_vasc_stroke_points(input.stroke_or_tia)
  let vascular = cha2ds2_vasc_flag_points(input.vascular_disease)
  let sex = cha2ds2_vasc_flag_points(input.sex_female)
  let score = failure + hypertension + age + diabetes + stroke + vascular + sex
  report(
    "CHA2DS2-VASc",
    score,
    cha2ds2_vasc_severity(score),
    "CHA2DS2-VASc summarizes thromboembolic risk factors; treatment decisions require clinical review.",
    [
      explanation(
        "Congestive heart failure", failure, "Heart-failure criterion",
      ),
      explanation("Hypertension", hypertension, "Hypertension criterion"),
      explanation("Age", age, "Age category"),
      explanation("Diabetes", diabetes, "Diabetes criterion"),
      explanation(
        "Stroke or TIA", stroke, "Prior stroke, TIA, or systemic embolism",
      ),
      explanation("Vascular disease", vascular, "Vascular-disease criterion"),
      explanation("Sex category", sex, "Female sex category"),
    ],
  )
}
