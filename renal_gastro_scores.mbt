///|
pub(all) struct ChildPughInput {
  bilirubin_tenths_mg_dl : Int
  albumin_tenths_g_dl : Int
  inr_hundredths : Int
  ascites_grade : Int
  encephalopathy_grade : Int
} derive(Debug, Eq)

///|
pub fn validate_child_pugh(input : ChildPughInput) -> ValidationError? {
  match
    validate_range(
      "bilirubin_tenths_mg_dl",
      input.bilirubin_tenths_mg_dl,
      0,
      1000,
    ) {
    Some(err) => Some(err)
    None =>
      match
        validate_range("albumin_tenths_g_dl", input.albumin_tenths_g_dl, 0, 100) {
        Some(err) => Some(err)
        None =>
          match
            validate_range("inr_hundredths", input.inr_hundredths, 0, 1000) {
            Some(err) => Some(err)
            None =>
              match validate_range("ascites_grade", input.ascites_grade, 0, 2) {
                Some(err) => Some(err)
                None =>
                  validate_range(
                    "encephalopathy_grade",
                    input.encephalopathy_grade,
                    0,
                    2,
                  )
              }
          }
      }
  }
}

///|
pub fn child_pugh_bilirubin_points(value : Int) -> Int {
  if value <= 20 {
    1
  } else if value <= 30 {
    2
  } else {
    3
  }
}

///|
pub fn child_pugh_albumin_points(value : Int) -> Int {
  if value >= 35 {
    1
  } else if value >= 28 {
    2
  } else {
    3
  }
}

///|
pub fn child_pugh_inr_points(value : Int) -> Int {
  if value < 170 {
    1
  } else if value <= 230 {
    2
  } else {
    3
  }
}

///|
pub fn child_pugh_ascites_points(value : Int) -> Int {
  if value <= 0 {
    1
  } else if value == 1 {
    2
  } else {
    3
  }
}

///|
pub fn child_pugh_encephalopathy_points(value : Int) -> Int {
  if value <= 0 {
    1
  } else if value == 1 {
    2
  } else {
    3
  }
}

///|
pub fn child_pugh_class(score : Int) -> String {
  if score <= 6 {
    "A"
  } else if score <= 9 {
    "B"
  } else {
    "C"
  }
}

///|
pub fn child_pugh_severity(score : Int) -> Severity {
  if score <= 6 {
    Low
  } else if score <= 9 {
    Medium
  } else {
    High
  }
}

///|
pub fn score_child_pugh(input : ChildPughInput) -> ScoreReport {
  let bilirubin = child_pugh_bilirubin_points(input.bilirubin_tenths_mg_dl)
  let albumin = child_pugh_albumin_points(input.albumin_tenths_g_dl)
  let inr = child_pugh_inr_points(input.inr_hundredths)
  let ascites = child_pugh_ascites_points(input.ascites_grade)
  let encephalopathy = child_pugh_encephalopathy_points(
    input.encephalopathy_grade,
  )
  let score = bilirubin + albumin + inr + ascites + encephalopathy
  report(
    "Child-Pugh",
    score,
    child_pugh_severity(score),
    "Child-Pugh classifies chronic liver disease severity from five clinical and laboratory domains.",
    [
      explanation("Bilirubin", bilirubin, "Total bilirubin band"),
      explanation("Albumin", albumin, "Serum albumin band"),
      explanation("Coagulation", inr, "INR band"),
      explanation("Ascites", ascites, "Ascites grade"),
      explanation("Encephalopathy", encephalopathy, "Encephalopathy grade"),
      explanation("Class", score, "Child-Pugh class=" + child_pugh_class(score)),
    ],
  )
}

///|
pub(all) struct GlasgowBlatchfordInput {
  bun_mmol_l_tenths : Int
  hemoglobin_g_dl_tenths : Int
  female : Bool
  systolic_bp : Int
  pulse : Int
  melena : Bool
  syncope : Bool
  hepatic_disease : Bool
  cardiac_failure : Bool
} derive(Debug, Eq)

///|
pub fn validate_glasgow_blatchford(
  input : GlasgowBlatchfordInput,
) -> ValidationError? {
  match validate_range("bun_mmol_l_tenths", input.bun_mmol_l_tenths, 0, 1000) {
    Some(err) => Some(err)
    None =>
      match
        validate_range(
          "hemoglobin_g_dl_tenths",
          input.hemoglobin_g_dl_tenths,
          0,
          250,
        ) {
        Some(err) => Some(err)
        None =>
          match validate_range("systolic_bp", input.systolic_bp, 0, 300) {
            Some(err) => Some(err)
            None => validate_range("pulse", input.pulse, 0, 300)
          }
      }
  }
}

///|
pub fn gbs_bun_points(value : Int) -> Int {
  if value < 65 {
    0
  } else if value < 80 {
    2
  } else if value < 100 {
    3
  } else if value < 250 {
    4
  } else {
    6
  }
}

///|
pub fn gbs_male_hemoglobin_points(value : Int) -> Int {
  if value >= 130 {
    0
  } else if value >= 120 {
    1
  } else if value >= 100 {
    3
  } else {
    6
  }
}

///|
pub fn gbs_female_hemoglobin_points(value : Int) -> Int {
  if value >= 120 {
    0
  } else if value >= 100 {
    1
  } else {
    6
  }
}

///|
pub fn gbs_hemoglobin_points(value : Int, female : Bool) -> Int {
  if female {
    gbs_female_hemoglobin_points(value)
  } else {
    gbs_male_hemoglobin_points(value)
  }
}

///|
pub fn gbs_pressure_points(value : Int) -> Int {
  if value >= 110 {
    0
  } else if value >= 100 {
    1
  } else if value >= 90 {
    2
  } else {
    3
  }
}

///|
pub fn gbs_pulse_points(value : Int) -> Int {
  if value >= 100 {
    1
  } else {
    0
  }
}

///|
pub fn gbs_bool_points(value : Bool, points : Int) -> Int {
  if value {
    points
  } else {
    0
  }
}

///|
pub fn gbs_severity(score : Int) -> Severity {
  if score == 0 {
    Low
  } else if score <= 5 {
    Medium
  } else {
    High
  }
}

///|
pub fn score_glasgow_blatchford(input : GlasgowBlatchfordInput) -> ScoreReport {
  let bun = gbs_bun_points(input.bun_mmol_l_tenths)
  let hemoglobin = gbs_hemoglobin_points(
    input.hemoglobin_g_dl_tenths,
    input.female,
  )
  let pressure = gbs_pressure_points(input.systolic_bp)
  let pulse = gbs_pulse_points(input.pulse)
  let melena = gbs_bool_points(input.melena, 1)
  let syncope = gbs_bool_points(input.syncope, 2)
  let hepatic = gbs_bool_points(input.hepatic_disease, 2)
  let cardiac = gbs_bool_points(input.cardiac_failure, 2)
  let score = bun +
    hemoglobin +
    pressure +
    pulse +
    melena +
    syncope +
    hepatic +
    cardiac
  report(
    "Glasgow-Blatchford",
    score,
    gbs_severity(score),
    "The Glasgow-Blatchford score estimates intervention risk in upper gastrointestinal bleeding.",
    [
      explanation("Blood urea", bun, "BUN band"),
      explanation("Hemoglobin", hemoglobin, "Sex-specific hemoglobin band"),
      explanation("Systolic pressure", pressure, "Systolic blood pressure band"),
      explanation("Pulse", pulse, "Pulse at least 100/min"),
      explanation("Melena", melena, "Melena present"),
      explanation("Syncope", syncope, "Syncope present"),
      explanation("Hepatic disease", hepatic, "Known hepatic disease"),
      explanation("Cardiac failure", cardiac, "Known cardiac failure"),
    ],
  )
}

///|
pub(all) struct AkiInput {
  baseline_creatinine_hundredths : Int
  current_creatinine_hundredths : Int
  urine_rate_hundredths_ml_kg_h : Int
  urine_duration_hours : Int
} derive(Debug, Eq)

///|
pub fn validate_aki(input : AkiInput) -> ValidationError? {
  match
    validate_range(
      "baseline_creatinine_hundredths",
      input.baseline_creatinine_hundredths,
      1,
      2000,
    ) {
    Some(err) => Some(err)
    None =>
      match
        validate_range(
          "current_creatinine_hundredths",
          input.current_creatinine_hundredths,
          1,
          2000,
        ) {
        Some(err) => Some(err)
        None =>
          match
            validate_range(
              "urine_rate_hundredths_ml_kg_h",
              input.urine_rate_hundredths_ml_kg_h,
              0,
              1000,
            ) {
            Some(err) => Some(err)
            None =>
              validate_range(
                "urine_duration_hours",
                input.urine_duration_hours,
                0,
                72,
              )
          }
      }
  }
}

///|
pub fn aki_creatinine_stage(input : AkiInput) -> Int {
  let baseline = input.baseline_creatinine_hundredths
  let current = input.current_creatinine_hundredths
  if current >= 400 || current >= baseline * 3 {
    3
  } else if current >= baseline * 2 {
    2
  } else if current >= baseline + 30 || current * 2 >= baseline * 3 {
    1
  } else {
    0
  }
}

///|
pub fn aki_urine_stage(input : AkiInput) -> Int {
  if input.urine_duration_hours >= 24 &&
    input.urine_rate_hundredths_ml_kg_h < 30 {
    3
  } else if input.urine_duration_hours >= 12 &&
    input.urine_rate_hundredths_ml_kg_h < 50 {
    2
  } else if input.urine_duration_hours >= 6 &&
    input.urine_rate_hundredths_ml_kg_h < 50 {
    1
  } else {
    0
  }
}

///|
pub fn aki_stage(input : AkiInput) -> Int {
  let creatinine = aki_creatinine_stage(input)
  let urine = aki_urine_stage(input)
  if creatinine > urine {
    creatinine
  } else {
    urine
  }
}

///|
pub fn aki_severity(stage : Int) -> Severity {
  if stage >= 3 {
    Critical
  } else if stage == 2 {
    High
  } else if stage == 1 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_aki(input : AkiInput) -> ScoreReport {
  let creatinine = aki_creatinine_stage(input)
  let urine = aki_urine_stage(input)
  let stage = aki_stage(input)
  report(
    "AKI-KDIGO",
    stage,
    aki_severity(stage),
    "This implementation evaluates creatinine and urine-output stage criteria; clinical context remains required.",
    [
      explanation("Creatinine stage", creatinine, "Creatinine-based stage"),
      explanation("Urine stage", urine, "Urine-output-based stage"),
      explanation("Combined stage", stage, "Maximum of component stages"),
    ],
  )
}
