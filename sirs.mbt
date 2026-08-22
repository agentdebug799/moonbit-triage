///|
pub(all) struct SirsInput {
  temperature_tenths_c : Int
  heart_rate : Int
  respiratory_rate : Int
  white_cell_count : Int
  immature_neutrophils_percent : Int
} derive(Debug, Eq)

///|
pub fn validate_sirs(input : SirsInput) -> ValidationError? {
  match
    validate_range("temperature_tenths_c", input.temperature_tenths_c, 250, 450) {
    Some(err) => Some(err)
    None =>
      match validate_range("heart_rate", input.heart_rate, 0, 300) {
        Some(err) => Some(err)
        None =>
          match
            validate_range("respiratory_rate", input.respiratory_rate, 0, 100) {
            Some(err) => Some(err)
            None =>
              match
                validate_range(
                  "white_cell_count",
                  input.white_cell_count,
                  0,
                  200,
                ) {
                Some(err) => Some(err)
                None =>
                  validate_range(
                    "immature_neutrophils_percent",
                    input.immature_neutrophils_percent,
                    0,
                    100,
                  )
              }
          }
      }
  }
}

///|
pub fn sirs_temperature_points(value : Int) -> Int {
  if value < 360 || value > 380 {
    1
  } else {
    0
  }
}

///|
pub fn sirs_heart_rate_points(value : Int) -> Int {
  if value > 90 {
    1
  } else {
    0
  }
}

///|
pub fn sirs_respiratory_rate_points(value : Int) -> Int {
  if value > 20 {
    1
  } else {
    0
  }
}

///|
pub fn sirs_white_cell_points(value : Int, immature_percent : Int) -> Int {
  if value < 4 || value > 12 || immature_percent > 10 {
    1
  } else {
    0
  }
}

///|
pub fn sirs_severity(score : Int) -> Severity {
  if score >= 3 {
    High
  } else if score >= 2 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_sirs(input : SirsInput) -> ScoreReport {
  let temperature = sirs_temperature_points(input.temperature_tenths_c)
  let heart = sirs_heart_rate_points(input.heart_rate)
  let respiration = sirs_respiratory_rate_points(input.respiratory_rate)
  let white_cell = sirs_white_cell_points(
    input.white_cell_count,
    input.immature_neutrophils_percent,
  )
  let score = temperature + heart + respiration + white_cell
  report(
    "SIRS",
    score,
    sirs_severity(score),
    "SIRS is a rule-based inflammatory response screen; interpret with the local protocol.",
    [
      explanation(
        "Temperature", temperature, "Temperature outside the SIRS reference band",
      ),
      explanation("Heart rate", heart, "Heart rate above the SIRS threshold"),
      explanation(
        "Respiratory rate", respiration, "Respiratory rate above the SIRS threshold",
      ),
      explanation(
        "White cells", white_cell, "White-cell or immature-neutrophil criterion",
      ),
    ],
  )
}
