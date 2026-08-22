///|
pub(all) struct RcriInput {
  high_risk_surgery : Bool
  ischemic_heart_disease : Bool
  heart_failure : Bool
  cerebrovascular_disease : Bool
  diabetes_on_insulin : Bool
  creatinine_above_2 : Bool
} derive(Debug, Eq)

///|
pub fn rcri_flag_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn rcri_severity(score : Int) -> Severity {
  if score >= 3 {
    High
  } else if score >= 1 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_rcri(input : RcriInput) -> ScoreReport {
  let surgery = rcri_flag_points(input.high_risk_surgery)
  let ischemia = rcri_flag_points(input.ischemic_heart_disease)
  let failure = rcri_flag_points(input.heart_failure)
  let stroke = rcri_flag_points(input.cerebrovascular_disease)
  let diabetes = rcri_flag_points(input.diabetes_on_insulin)
  let creatinine = rcri_flag_points(input.creatinine_above_2)
  let score = surgery + ischemia + failure + stroke + diabetes + creatinine
  report(
    "RCRI",
    score,
    rcri_severity(score),
    "RCRI is a perioperative cardiac-risk aid and does not replace anaesthetic assessment.",
    [
      explanation(
        "High-risk surgery", surgery, "High-risk intraperitoneal, intrathoracic, or suprainguinal vascular procedure",
      ),
      explanation(
        "Ischemic heart disease", ischemia, "History of ischemic heart disease",
      ),
      explanation(
        "Heart failure", failure, "History of congestive heart failure",
      ),
      explanation(
        "Cerebrovascular disease", stroke, "History of stroke or transient ischemic attack",
      ),
      explanation("Insulin therapy", diabetes, "Diabetes treated with insulin"),
      explanation(
        "Creatinine", creatinine, "Preoperative creatinine above 2 mg/dL",
      ),
    ],
  )
}

///|
pub(all) struct TimiInput {
  age_65_or_more : Bool
  risk_factors : Int
  known_coronary_stenosis : Bool
  aspirin_last_7_days : Bool
  severe_angina : Bool
  st_deviation : Bool
  positive_biomarker : Bool
} derive(Debug, Eq)

///|
pub fn validate_timi(input : TimiInput) -> ValidationError? {
  validate_range("risk_factors", input.risk_factors, 0, 20)
}

///|
pub fn timi_risk_factor_points(value : Int) -> Int {
  if value >= 3 {
    1
  } else {
    0
  }
}

///|
pub fn timi_severity(score : Int) -> Severity {
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
pub fn score_timi(input : TimiInput) -> ScoreReport {
  let age = rcri_flag_points(input.age_65_or_more)
  let risks = timi_risk_factor_points(input.risk_factors)
  let stenosis = rcri_flag_points(input.known_coronary_stenosis)
  let aspirin = rcri_flag_points(input.aspirin_last_7_days)
  let angina = rcri_flag_points(input.severe_angina)
  let st = rcri_flag_points(input.st_deviation)
  let biomarker = rcri_flag_points(input.positive_biomarker)
  let score = age + risks + stenosis + aspirin + angina + st + biomarker
  report(
    "TIMI",
    score,
    timi_severity(score),
    "TIMI is an acute coronary syndrome risk score; it is not a diagnosis or treatment order.",
    [
      explanation("Age", age, "Age 65 years or older"),
      explanation("Risk factors", risks, "At least three coronary risk factors"),
      explanation(
        "Known stenosis", stenosis, "Known coronary stenosis of at least 50 percent",
      ),
      explanation("Aspirin", aspirin, "Aspirin use in the preceding seven days"),
      explanation(
        "Severe angina", angina, "Two or more anginal episodes in the prior 24 hours",
      ),
      explanation("ST deviation", st, "ST deviation on presenting ECG"),
      explanation("Biomarker", biomarker, "Elevated cardiac biomarker"),
    ],
  )
}

///|
pub(all) struct HasBledInput {
  hypertension : Bool
  abnormal_renal : Bool
  abnormal_liver : Bool
  stroke : Bool
  bleeding_history : Bool
  labile_inr : Bool
  age_over_65 : Bool
  drugs_or_alcohol : Bool
} derive(Debug, Eq)

///|
pub fn has_bled_severity(score : Int) -> Severity {
  if score >= 3 {
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
pub fn score_has_bled(input : HasBledInput) -> ScoreReport {
  let hypertension = rcri_flag_points(input.hypertension)
  let renal = rcri_flag_points(input.abnormal_renal)
  let liver = rcri_flag_points(input.abnormal_liver)
  let stroke = rcri_flag_points(input.stroke)
  let bleeding = rcri_flag_points(input.bleeding_history)
  let inr = rcri_flag_points(input.labile_inr)
  let age = rcri_flag_points(input.age_over_65)
  let drugs = rcri_flag_points(input.drugs_or_alcohol)
  let score = hypertension +
    renal +
    liver +
    stroke +
    bleeding +
    inr +
    age +
    drugs
  report(
    "HAS-BLED",
    score,
    has_bled_severity(score),
    "HAS-BLED identifies modifiable bleeding-risk factors; it is not a reason to withhold treatment by itself.",
    [
      explanation(
        "Hypertension", hypertension, "Uncontrolled systolic hypertension",
      ),
      explanation("Renal disease", renal, "Abnormal renal function"),
      explanation("Liver disease", liver, "Abnormal liver function"),
      explanation("Stroke", stroke, "Previous stroke"),
      explanation(
        "Bleeding", bleeding, "Previous major bleeding or bleeding predisposition",
      ),
      explanation("Labile INR", inr, "Labile or unstable anticoagulation"),
      explanation("Age", age, "Age over 65 years"),
      explanation(
        "Drugs or alcohol", drugs, "Drugs predisposing to bleeding or alcohol use",
      ),
    ],
  )
}

///|
pub(all) struct WellsDvtInput {
  active_cancer : Bool
  paralysis_or_immobilization : Bool
  bedridden_or_surgery : Bool
  tenderness_deep_veins : Bool
  entire_leg_swollen : Bool
  calf_swelling : Bool
  previous_dvt : Bool
  alternative_diagnosis : Bool
} derive(Debug, Eq)

///|
pub fn wells_dvt_severity(score : Int) -> Severity {
  if score >= 5 {
    High
  } else if score >= 2 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_wells_dvt(input : WellsDvtInput) -> ScoreReport {
  let cancer = rcri_flag_points(input.active_cancer)
  let paralysis = rcri_flag_points(input.paralysis_or_immobilization)
  let bedridden = rcri_flag_points(input.bedridden_or_surgery)
  let tenderness = rcri_flag_points(input.tenderness_deep_veins)
  let entire_leg = if input.entire_leg_swollen { 2 } else { 0 }
  let calf = rcri_flag_points(input.calf_swelling)
  let previous = rcri_flag_points(input.previous_dvt)
  let alternative = if input.alternative_diagnosis { -2 } else { 0 }
  let score = cancer +
    paralysis +
    bedridden +
    tenderness +
    entire_leg +
    calf +
    previous +
    alternative
  report(
    "Wells DVT",
    score,
    wells_dvt_severity(score),
    "Wells DVT is a pre-test probability aid and must be paired with the local diagnostic pathway.",
    [
      explanation(
        "Active cancer", cancer, "Active cancer or treatment within six months",
      ),
      explanation(
        "Paralysis or immobilization", paralysis, "Paralysis, paresis, or recent plaster immobilization",
      ),
      explanation(
        "Bedridden or surgery", bedridden, "Recently bedridden or major surgery",
      ),
      explanation(
        "Deep-vein tenderness", tenderness, "Tenderness along the deep venous system",
      ),
      explanation("Entire leg swollen", entire_leg, "Entire leg swelling"),
      explanation(
        "Calf swelling", calf, "Calf swelling compared with the asymptomatic leg",
      ),
      explanation("Previous DVT", previous, "Previous documented DVT"),
      explanation(
        "Alternative diagnosis", alternative, "Alternative diagnosis at least as likely as DVT",
      ),
    ],
  )
}
