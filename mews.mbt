///|
pub(all) struct MewsInput {
  systolic_bp : Int
  heart_rate : Int
  respiratory_rate : Int
  temperature_tenths_c : Int
  consciousness : Consciousness
} derive(Debug, Eq)

///|
pub fn validate_mews(input : MewsInput) -> ValidationError? {
  match validate_range("systolic_bp", input.systolic_bp, 30, 300) {
    Some(err) => Some(err)
    None =>
      match validate_range("heart_rate", input.heart_rate, 0, 300) {
        Some(err) => Some(err)
        None =>
          match
            validate_range("respiratory_rate", input.respiratory_rate, 0, 100) {
            Some(err) => Some(err)
            None =>
              validate_range(
                "temperature_tenths_c",
                input.temperature_tenths_c,
                250,
                450,
              )
          }
      }
  }
}

///|
pub fn mews_systolic_bp_points(value : Int) -> Int {
  if value <= 70 {
    3
  } else if value <= 80 {
    2
  } else if value <= 100 {
    1
  } else if value <= 199 {
    0
  } else {
    2
  }
}

///|
pub fn mews_heart_rate_points(value : Int) -> Int {
  if value < 40 {
    2
  } else if value <= 50 {
    1
  } else if value <= 100 {
    0
  } else if value <= 129 {
    2
  } else {
    3
  }
}

///|
pub fn mews_respiratory_rate_points(value : Int) -> Int {
  if value < 9 {
    2
  } else if value <= 14 {
    0
  } else if value <= 20 {
    1
  } else if value <= 29 {
    2
  } else {
    3
  }
}

///|
pub fn mews_temperature_points(value : Int) -> Int {
  if value < 350 {
    2
  } else if value <= 380 {
    0
  } else if value <= 390 {
    1
  } else {
    2
  }
}

///|
pub fn mews_consciousness_points(value : Consciousness) -> Int {
  match value {
    Alert => 0
    NewConfusion | Voice | Pain | Unresponsive => 3
  }
}

///|
pub fn mews_severity(score : Int) -> Severity {
  if score >= 9 {
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
pub fn score_mews(input : MewsInput) -> ScoreReport {
  let bp = mews_systolic_bp_points(input.systolic_bp)
  let heart = mews_heart_rate_points(input.heart_rate)
  let respiration = mews_respiratory_rate_points(input.respiratory_rate)
  let temperature = mews_temperature_points(input.temperature_tenths_c)
  let consciousness = mews_consciousness_points(input.consciousness)
  let score = bp + heart + respiration + temperature + consciousness
  report(
    "MEWS",
    score,
    mews_severity(score),
    "MEWS is an early-warning score and does not replace local escalation policy.",
    [
      explanation("Systolic blood pressure", bp, "MEWS systolic pressure band"),
      explanation("Heart rate", heart, "MEWS pulse band"),
      explanation("Respiratory rate", respiration, "MEWS respiratory band"),
      explanation("Temperature", temperature, "MEWS temperature band"),
      explanation("Consciousness", consciousness, "MEWS AVPU contribution"),
    ],
  )
}
