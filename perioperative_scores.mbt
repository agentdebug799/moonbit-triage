///|
pub(all) struct CapriniInput {
  age : Int
  bmi_over_25 : Bool
  swollen_legs : Bool
  varicose_veins : Bool
  pregnancy_or_postpartum : Bool
  oral_contraceptives_or_hormone : Bool
  sepsis : Bool
  serious_lung_disease : Bool
  abnormal_pulmonary_function : Bool
  acute_myocardial_infarction : Bool
  congestive_heart_failure : Bool
  inflammatory_bowel_disease : Bool
  medical_patient : Bool
  minor_surgery : Bool
  arthroscopic_surgery : Bool
  major_surgery : Bool
  laparoscopic_surgery_over_45_min : Bool
  malignancy : Bool
  bed_rest_over_72_hours : Bool
  prior_vte : Bool
  family_history_vte : Bool
  thrombophilia : Bool
  stroke : Bool
  elective_arthroplasty : Bool
  hip_pelvis_leg_fracture : Bool
  acute_spinal_cord_injury : Bool
} derive(Debug, Eq)

///|
pub fn validate_caprini(input : CapriniInput) -> ValidationError? {
  validate_range("age", input.age, 0, 150)
}

///|
pub fn caprini_age_points(age : Int) -> Int {
  if age < 41 {
    0
  } else if age <= 60 {
    1
  } else if age <= 74 {
    2
  } else {
    3
  }
}

///|
pub fn caprini_bool_points(value : Bool, points : Int) -> Int {
  if value {
    points
  } else {
    0
  }
}

///|
pub fn caprini_two_point_count(input : CapriniInput) -> Int {
  caprini_bool_points(input.arthroscopic_surgery, 2) +
  caprini_bool_points(input.major_surgery, 2) +
  caprini_bool_points(input.laparoscopic_surgery_over_45_min, 2) +
  caprini_bool_points(input.malignancy, 2) +
  caprini_bool_points(input.bed_rest_over_72_hours, 1)
}

///|
pub fn caprini_three_point_count(input : CapriniInput) -> Int {
  caprini_bool_points(input.prior_vte, 3) +
  caprini_bool_points(input.family_history_vte, 3) +
  caprini_bool_points(input.thrombophilia, 3)
}

///|
pub fn caprini_five_point_count(input : CapriniInput) -> Int {
  caprini_bool_points(input.stroke, 5) +
  caprini_bool_points(input.elective_arthroplasty, 5) +
  caprini_bool_points(input.hip_pelvis_leg_fracture, 5) +
  caprini_bool_points(input.acute_spinal_cord_injury, 5)
}

///|
pub fn caprini_score(input : CapriniInput) -> Int {
  let one = caprini_bool_points(input.bmi_over_25, 1) +
    caprini_bool_points(input.swollen_legs, 1) +
    caprini_bool_points(input.varicose_veins, 1) +
    caprini_bool_points(input.pregnancy_or_postpartum, 1) +
    caprini_bool_points(input.oral_contraceptives_or_hormone, 1) +
    caprini_bool_points(input.sepsis, 1) +
    caprini_bool_points(input.serious_lung_disease, 1) +
    caprini_bool_points(input.abnormal_pulmonary_function, 1) +
    caprini_bool_points(input.acute_myocardial_infarction, 1) +
    caprini_bool_points(input.congestive_heart_failure, 1) +
    caprini_bool_points(input.inflammatory_bowel_disease, 1) +
    caprini_bool_points(input.medical_patient, 1) +
    caprini_bool_points(input.minor_surgery, 1)
  caprini_age_points(input.age) +
  one +
  caprini_two_point_count(input) +
  caprini_three_point_count(input) +
  caprini_five_point_count(input)
}

///|
pub fn caprini_severity(score : Int) -> Severity {
  if score >= 5 {
    Critical
  } else if score >= 3 {
    High
  } else if score >= 1 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_caprini(input : CapriniInput) -> ScoreReport {
  let age = caprini_age_points(input.age)
  let score = caprini_score(input)
  report(
    "Caprini",
    score,
    caprini_severity(score),
    "Caprini aggregates surgical and patient-level venous thromboembolism risk factors for local prophylaxis workflows.",
    [
      explanation("Age", age, "Age contribution"),
      explanation(
        "One-point factors",
        score -
        age -
        caprini_two_point_count(input) -
        caprini_three_point_count(input) -
        caprini_five_point_count(input),
        "One-point factor total",
      ),
      explanation(
        "Two-point factors",
        caprini_two_point_count(input),
        "Two-point factor total",
      ),
      explanation(
        "Three-point factors",
        caprini_three_point_count(input),
        "Three-point factor total",
      ),
      explanation(
        "Five-point factors",
        caprini_five_point_count(input),
        "Five-point factor total",
      ),
    ],
  )
}

///|
pub(all) struct PaduaInput {
  active_cancer : Bool
  previous_vte : Bool
  reduced_mobility : Bool
  known_thrombophilia : Bool
  recent_trauma_or_surgery : Bool
  elderly_age : Bool
  heart_or_respiratory_failure : Bool
  acute_mi_or_stroke : Bool
  acute_infection_or_rheumatologic : Bool
  bmi_over_30 : Bool
  ongoing_hormonal_treatment : Bool
} derive(Debug, Eq)

///|
pub fn validate_padua(input : PaduaInput) -> ValidationError? {
  let _ = input
  None
}

///|
pub fn padua_score(input : PaduaInput) -> Int {
  let cancer = caprini_bool_points(input.active_cancer, 3)
  let previous = caprini_bool_points(input.previous_vte, 3)
  let mobility = caprini_bool_points(input.reduced_mobility, 3)
  let thrombophilia = caprini_bool_points(input.known_thrombophilia, 3)
  let trauma = caprini_bool_points(input.recent_trauma_or_surgery, 2)
  let age = caprini_bool_points(input.elderly_age, 1)
  let failure = caprini_bool_points(input.heart_or_respiratory_failure, 1)
  let event = caprini_bool_points(input.acute_mi_or_stroke, 1)
  let infection = caprini_bool_points(input.acute_infection_or_rheumatologic, 1)
  let bmi = caprini_bool_points(input.bmi_over_30, 1)
  let hormones = caprini_bool_points(input.ongoing_hormonal_treatment, 1)
  cancer +
  previous +
  mobility +
  thrombophilia +
  trauma +
  age +
  failure +
  event +
  infection +
  bmi +
  hormones
}

///|
pub fn padua_severity(score : Int) -> Severity {
  if score >= 4 {
    High
  } else if score >= 2 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_padua(input : PaduaInput) -> ScoreReport {
  let score = padua_score(input)
  report(
    "Padua",
    score,
    padua_severity(score),
    "Padua identifies venous thromboembolism risk in hospitalized medical patients; bleeding risk must be assessed separately.",
    [
      explanation(
        "Active cancer",
        caprini_bool_points(input.active_cancer, 3),
        "Three-point factor",
      ),
      explanation(
        "Previous VTE",
        caprini_bool_points(input.previous_vte, 3),
        "Three-point factor",
      ),
      explanation(
        "Reduced mobility",
        caprini_bool_points(input.reduced_mobility, 3),
        "Three-point factor",
      ),
      explanation(
        "Other factors",
        score -
        caprini_bool_points(input.active_cancer, 3) -
        caprini_bool_points(input.previous_vte, 3) -
        caprini_bool_points(input.reduced_mobility, 3),
        "Remaining Padua factors",
      ),
    ],
  )
}

///|
pub(all) struct StopBangInput {
  snoring : Bool
  tiredness : Bool
  observed_apnea : Bool
  hypertension : Bool
  bmi_over_35 : Bool
  age_over_50 : Bool
  neck_circumference_over_40_cm : Bool
  male : Bool
} derive(Debug, Eq)

///|
pub fn stop_bang_score(input : StopBangInput) -> Int {
  caprini_bool_points(input.snoring, 1) +
  caprini_bool_points(input.tiredness, 1) +
  caprini_bool_points(input.observed_apnea, 1) +
  caprini_bool_points(input.hypertension, 1) +
  caprini_bool_points(input.bmi_over_35, 1) +
  caprini_bool_points(input.age_over_50, 1) +
  caprini_bool_points(input.neck_circumference_over_40_cm, 1) +
  caprini_bool_points(input.male, 1)
}

///|
pub fn stop_bang_severity(score : Int) -> Severity {
  if score >= 5 {
    High
  } else if score >= 3 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_stop_bang(input : StopBangInput) -> ScoreReport {
  let score = stop_bang_score(input)
  report(
    "STOP-Bang",
    score,
    stop_bang_severity(score),
    "STOP-Bang screens for obstructive sleep apnea risk before perioperative planning.",
    [
      explanation(
        "Snoring",
        caprini_bool_points(input.snoring, 1),
        "Loud or regular snoring",
      ),
      explanation(
        "Tiredness",
        caprini_bool_points(input.tiredness, 1),
        "Daytime tiredness",
      ),
      explanation(
        "Observed apnea",
        caprini_bool_points(input.observed_apnea, 1),
        "Observed pauses in breathing",
      ),
      explanation(
        "Hypertension",
        caprini_bool_points(input.hypertension, 1),
        "History of hypertension",
      ),
      explanation(
        "Body mass index",
        caprini_bool_points(input.bmi_over_35, 1),
        "BMI above 35",
      ),
      explanation(
        "Age",
        caprini_bool_points(input.age_over_50, 1),
        "Age above 50",
      ),
      explanation(
        "Neck",
        caprini_bool_points(input.neck_circumference_over_40_cm, 1),
        "Neck circumference above 40 cm",
      ),
      explanation("Sex", caprini_bool_points(input.male, 1), "Male sex"),
    ],
  )
}

///|
pub(all) struct AriscatInput {
  age : Int
  preoperative_oxygen_saturation : Int
  respiratory_infection_last_month : Bool
  preoperative_anemia : Bool
  surgical_incision_site : Int
  expected_duration_minutes : Int
  emergency_surgery : Bool
} derive(Debug, Eq)

///|
pub fn validate_ariscat(input : AriscatInput) -> ValidationError? {
  match validate_range("age", input.age, 0, 150) {
    Some(err) => Some(err)
    None =>
      match
        validate_range(
          "preoperative_oxygen_saturation",
          input.preoperative_oxygen_saturation,
          0,
          100,
        ) {
        Some(err) => Some(err)
        None =>
          match
            validate_range(
              "surgical_incision_site",
              input.surgical_incision_site,
              0,
              2,
            ) {
            Some(err) => Some(err)
            None =>
              validate_range(
                "expected_duration_minutes",
                input.expected_duration_minutes,
                0,
                2000,
              )
          }
      }
  }
}

///|
pub fn ariscat_age_points(age : Int) -> Int {
  if age < 51 {
    0
  } else if age <= 80 {
    3
  } else {
    16
  }
}

///|
pub fn ariscat_oxygen_points(value : Int) -> Int {
  if value >= 96 {
    0
  } else if value >= 91 {
    8
  } else if value >= 86 {
    17
  } else {
    24
  }
}

///|
pub fn ariscat_infection_points(value : Bool) -> Int {
  if value {
    17
  } else {
    0
  }
}

///|
pub fn ariscat_anemia_points(value : Bool) -> Int {
  if value {
    11
  } else {
    0
  }
}

///|
pub fn ariscat_incision_points(value : Int) -> Int {
  if value <= 0 {
    0
  } else if value == 1 {
    15
  } else {
    24
  }
}

///|
pub fn ariscat_duration_points(minutes : Int) -> Int {
  if minutes < 120 {
    0
  } else if minutes < 180 {
    16
  } else {
    23
  }
}

///|
pub fn ariscat_emergency_points(value : Bool) -> Int {
  if value {
    8
  } else {
    0
  }
}

///|
pub fn ariscat_severity(score : Int) -> Severity {
  if score >= 45 {
    Critical
  } else if score >= 26 {
    High
  } else if score >= 16 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_ariscat(input : AriscatInput) -> ScoreReport {
  let age = ariscat_age_points(input.age)
  let oxygen = ariscat_oxygen_points(input.preoperative_oxygen_saturation)
  let infection = ariscat_infection_points(
    input.respiratory_infection_last_month,
  )
  let anemia = ariscat_anemia_points(input.preoperative_anemia)
  let incision = ariscat_incision_points(input.surgical_incision_site)
  let duration = ariscat_duration_points(input.expected_duration_minutes)
  let emergency = ariscat_emergency_points(input.emergency_surgery)
  let score = age +
    oxygen +
    infection +
    anemia +
    incision +
    duration +
    emergency
  report(
    "ARISCAT",
    score,
    ariscat_severity(score),
    "ARISCAT estimates postoperative pulmonary complication risk from preoperative and procedural factors.",
    [
      explanation("Age", age, "Age band"),
      explanation("Oxygen saturation", oxygen, "Preoperative saturation band"),
      explanation(
        "Respiratory infection", infection, "Respiratory infection in the last month",
      ),
      explanation("Anemia", anemia, "Preoperative anemia"),
      explanation("Incision", incision, "Surgical incision location"),
      explanation("Duration", duration, "Expected surgical duration"),
      explanation("Emergency", emergency, "Emergency surgery"),
    ],
  )
}
