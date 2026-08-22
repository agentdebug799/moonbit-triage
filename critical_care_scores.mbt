///|
pub(all) struct ApacheIiInput {
  temperature_tenths_c : Int
  mean_arterial_pressure : Int
  heart_rate : Int
  respiratory_rate : Int
  oxygenation_value : Int
  high_fio2 : Bool
  arterial_ph_hundredths : Int
  sodium : Int
  potassium_tenths : Int
  creatinine_hundredths : Int
  acute_renal_failure : Bool
  hematocrit_tenths : Int
  white_cell_count_tenths : Int
  gcs : Int
  age : Int
  chronic_health : Bool
} derive(Debug, Eq)

///|
pub fn validate_apache_ii(input : ApacheIiInput) -> ValidationError? {
  match
    validate_range("temperature_tenths_c", input.temperature_tenths_c, 250, 450) {
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
          match validate_range("heart_rate", input.heart_rate, 0, 300) {
            Some(err) => Some(err)
            None =>
              match
                validate_range(
                  "respiratory_rate",
                  input.respiratory_rate,
                  0,
                  100,
                ) {
                Some(err) => Some(err)
                None =>
                  match
                    validate_range(
                      "oxygenation_value",
                      input.oxygenation_value,
                      0,
                      1000,
                    ) {
                    Some(err) => Some(err)
                    None =>
                      match
                        validate_range(
                          "arterial_ph_hundredths",
                          input.arterial_ph_hundredths,
                          650,
                          800,
                        ) {
                        Some(err) => Some(err)
                        None =>
                          match
                            validate_range("sodium", input.sodium, 80, 250) {
                            Some(err) => Some(err)
                            None =>
                              match
                                validate_range(
                                  "potassium_tenths",
                                  input.potassium_tenths,
                                  10,
                                  100,
                                ) {
                                Some(err) => Some(err)
                                None =>
                                  match
                                    validate_range(
                                      "creatinine_hundredths",
                                      input.creatinine_hundredths,
                                      1,
                                      2000,
                                    ) {
                                    Some(err) => Some(err)
                                    None =>
                                      match
                                        validate_range(
                                          "hematocrit_tenths",
                                          input.hematocrit_tenths,
                                          50,
                                          800,
                                        ) {
                                        Some(err) => Some(err)
                                        None =>
                                          match
                                            validate_range(
                                              "white_cell_count_tenths",
                                              input.white_cell_count_tenths,
                                              1,
                                              1000,
                                            ) {
                                            Some(err) => Some(err)
                                            None =>
                                              match
                                                validate_range(
                                                  "gcs",
                                                  input.gcs,
                                                  3,
                                                  15,
                                                ) {
                                                Some(err) => Some(err)
                                                None =>
                                                  validate_range(
                                                    "age",
                                                    input.age,
                                                    0,
                                                    150,
                                                  )
                                              }
                                          }
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }
      }
  }
}

///|
pub fn apache_temp_points(value : Int) -> Int {
  if value >= 410 {
    4
  } else if value >= 390 {
    3
  } else if value >= 380 {
    1
  } else if value >= 360 {
    0
  } else if value >= 340 {
    1
  } else if value >= 320 {
    2
  } else {
    4
  }
}

///|
pub fn apache_map_points(value : Int) -> Int {
  if value >= 160 {
    4
  } else if value >= 130 {
    3
  } else if value >= 110 {
    2
  } else if value >= 70 {
    0
  } else if value >= 50 {
    2
  } else {
    4
  }
}

///|
pub fn apache_heart_rate_points(value : Int) -> Int {
  if value >= 180 {
    4
  } else if value >= 140 {
    3
  } else if value >= 110 {
    2
  } else if value >= 70 {
    0
  } else if value >= 55 {
    2
  } else if value >= 40 {
    3
  } else {
    4
  }
}

///|
pub fn apache_respiratory_rate_points(value : Int) -> Int {
  if value >= 50 {
    4
  } else if value >= 35 {
    3
  } else if value >= 25 {
    1
  } else if value >= 12 {
    0
  } else if value >= 10 {
    1
  } else if value >= 6 {
    2
  } else {
    4
  }
}

///|
pub fn apache_oxygenation_points(value : Int, high_fio2 : Bool) -> Int {
  if high_fio2 {
    if value >= 500 {
      3
    } else if value >= 350 {
      1
    } else if value >= 200 {
      2
    } else {
      3
    }
  } else if value >= 70 {
    0
  } else if value >= 61 {
    1
  } else if value >= 55 {
    3
  } else {
    4
  }
}

///|
pub fn apache_ph_points(value : Int) -> Int {
  if value >= 760 {
    4
  } else if value >= 750 {
    1
  } else if value >= 733 {
    0
  } else if value >= 725 {
    2
  } else {
    4
  }
}

///|
pub fn apache_sodium_points(value : Int) -> Int {
  if value >= 180 {
    4
  } else if value >= 160 {
    3
  } else if value >= 155 {
    1
  } else if value >= 130 {
    0
  } else if value >= 120 {
    2
  } else {
    4
  }
}

///|
pub fn apache_potassium_points(value : Int) -> Int {
  if value >= 7 {
    4
  } else if value >= 6 {
    3
  } else if value >= 55 {
    1
  } else if value >= 35 {
    0
  } else if value >= 3 {
    1
  } else {
    4
  }
}

///|
pub fn apache_creatinine_points(value : Int) -> Int {
  if value >= 350 {
    4
  } else if value >= 200 {
    3
  } else if value >= 150 {
    2
  } else if value >= 60 {
    0
  } else if value >= 30 {
    2
  } else {
    3
  }
}

///|
pub fn apache_hematocrit_points(value : Int) -> Int {
  if value >= 600 {
    4
  } else if value >= 500 {
    2
  } else if value >= 460 {
    1
  } else if value >= 300 {
    0
  } else if value >= 200 {
    2
  } else {
    4
  }
}

///|
pub fn apache_white_cell_points(value : Int) -> Int {
  if value >= 400 {
    4
  } else if value >= 200 {
    1
  } else if value >= 150 {
    0
  } else if value >= 30 {
    1
  } else {
    4
  }
}

///|
pub fn apache_age_points(value : Int) -> Int {
  if value < 45 {
    0
  } else if value < 55 {
    2
  } else if value < 65 {
    3
  } else if value < 75 {
    5
  } else {
    6
  }
}

///|
pub fn apache_chronic_points(value : Bool) -> Int {
  if value {
    5
  } else {
    0
  }
}

///|
pub fn apache_ii_score(input : ApacheIiInput) -> Int {
  let creatinine_multiplier = if input.acute_renal_failure { 2 } else { 1 }
  apache_temp_points(input.temperature_tenths_c) +
  apache_map_points(input.mean_arterial_pressure) +
  apache_heart_rate_points(input.heart_rate) +
  apache_respiratory_rate_points(input.respiratory_rate) +
  apache_oxygenation_points(input.oxygenation_value, input.high_fio2) +
  apache_ph_points(input.arterial_ph_hundredths) +
  apache_sodium_points(input.sodium) +
  apache_potassium_points(input.potassium_tenths) +
  apache_creatinine_points(input.creatinine_hundredths) * creatinine_multiplier +
  apache_hematocrit_points(input.hematocrit_tenths) +
  apache_white_cell_points(input.white_cell_count_tenths) +
  (15 - input.gcs) +
  apache_age_points(input.age) +
  apache_chronic_points(input.chronic_health)
}

///|
pub fn apache_ii_severity(score : Int) -> Severity {
  if score >= 25 {
    Critical
  } else if score >= 15 {
    High
  } else if score >= 5 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_apache_ii(input : ApacheIiInput) -> ScoreReport {
  let score = apache_ii_score(input)
  let creatinine_multiplier = if input.acute_renal_failure { 2 } else { 1 }
  report(
    "APACHE II",
    score,
    apache_ii_severity(score),
    "APACHE II summarizes acute physiology, age, and chronic health status for ICU risk stratification.",
    [
      explanation(
        "Temperature",
        apache_temp_points(input.temperature_tenths_c),
        "Temperature points",
      ),
      explanation(
        "Mean pressure",
        apache_map_points(input.mean_arterial_pressure),
        "Mean arterial pressure points",
      ),
      explanation(
        "Heart rate",
        apache_heart_rate_points(input.heart_rate),
        "Heart-rate points",
      ),
      explanation(
        "Respiration",
        apache_respiratory_rate_points(input.respiratory_rate),
        "Respiratory-rate points",
      ),
      explanation(
        "Oxygenation",
        apache_oxygenation_points(input.oxygenation_value, input.high_fio2),
        "Oxygenation points",
      ),
      explanation(
        "Acid-base",
        apache_ph_points(input.arterial_ph_hundredths),
        "Arterial pH points",
      ),
      explanation(
        "Sodium",
        apache_sodium_points(input.sodium),
        "Serum sodium points",
      ),
      explanation(
        "Potassium",
        apache_potassium_points(input.potassium_tenths),
        "Serum potassium points",
      ),
      explanation(
        "Creatinine",
        apache_creatinine_points(input.creatinine_hundredths) *
        creatinine_multiplier,
        "Creatinine points, doubled for acute renal failure",
      ),
      explanation(
        "Hematocrit",
        apache_hematocrit_points(input.hematocrit_tenths),
        "Hematocrit points",
      ),
      explanation(
        "White cells",
        apache_white_cell_points(input.white_cell_count_tenths),
        "White-cell points",
      ),
      explanation("GCS", 15 - input.gcs, "Glasgow Coma Scale conversion"),
      explanation("Age", apache_age_points(input.age), "Age points"),
      explanation(
        "Chronic health",
        apache_chronic_points(input.chronic_health),
        "Chronic health points",
      ),
    ],
  )
}

///|
pub(all) struct SmartCopInput {
  systolic_bp : Int
  multilobar_infiltrates : Bool
  albumin_tenths_g_dl : Int
  respiratory_rate : Int
  age : Int
  confusion : Bool
  oxygen_saturation : Int
  arterial_ph_hundredths : Int
} derive(Debug, Eq)

///|
pub fn validate_smart_cop(input : SmartCopInput) -> ValidationError? {
  match validate_range("systolic_bp", input.systolic_bp, 0, 300) {
    Some(err) => Some(err)
    None =>
      match
        validate_range("albumin_tenths_g_dl", input.albumin_tenths_g_dl, 0, 100) {
        Some(err) => Some(err)
        None =>
          match
            validate_range("respiratory_rate", input.respiratory_rate, 0, 100) {
            Some(err) => Some(err)
            None =>
              match validate_range("age", input.age, 0, 150) {
                Some(err) => Some(err)
                None =>
                  match
                    validate_range(
                      "oxygen_saturation",
                      input.oxygen_saturation,
                      0,
                      100,
                    ) {
                    Some(err) => Some(err)
                    None =>
                      validate_range(
                        "arterial_ph_hundredths",
                        input.arterial_ph_hundredths,
                        650,
                        800,
                      )
                  }
              }
          }
      }
  }
}

///|
pub fn smart_cop_pressure_points(value : Int) -> Int {
  if value < 90 {
    2
  } else {
    0
  }
}

///|
pub fn smart_cop_infiltrate_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn smart_cop_albumin_points(value : Int) -> Int {
  if value < 35 {
    1
  } else {
    0
  }
}

///|
pub fn smart_cop_respiration_points(value : Int, age : Int) -> Int {
  if (age < 50 && value >= 30) || (age >= 50 && value >= 25) {
    1
  } else {
    0
  }
}

///|
pub fn smart_cop_age_points(value : Int) -> Int {
  if value >= 50 {
    1
  } else {
    0
  }
}

///|
pub fn smart_cop_confusion_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn smart_cop_oxygen_points(value : Int) -> Int {
  if value < 90 {
    2
  } else {
    0
  }
}

///|
pub fn smart_cop_ph_points(value : Int) -> Int {
  if value < 735 {
    2
  } else {
    0
  }
}

///|
pub fn smart_cop_score(input : SmartCopInput) -> Int {
  smart_cop_pressure_points(input.systolic_bp) +
  smart_cop_infiltrate_points(input.multilobar_infiltrates) +
  smart_cop_albumin_points(input.albumin_tenths_g_dl) +
  smart_cop_respiration_points(input.respiratory_rate, input.age) +
  smart_cop_age_points(input.age) +
  smart_cop_confusion_points(input.confusion) +
  smart_cop_oxygen_points(input.oxygen_saturation) +
  smart_cop_ph_points(input.arterial_ph_hundredths)
}

///|
pub fn smart_cop_severity(score : Int) -> Severity {
  if score >= 5 {
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
pub fn score_smart_cop(input : SmartCopInput) -> ScoreReport {
  let score = smart_cop_score(input)
  report(
    "SMART-COP",
    score,
    smart_cop_severity(score),
    "SMART-COP identifies pneumonia patients at risk of intensive respiratory or vasopressor support.",
    [
      explanation(
        "Pressure",
        smart_cop_pressure_points(input.systolic_bp),
        "Systolic pressure",
      ),
      explanation(
        "Infiltrates",
        smart_cop_infiltrate_points(input.multilobar_infiltrates),
        "Multilobar infiltrates",
      ),
      explanation(
        "Albumin",
        smart_cop_albumin_points(input.albumin_tenths_g_dl),
        "Albumin below threshold",
      ),
      explanation(
        "Respiration",
        smart_cop_respiration_points(input.respiratory_rate, input.age),
        "Age-adjusted respiratory rate",
      ),
      explanation("Age", smart_cop_age_points(input.age), "Age at least 50"),
      explanation(
        "Confusion",
        smart_cop_confusion_points(input.confusion),
        "Confusion present",
      ),
      explanation(
        "Oxygen",
        smart_cop_oxygen_points(input.oxygen_saturation),
        "Oxygen saturation",
      ),
      explanation(
        "pH",
        smart_cop_ph_points(input.arterial_ph_hundredths),
        "Arterial pH",
      ),
    ],
  )
}
