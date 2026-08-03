///|
pub(all) enum Spo2Scale {
  Scale1
  Scale2
} derive(Debug, Eq)

///|
pub(all) enum Consciousness {
  Alert
  NewConfusion
  Voice
  Pain
  Unresponsive
} derive(Debug, Eq)

///|
pub(all) struct News2Input {
  respiratory_rate : Int
  oxygen_saturation : Int
  spo2_scale : Spo2Scale
  supplemental_oxygen : Bool
  temperature_tenths_c : Int
  systolic_bp : Int
  heart_rate : Int
  consciousness : Consciousness
} derive(Debug, Eq)

///|
pub fn validate_news2(input : News2Input) -> ValidationError? {
  match validate_range("respiratory_rate", input.respiratory_rate, 0, 80) {
    Some(err) => Some(err)
    None =>
      match
        validate_range("oxygen_saturation", input.oxygen_saturation, 0, 100) {
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
              match validate_range("systolic_bp", input.systolic_bp, 40, 300) {
                Some(err) => Some(err)
                None => validate_range("heart_rate", input.heart_rate, 0, 250)
              }
          }
      }
  }
}

///|
pub fn news2_respiratory_rate_points(rate : Int) -> Int {
  if rate <= 8 {
    3
  } else if rate <= 11 {
    1
  } else if rate <= 20 {
    0
  } else if rate <= 24 {
    2
  } else {
    3
  }
}

///|
pub fn news2_oxygen_saturation_points(
  saturation : Int,
  scale : Spo2Scale,
  supplemental_oxygen : Bool,
) -> Int {
  match scale {
    Scale1 =>
      if saturation <= 91 {
        3
      } else if saturation <= 93 {
        2
      } else if saturation <= 95 {
        1
      } else {
        0
      }
    Scale2 =>
      if saturation <= 83 {
        3
      } else if saturation <= 85 {
        2
      } else if saturation <= 87 {
        1
      } else if saturation <= 92 {
        0
      } else if !supplemental_oxygen {
        0
      } else if saturation <= 94 {
        1
      } else if saturation <= 96 {
        2
      } else {
        3
      }
  }
}

///|
pub fn news2_supplemental_oxygen_points(supplemental_oxygen : Bool) -> Int {
  if supplemental_oxygen {
    2
  } else {
    0
  }
}

///|
pub fn news2_temperature_points(temperature_tenths_c : Int) -> Int {
  if temperature_tenths_c <= 350 {
    3
  } else if temperature_tenths_c <= 360 {
    1
  } else if temperature_tenths_c <= 380 {
    0
  } else if temperature_tenths_c <= 390 {
    1
  } else {
    2
  }
}

///|
pub fn news2_systolic_bp_points(systolic_bp : Int) -> Int {
  if systolic_bp <= 90 {
    3
  } else if systolic_bp <= 100 {
    2
  } else if systolic_bp <= 110 {
    1
  } else if systolic_bp <= 219 {
    0
  } else {
    3
  }
}

///|
pub fn news2_heart_rate_points(heart_rate : Int) -> Int {
  if heart_rate <= 40 {
    3
  } else if heart_rate <= 50 {
    1
  } else if heart_rate <= 90 {
    0
  } else if heart_rate <= 110 {
    1
  } else if heart_rate <= 130 {
    2
  } else {
    3
  }
}

///|
pub fn news2_consciousness_points(consciousness : Consciousness) -> Int {
  match consciousness {
    Alert => 0
    NewConfusion | Voice | Pain | Unresponsive => 3
  }
}

///|
pub fn news2_severity(score : Int, any_single_three : Bool) -> Severity {
  if score >= 7 {
    Critical
  } else if score >= 5 || any_single_three {
    High
  } else if score >= 1 {
    Medium
  } else {
    Low
  }
}

///|
fn news2_interpretation(score : Int, any_single_three : Bool) -> String {
  if score >= 7 {
    "High aggregate NEWS2 score: urgent clinical review is commonly expected in local protocols."
  } else if score >= 5 {
    "Medium aggregate NEWS2 score: local escalation protocol should be reviewed."
  } else if any_single_three {
    "Low aggregate score with one severe parameter: local escalation protocol should still be reviewed."
  } else if score >= 1 {
    "Low aggregate score: continue observation according to local policy."
  } else {
    "All measured NEWS2 parameters scored zero."
  }
}

///|
pub fn score_news2(input : News2Input) -> ScoreReport {
  let rr = news2_respiratory_rate_points(input.respiratory_rate)
  let spo2 = news2_oxygen_saturation_points(
    input.oxygen_saturation,
    input.spo2_scale,
    input.supplemental_oxygen,
  )
  let oxygen = news2_supplemental_oxygen_points(input.supplemental_oxygen)
  let temp = news2_temperature_points(input.temperature_tenths_c)
  let bp = news2_systolic_bp_points(input.systolic_bp)
  let pulse = news2_heart_rate_points(input.heart_rate)
  let neuro = news2_consciousness_points(input.consciousness)
  let score = rr + spo2 + oxygen + temp + bp + pulse + neuro
  let any_single_three = rr == 3 ||
    spo2 == 3 ||
    temp == 3 ||
    bp == 3 ||
    pulse == 3 ||
    neuro == 3
  report(
    "NEWS2",
    score,
    news2_severity(score, any_single_three),
    news2_interpretation(score, any_single_three),
    [
      explanation("Respiratory rate", rr, "NEWS2 respiratory-rate band"),
      explanation("Oxygen saturation", spo2, "NEWS2 SpO2 scale band"),
      explanation("Supplemental oxygen", oxygen, "NEWS2 oxygen therapy add-on"),
      explanation("Temperature", temp, "NEWS2 temperature band in Celsius"),
      explanation("Systolic blood pressure", bp, "NEWS2 systolic BP band"),
      explanation("Heart rate", pulse, "NEWS2 pulse band"),
      explanation("Consciousness", neuro, "NEWS2 ACVPU band"),
    ],
  )
}
