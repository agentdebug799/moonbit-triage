///|
pub(all) struct PesiInput {
  age : Int
  male : Bool
  nursing_home : Bool
  cancer : Bool
  heart_failure : Bool
  chronic_lung_disease : Bool
  heart_rate : Int
  systolic_bp : Int
  temperature_tenths_c : Int
  altered_mentation : Bool
  oxygen_saturation : Int
} derive(Debug, Eq)

///|
pub fn validate_pesi(input : PesiInput) -> ValidationError? {
  match validate_range("age", input.age, 0, 150) {
    Some(err) => Some(err)
    None =>
      match validate_range("heart_rate", input.heart_rate, 0, 300) {
        Some(err) => Some(err)
        None =>
          match validate_range("systolic_bp", input.systolic_bp, 0, 300) {
            Some(err) => Some(err)
            None =>
              match
                validate_range(
                  "temperature_tenths_c",
                  input.temperature_tenths_c,
                  250,
                  450,
                ) {
                Some(err) => Some(err)
                None =>
                  validate_range(
                    "oxygen_saturation",
                    input.oxygen_saturation,
                    0,
                    100,
                  )
              }
          }
      }
  }
}

///|
pub fn pesi_severity(score : Int) -> Severity {
  if score >= 126 {
    Critical
  } else if score >= 106 {
    High
  } else if score >= 86 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_pesi(input : PesiInput) -> ScoreReport {
  let age = input.age
  let sex = if input.male { 10 } else { 0 }
  let home = if input.nursing_home { 10 } else { 0 }
  let cancer = if input.cancer { 30 } else { 0 }
  let failure = if input.heart_failure { 10 } else { 0 }
  let lung = if input.chronic_lung_disease { 10 } else { 0 }
  let pulse = if input.heart_rate >= 110 { 20 } else { 0 }
  let pressure = if input.systolic_bp < 100 { 30 } else { 0 }
  let temperature = if input.temperature_tenths_c < 360 ||
    input.temperature_tenths_c >= 400 {
    20
  } else {
    0
  }
  let mentation = if input.altered_mentation { 60 } else { 0 }
  let oxygen = if input.oxygen_saturation < 90 { 20 } else { 0 }
  let score = age +
    sex +
    home +
    cancer +
    failure +
    lung +
    pulse +
    pressure +
    temperature +
    mentation +
    oxygen
  report(
    "PESI",
    score,
    pesi_severity(score),
    "PESI is a pulmonary-embolism severity index; it is not a disposition order.",
    [
      explanation("Age", age, "Age contributes one point per year"),
      explanation("Sex", sex, "Male sex contribution"),
      explanation("Nursing home", home, "Residence in a nursing facility"),
      explanation("Cancer", cancer, "Cancer contribution"),
      explanation("Heart failure", failure, "Heart-failure contribution"),
      explanation(
        "Chronic lung disease", lung, "Chronic lung disease contribution",
      ),
      explanation("Heart rate", pulse, "Heart rate at least 110/min"),
      explanation(
        "Systolic pressure", pressure, "Systolic pressure below 100 mmHg",
      ),
      explanation(
        "Temperature", temperature, "Temperature outside the reference band",
      ),
      explanation("Mentation", mentation, "Altered mental status"),
      explanation("Oxygen", oxygen, "Oxygen saturation below 90 percent"),
    ],
  )
}

///|
pub(all) struct BodeInput {
  body_mass_index : Int
  fev1_percent : Int
  modified_mrc : Int
  six_minute_walk_meters : Int
} derive(Debug, Eq)

///|
pub fn validate_bode(input : BodeInput) -> ValidationError? {
  match validate_range("body_mass_index", input.body_mass_index, 0, 100) {
    Some(err) => Some(err)
    None =>
      match validate_range("fev1_percent", input.fev1_percent, 0, 200) {
        Some(err) => Some(err)
        None =>
          match validate_range("modified_mrc", input.modified_mrc, 0, 4) {
            Some(err) => Some(err)
            None =>
              validate_range(
                "six_minute_walk_meters",
                input.six_minute_walk_meters,
                0,
                1000,
              )
          }
      }
  }
}

///|
pub fn bode_bmi_points(value : Int) -> Int {
  if value <= 21 {
    1
  } else {
    0
  }
}

///|
pub fn bode_fev1_points(value : Int) -> Int {
  if value >= 65 {
    0
  } else if value >= 50 {
    1
  } else if value >= 36 {
    2
  } else {
    3
  }
}

///|
pub fn bode_mrc_points(value : Int) -> Int {
  if value <= 1 {
    0
  } else if value == 2 {
    1
  } else if value == 3 {
    2
  } else {
    3
  }
}

///|
pub fn bode_walk_points(value : Int) -> Int {
  if value >= 350 {
    0
  } else if value >= 250 {
    1
  } else if value >= 150 {
    2
  } else {
    3
  }
}

///|
pub fn bode_severity(score : Int) -> Severity {
  if score >= 7 {
    Critical
  } else if score >= 5 {
    High
  } else if score >= 3 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_bode(input : BodeInput) -> ScoreReport {
  let bmi = bode_bmi_points(input.body_mass_index)
  let fev1 = bode_fev1_points(input.fev1_percent)
  let mrc = bode_mrc_points(input.modified_mrc)
  let walk = bode_walk_points(input.six_minute_walk_meters)
  let score = bmi + fev1 + mrc + walk
  report(
    "BODE",
    score,
    bode_severity(score),
    "BODE summarizes COPD severity domains and is not a stand-alone treatment decision.",
    [
      explanation("BMI", bmi, "Body mass index band"),
      explanation("Airflow obstruction", fev1, "FEV1 percent predicted band"),
      explanation("Dyspnea", mrc, "Modified MRC dyspnea band"),
      explanation("Exercise capacity", walk, "Six-minute walk distance band"),
    ],
  )
}

///|
pub(all) struct QcsiInput {
  respiratory_rate : Int
  oxygen_saturation : Int
  oxygen_flow_liters : Int
} derive(Debug, Eq)

///|
pub fn validate_qcsi(input : QcsiInput) -> ValidationError? {
  match validate_range("respiratory_rate", input.respiratory_rate, 0, 100) {
    Some(err) => Some(err)
    None =>
      match
        validate_range("oxygen_saturation", input.oxygen_saturation, 0, 100) {
        Some(err) => Some(err)
        None =>
          validate_range("oxygen_flow_liters", input.oxygen_flow_liters, 0, 100)
      }
  }
}

///|
pub fn qcsi_respiratory_points(value : Int) -> Int {
  if value >= 30 {
    3
  } else if value >= 23 {
    2
  } else if value >= 16 {
    1
  } else {
    0
  }
}

///|
pub fn qcsi_oxygen_points(value : Int) -> Int {
  if value <= 89 {
    3
  } else if value <= 93 {
    2
  } else if value <= 95 {
    1
  } else {
    0
  }
}

///|
pub fn qcsi_flow_points(value : Int) -> Int {
  if value >= 15 {
    3
  } else if value >= 6 {
    2
  } else if value >= 1 {
    1
  } else {
    0
  }
}

///|
pub fn qcsi_severity(score : Int) -> Severity {
  if score >= 7 {
    Critical
  } else if score >= 5 {
    High
  } else if score >= 2 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_qcsi(input : QcsiInput) -> ScoreReport {
  let respiration = qcsi_respiratory_points(input.respiratory_rate)
  let oxygen = qcsi_oxygen_points(input.oxygen_saturation)
  let flow = qcsi_flow_points(input.oxygen_flow_liters)
  let score = respiration + oxygen + flow
  report(
    "qCSI",
    score,
    qcsi_severity(score),
    "qCSI is an oxygenation and respiratory-rate severity aid for local respiratory pathways.",
    [
      explanation("Respiratory rate", respiration, "Respiratory-rate band"),
      explanation("Oxygen saturation", oxygen, "Oxygen-saturation band"),
      explanation("Oxygen flow", flow, "Supplemental oxygen flow band"),
    ],
  )
}

///|
pub(all) struct HestiaInput {
  unstable : Bool
  oxygen_saturation_low : Bool
  active_bleeding : Bool
  need_thrombolysis : Bool
  severe_renal_impairment : Bool
  severe_liver_impairment : Bool
  social_barrier : Bool
  pregnancy : Bool
  history_bleeding : Bool
  treatment_failure : Bool
} derive(Debug, Eq)

///|
pub fn hestia_positive_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn hestia_severity(score : Int) -> Severity {
  if score >= 2 {
    Critical
  } else if score == 1 {
    High
  } else {
    Low
  }
}

///|
pub fn score_hestia(input : HestiaInput) -> ScoreReport {
  let unstable = hestia_positive_points(input.unstable)
  let oxygen = hestia_positive_points(input.oxygen_saturation_low)
  let bleeding = hestia_positive_points(input.active_bleeding)
  let thrombolysis = hestia_positive_points(input.need_thrombolysis)
  let renal = hestia_positive_points(input.severe_renal_impairment)
  let liver = hestia_positive_points(input.severe_liver_impairment)
  let social = hestia_positive_points(input.social_barrier)
  let pregnancy = hestia_positive_points(input.pregnancy)
  let history = hestia_positive_points(input.history_bleeding)
  let failure = hestia_positive_points(input.treatment_failure)
  let score = unstable +
    oxygen +
    bleeding +
    thrombolysis +
    renal +
    liver +
    social +
    pregnancy +
    history +
    failure
  report(
    "Hestia",
    score,
    hestia_severity(score),
    "Hestia criteria identify exclusions from selected outpatient PE pathways.",
    [
      explanation("Instability", unstable, "Hemodynamic instability"),
      explanation(
        "Oxygenation", oxygen, "Oxygenation below local outpatient threshold",
      ),
      explanation("Bleeding", bleeding, "Active bleeding or high bleeding risk"),
      explanation(
        "Thrombolysis", thrombolysis, "Need for inpatient reperfusion therapy",
      ),
      explanation("Renal impairment", renal, "Severe renal impairment"),
      explanation("Liver impairment", liver, "Severe hepatic impairment"),
      explanation("Social barrier", social, "Lack of safe outpatient support"),
      explanation("Pregnancy", pregnancy, "Pregnancy criterion"),
      explanation(
        "Bleeding history", history, "Recent clinically significant bleeding",
      ),
      explanation(
        "Treatment failure", failure, "Failure of prior outpatient treatment",
      ),
    ],
  )
}

///|
pub(all) struct RevisedTraumaInput {
  gcs_total : Int
  systolic_bp : Int
  respiratory_rate : Int
} derive(Debug, Eq)

///|
pub fn validate_revised_trauma(input : RevisedTraumaInput) -> ValidationError? {
  match validate_range("gcs_total", input.gcs_total, 3, 15) {
    Some(err) => Some(err)
    None =>
      match validate_range("systolic_bp", input.systolic_bp, 0, 300) {
        Some(err) => Some(err)
        None =>
          validate_range("respiratory_rate", input.respiratory_rate, 0, 100)
      }
  }
}

///|
pub fn trauma_gcs_points(value : Int) -> Int {
  if value >= 13 {
    4
  } else if value >= 9 {
    3
  } else if value >= 6 {
    2
  } else if value >= 4 {
    1
  } else {
    0
  }
}

///|
pub fn trauma_pressure_points(value : Int) -> Int {
  if value >= 90 {
    4
  } else if value >= 76 {
    3
  } else if value >= 50 {
    2
  } else if value >= 1 {
    1
  } else {
    0
  }
}

///|
pub fn trauma_respiration_points(value : Int) -> Int {
  if value >= 10 && value <= 29 {
    4
  } else if value >= 6 {
    3
  } else if value >= 1 {
    2
  } else {
    0
  }
}

///|
pub fn revised_trauma_score(input : RevisedTraumaInput) -> Int {
  trauma_gcs_points(input.gcs_total) * 290 +
  trauma_pressure_points(input.systolic_bp) * 271 +
  trauma_respiration_points(input.respiratory_rate) * 276
}

///|
pub fn revised_trauma_severity(score : Int) -> Severity {
  if score < 2500 {
    Critical
  } else if score < 3000 {
    High
  } else if score < 3300 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_revised_trauma(input : RevisedTraumaInput) -> ScoreReport {
  let gcs = trauma_gcs_points(input.gcs_total)
  let pressure = trauma_pressure_points(input.systolic_bp)
  let respiration = trauma_respiration_points(input.respiratory_rate)
  let score = revised_trauma_score(input)
  report(
    "RTS",
    score,
    revised_trauma_severity(score),
    "RTS is a trauma triage aid based on neurologic, pressure, and respiratory components.",
    [
      explanation("GCS", gcs, "Glasgow Coma Scale component"),
      explanation("Systolic pressure", pressure, "Systolic pressure component"),
      explanation("Respiration", respiration, "Respiratory-rate component"),
    ],
  )
}

///|
pub(all) struct InjurySeverityInput {
  head_neck : Int
  face : Int
  chest : Int
  abdomen : Int
  extremity : Int
  external : Int
} derive(Debug, Eq)

///|
pub fn validate_injury_severity(
  input : InjurySeverityInput,
) -> ValidationError? {
  match validate_range("head_neck", input.head_neck, 0, 6) {
    Some(err) => Some(err)
    None =>
      match validate_range("face", input.face, 0, 6) {
        Some(err) => Some(err)
        None =>
          match validate_range("chest", input.chest, 0, 6) {
            Some(err) => Some(err)
            None =>
              match validate_range("abdomen", input.abdomen, 0, 6) {
                Some(err) => Some(err)
                None =>
                  match validate_range("extremity", input.extremity, 0, 6) {
                    Some(err) => Some(err)
                    None => validate_range("external", input.external, 0, 6)
                  }
              }
          }
      }
  }
}

///|
pub fn injury_severity_score(input : InjurySeverityInput) -> Int {
  let a = [
    input.head_neck,
    input.face,
    input.chest,
    input.abdomen,
    input.extremity,
    input.external,
  ]
  let mut first = 0
  let mut second = 0
  let mut third = 0
  for value in a {
    if value > first {
      third = second
      second = first
      first = value
    } else if value > second {
      third = second
      second = value
    } else if value > third {
      third = value
    }
  }
  first * first + second * second + third * third
}

///|
pub fn injury_severity_band(score : Int) -> Severity {
  if score >= 25 {
    Critical
  } else if score >= 16 {
    High
  } else if score >= 9 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_injury_severity(input : InjurySeverityInput) -> ScoreReport {
  let score = injury_severity_score(input)
  report(
    "ISS",
    score,
    injury_severity_band(score),
    "ISS combines the three highest AIS region scores; confirm the AIS coding source.",
    [
      explanation("Head and neck", input.head_neck, "AIS region score"),
      explanation("Face", input.face, "AIS region score"),
      explanation("Chest", input.chest, "AIS region score"),
      explanation("Abdomen", input.abdomen, "AIS region score"),
      explanation("Extremity", input.extremity, "AIS region score"),
      explanation("External", input.external, "AIS region score"),
    ],
  )
}
