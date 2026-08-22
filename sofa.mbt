///|
pub(all) enum VasopressorLevel {
  None
  DopamineLow
  DopamineHigh
  NorepinephrineLow
  NorepinephrineHigh
} derive(Debug, Eq)

///|
pub(all) struct SofaInput {
  pao2_fio2 : Int
  respiratory_support : Bool
  platelets : Int
  bilirubin_micromol : Int
  mean_arterial_pressure : Int
  vasopressor : VasopressorLevel
  gcs_total : Int
  creatinine_micromol : Int
  urine_ml_day : Int
} derive(Debug, Eq)

///|
pub fn validate_sofa(input : SofaInput) -> ValidationError? {
  match validate_range("pao2_fio2", input.pao2_fio2, 0, 1000) {
    Some(err) => Some(err)
    None =>
      match validate_range("platelets", input.platelets, 0, 1000) {
        Some(err) => Some(err)
        None =>
          match
            validate_range(
              "bilirubin_micromol",
              input.bilirubin_micromol,
              0,
              1000,
            ) {
            Some(err) => Some(err)
            None =>
              match
                validate_range(
                  "mean_arterial_pressure",
                  input.mean_arterial_pressure,
                  0,
                  300,
                ) {
                Some(err) => Some(err)
                None =>
                  match validate_range("gcs_total", input.gcs_total, 3, 15) {
                    Some(err) => Some(err)
                    None =>
                      match
                        validate_range(
                          "creatinine_micromol",
                          input.creatinine_micromol,
                          0,
                          2000,
                        ) {
                        Some(err) => Some(err)
                        None =>
                          validate_range(
                            "urine_ml_day",
                            input.urine_ml_day,
                            0,
                            10000,
                          )
                      }
                  }
              }
          }
      }
  }
}

///|
pub fn sofa_respiratory_points(ratio : Int, support : Bool) -> Int {
  if ratio < 100 && support {
    4
  } else if ratio < 200 && support {
    3
  } else if ratio < 300 {
    2
  } else if ratio < 400 {
    1
  } else {
    0
  }
}

///|
pub fn sofa_platelet_points(value : Int) -> Int {
  if value < 20 {
    4
  } else if value < 50 {
    3
  } else if value < 100 {
    2
  } else if value < 150 {
    1
  } else {
    0
  }
}

///|
pub fn sofa_bilirubin_points(value : Int) -> Int {
  if value >= 204 {
    4
  } else if value >= 102 {
    3
  } else if value >= 33 {
    2
  } else if value >= 20 {
    1
  } else {
    0
  }
}

///|
pub fn sofa_circulation_points(map : Int, pressor : VasopressorLevel) -> Int {
  match pressor {
    NorepinephrineHigh | DopamineHigh => 4
    NorepinephrineLow => 3
    DopamineLow => 2
    None => if map < 70 { 1 } else { 0 }
  }
}

///|
pub fn sofa_gcs_points(value : Int) -> Int {
  if value < 6 {
    4
  } else if value < 10 {
    3
  } else if value < 13 {
    2
  } else if value < 15 {
    1
  } else {
    0
  }
}

///|
pub fn sofa_renal_points(creatinine : Int, urine : Int) -> Int {
  if creatinine >= 440 || urine < 200 {
    4
  } else if creatinine >= 300 || urine < 500 {
    3
  } else if creatinine >= 171 {
    2
  } else if creatinine >= 110 {
    1
  } else {
    0
  }
}

///|
pub fn sofa_severity(score : Int) -> Severity {
  if score >= 12 {
    Critical
  } else if score >= 8 {
    High
  } else if score >= 4 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_sofa(input : SofaInput) -> ScoreReport {
  let respiratory = sofa_respiratory_points(
    input.pao2_fio2,
    input.respiratory_support,
  )
  let platelets = sofa_platelet_points(input.platelets)
  let bilirubin = sofa_bilirubin_points(input.bilirubin_micromol)
  let circulation = sofa_circulation_points(
    input.mean_arterial_pressure,
    input.vasopressor,
  )
  let neurological = sofa_gcs_points(input.gcs_total)
  let renal = sofa_renal_points(input.creatinine_micromol, input.urine_ml_day)
  let score = respiratory +
    platelets +
    bilirubin +
    circulation +
    neurological +
    renal
  report(
    "SOFA",
    score,
    sofa_severity(score),
    "SOFA summarizes organ-system dysfunction; use the intended clinical context and baseline policy.",
    [
      explanation(
        "Respiration", respiratory, "PaO2/FiO2 and respiratory support",
      ),
      explanation("Coagulation", platelets, "Platelet band"),
      explanation("Liver", bilirubin, "Bilirubin band"),
      explanation("Cardiovascular", circulation, "MAP and vasopressor band"),
      explanation("Central nervous system", neurological, "GCS band"),
      explanation("Renal", renal, "Creatinine and urine-output band"),
    ],
  )
}
