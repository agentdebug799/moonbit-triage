///|
pub(all) struct Curbs65Input {
  confusion : Bool
  urea_mmol : Int
  respiratory_rate : Int
  systolic_bp : Int
  diastolic_bp : Int
  age : Int
} derive(Debug, Eq)

///|
pub fn validate_curbs65(input : Curbs65Input) -> ValidationError? {
  match validate_range("urea_mmol", input.urea_mmol, 0, 100) {
    Some(err) => Some(err)
    None =>
      match validate_range("respiratory_rate", input.respiratory_rate, 0, 100) {
        Some(err) => Some(err)
        None =>
          match validate_range("systolic_bp", input.systolic_bp, 0, 300) {
            Some(err) => Some(err)
            None =>
              match validate_range("diastolic_bp", input.diastolic_bp, 0, 200) {
                Some(err) => Some(err)
                None => validate_range("age", input.age, 0, 150)
              }
          }
      }
  }
}

///|
pub fn curbs65_confusion_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn curbs65_urea_points(value : Int) -> Int {
  if value > 7 {
    1
  } else {
    0
  }
}

///|
pub fn curbs65_respiratory_points(value : Int) -> Int {
  if value >= 30 {
    1
  } else {
    0
  }
}

///|
pub fn curbs65_pressure_points(systolic : Int, diastolic : Int) -> Int {
  if systolic < 90 || diastolic <= 60 {
    1
  } else {
    0
  }
}

///|
pub fn curbs65_age_points(value : Int) -> Int {
  if value >= 65 {
    1
  } else {
    0
  }
}

///|
pub fn curbs65_severity(score : Int) -> Severity {
  if score >= 4 {
    Critical
  } else if score >= 3 {
    High
  } else if score >= 2 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_curbs65(input : Curbs65Input) -> ScoreReport {
  let confusion = curbs65_confusion_points(input.confusion)
  let urea = curbs65_urea_points(input.urea_mmol)
  let respiration = curbs65_respiratory_points(input.respiratory_rate)
  let pressure = curbs65_pressure_points(input.systolic_bp, input.diastolic_bp)
  let age = curbs65_age_points(input.age)
  let score = confusion + urea + respiration + pressure + age
  report(
    "CURB-65",
    score,
    curbs65_severity(score),
    "CURB-65 is an illness-severity aid for pneumonia pathways; use local admission policy.",
    [
      explanation("Confusion", confusion, "New confusion criterion"),
      explanation("Urea", urea, "Urea criterion"),
      explanation("Respiratory rate", respiration, "Respiratory-rate criterion"),
      explanation("Blood pressure", pressure, "Low blood-pressure criterion"),
      explanation("Age", age, "Age criterion"),
    ],
  )
}

///|
pub(all) struct ShockIndexInput {
  heart_rate : Int
  systolic_bp : Int
} derive(Debug, Eq)

///|
pub fn validate_shock_index(input : ShockIndexInput) -> ValidationError? {
  match validate_range("heart_rate", input.heart_rate, 0, 300) {
    Some(err) => Some(err)
    None => validate_range("systolic_bp", input.systolic_bp, 1, 300)
  }
}

///|
pub fn shock_index_x100(input : ShockIndexInput) -> Int {
  input.heart_rate * 100 / input.systolic_bp
}

///|
pub fn shock_index_severity(index_x100 : Int) -> Severity {
  if index_x100 >= 120 {
    Critical
  } else if index_x100 >= 100 {
    High
  } else if index_x100 >= 90 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_shock_index(input : ShockIndexInput) -> ScoreReport {
  let score = shock_index_x100(input)
  report(
    "Shock Index x100",
    score,
    shock_index_severity(score),
    "Shock Index is a screening ratio; verify the underlying measurements and context.",
    [
      explanation(
        "Heart rate / systolic BP", score, "Ratio multiplied by 100 to preserve integer arithmetic",
      ),
    ],
  )
}

///|
pub(all) struct RoxInput {
  oxygen_saturation : Int
  fio2_percent : Int
  respiratory_rate : Int
} derive(Debug, Eq)

///|
pub fn validate_rox(input : RoxInput) -> ValidationError? {
  match validate_range("oxygen_saturation", input.oxygen_saturation, 0, 100) {
    Some(err) => Some(err)
    None =>
      match validate_range("fio2_percent", input.fio2_percent, 1, 100) {
        Some(err) => Some(err)
        None =>
          validate_range("respiratory_rate", input.respiratory_rate, 1, 100)
      }
  }
}

///|
pub fn rox_x100(input : RoxInput) -> Int {
  input.oxygen_saturation * 10000 / input.fio2_percent / input.respiratory_rate
}

///|
pub fn rox_severity(index_x100 : Int) -> Severity {
  if index_x100 < 200 {
    Critical
  } else if index_x100 < 300 {
    High
  } else if index_x100 < 450 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_rox(input : RoxInput) -> ScoreReport {
  let score = rox_x100(input)
  report(
    "ROX Index x100",
    score,
    rox_severity(score),
    "ROX Index is a respiratory-support trend measure and is not a stand-alone escalation decision.",
    [
      explanation(
        "SpO2 / FiO2 / respiratory rate", score, "Ratio multiplied by 100 for deterministic integer output",
      ),
    ],
  )
}
