///|
pub(all) struct BisapInput {
  bun_mmol_l_tenths : Int
  impaired_mentation : Bool
  sirs_criteria : Int
  age : Int
  pleural_effusion : Bool
} derive(Debug, Eq)

///|
pub fn validate_bisap(input : BisapInput) -> ValidationError? {
  match validate_range("bun_mmol_l_tenths", input.bun_mmol_l_tenths, 0, 1000) {
    Some(err) => Some(err)
    None =>
      match validate_range("sirs_criteria", input.sirs_criteria, 0, 4) {
        Some(err) => Some(err)
        None => validate_range("age", input.age, 0, 150)
      }
  }
}

///|
pub fn bisap_bun_points(value : Int) -> Int {
  if value >= 80 {
    1
  } else {
    0
  }
}

///|
pub fn bisap_mentation_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn bisap_sirs_points(value : Int) -> Int {
  if value >= 2 {
    1
  } else {
    0
  }
}

///|
pub fn bisap_age_points(value : Int) -> Int {
  if value > 60 {
    1
  } else {
    0
  }
}

///|
pub fn bisap_effusion_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn bisap_score(input : BisapInput) -> Int {
  bisap_bun_points(input.bun_mmol_l_tenths) +
  bisap_mentation_points(input.impaired_mentation) +
  bisap_sirs_points(input.sirs_criteria) +
  bisap_age_points(input.age) +
  bisap_effusion_points(input.pleural_effusion)
}

///|
pub fn bisap_severity(score : Int) -> Severity {
  if score >= 3 {
    Critical
  } else if score >= 2 {
    High
  } else if score >= 1 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_bisap(input : BisapInput) -> ScoreReport {
  let score = bisap_score(input)
  report(
    "BISAP",
    score,
    bisap_severity(score),
    "BISAP estimates severity of acute pancreatitis from five admission variables.",
    [
      explanation(
        "BUN",
        bisap_bun_points(input.bun_mmol_l_tenths),
        "BUN threshold",
      ),
      explanation(
        "Mental status",
        bisap_mentation_points(input.impaired_mentation),
        "Impaired mental status",
      ),
      explanation(
        "SIRS",
        bisap_sirs_points(input.sirs_criteria),
        "SIRS threshold",
      ),
      explanation("Age", bisap_age_points(input.age), "Age threshold"),
      explanation(
        "Pleural effusion",
        bisap_effusion_points(input.pleural_effusion),
        "Pleural effusion",
      ),
    ],
  )
}

///|
pub(all) struct RansonInput {
  age : Int
  wbc_tenths : Int
  glucose_mg_dl : Int
  ldh_units : Int
  ast_units : Int
  hematocrit_drop_tenths : Int
  bun_rise_mg_dl : Int
  calcium_mg_dl_tenths : Int
  arterial_oxygen_mmhg : Int
  base_deficit : Int
  fluid_sequestration_liters : Int
} derive(Debug, Eq)

///|
pub fn validate_ranson(input : RansonInput) -> ValidationError? {
  match validate_range("age", input.age, 0, 150) {
    Some(err) => Some(err)
    None =>
      match validate_range("wbc_tenths", input.wbc_tenths, 0, 1000) {
        Some(err) => Some(err)
        None =>
          match validate_range("glucose_mg_dl", input.glucose_mg_dl, 0, 1000) {
            Some(err) => Some(err)
            None =>
              match validate_range("ldh_units", input.ldh_units, 0, 5000) {
                Some(err) => Some(err)
                None =>
                  match validate_range("ast_units", input.ast_units, 0, 5000) {
                    Some(err) => Some(err)
                    None =>
                      match
                        validate_range(
                          "hematocrit_drop_tenths",
                          input.hematocrit_drop_tenths,
                          0,
                          500,
                        ) {
                        Some(err) => Some(err)
                        None =>
                          validate_range(
                            "bun_rise_mg_dl",
                            input.bun_rise_mg_dl,
                            0,
                            200,
                          )
                      }
                  }
              }
          }
      }
  }
}

///|
pub fn ranson_admission_score(input : RansonInput) -> Int {
  let age = if input.age > 55 { 1 } else { 0 }
  let wbc = if input.wbc_tenths > 160 { 1 } else { 0 }
  let glucose = if input.glucose_mg_dl > 200 { 1 } else { 0 }
  let ldh = if input.ldh_units > 350 { 1 } else { 0 }
  let ast = if input.ast_units > 250 { 1 } else { 0 }
  age + wbc + glucose + ldh + ast
}

///|
pub fn ranson_48_hour_score(input : RansonInput) -> Int {
  let hematocrit = if input.hematocrit_drop_tenths > 100 { 1 } else { 0 }
  let bun = if input.bun_rise_mg_dl > 5 { 1 } else { 0 }
  let calcium = if input.calcium_mg_dl_tenths < 80 { 1 } else { 0 }
  let oxygen = if input.arterial_oxygen_mmhg < 60 { 1 } else { 0 }
  let base = if input.base_deficit > 4 { 1 } else { 0 }
  let fluid = if input.fluid_sequestration_liters > 6 { 1 } else { 0 }
  hematocrit + bun + calcium + oxygen + base + fluid
}

///|
pub fn ranson_score(input : RansonInput) -> Int {
  ranson_admission_score(input) + ranson_48_hour_score(input)
}

///|
pub fn ranson_severity(score : Int) -> Severity {
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
pub fn score_ranson(input : RansonInput) -> ScoreReport {
  let admission = ranson_admission_score(input)
  let follow_up = ranson_48_hour_score(input)
  let score = admission + follow_up
  report(
    "Ranson",
    score,
    ranson_severity(score),
    "Ranson criteria separate admission and 48-hour acute pancreatitis variables; the timing of data collection is essential.",
    [
      explanation("Admission", admission, "Admission criteria"),
      explanation("48-hour", follow_up, "48-hour criteria"),
    ],
  )
}

///|
pub(all) struct AlvaradoInput {
  migration_of_pain : Bool
  anorexia : Bool
  nausea_or_vomiting : Bool
  right_lower_quadrant_tenderness : Bool
  rebound_tenderness : Bool
  fever_tenths_c : Int
  leukocytosis : Bool
  left_shift : Bool
} derive(Debug, Eq)

///|
pub fn validate_alvarado(input : AlvaradoInput) -> ValidationError? {
  validate_range("fever_tenths_c", input.fever_tenths_c, 250, 450)
}

///|
pub fn alvarado_score(input : AlvaradoInput) -> Int {
  let migration = if input.migration_of_pain { 1 } else { 0 }
  let anorexia = if input.anorexia { 1 } else { 0 }
  let nausea = if input.nausea_or_vomiting { 1 } else { 0 }
  let tenderness = if input.right_lower_quadrant_tenderness { 2 } else { 0 }
  let rebound = if input.rebound_tenderness { 1 } else { 0 }
  let fever = if input.fever_tenths_c >= 377 { 1 } else { 0 }
  let white_cells = if input.leukocytosis { 2 } else { 0 }
  let shift = if input.left_shift { 1 } else { 0 }
  migration +
  anorexia +
  nausea +
  tenderness +
  rebound +
  fever +
  white_cells +
  shift
}

///|
pub fn alvarado_severity(score : Int) -> Severity {
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
pub fn score_alvarado(input : AlvaradoInput) -> ScoreReport {
  let score = alvarado_score(input)
  report(
    "Alvarado",
    score,
    alvarado_severity(score),
    "The Alvarado score organizes symptoms, signs, and laboratory findings in suspected appendicitis.",
    [
      explanation(
        "Migration",
        if input.migration_of_pain {
          1
        } else {
          0
        },
        "Migration of pain",
      ),
      explanation("Anorexia", if input.anorexia { 1 } else { 0 }, "Anorexia"),
      explanation(
        "Nausea",
        if input.nausea_or_vomiting {
          1
        } else {
          0
        },
        "Nausea or vomiting",
      ),
      explanation(
        "RLQ tenderness",
        if input.right_lower_quadrant_tenderness {
          2
        } else {
          0
        },
        "Right lower quadrant tenderness",
      ),
      explanation(
        "Rebound",
        if input.rebound_tenderness {
          1
        } else {
          0
        },
        "Rebound tenderness",
      ),
      explanation(
        "Fever",
        if input.fever_tenths_c >= 377 {
          1
        } else {
          0
        },
        "Fever threshold",
      ),
      explanation(
        "Leukocytosis",
        if input.leukocytosis {
          2
        } else {
          0
        },
        "Leukocytosis",
      ),
      explanation(
        "Left shift",
        if input.left_shift {
          1
        } else {
          0
        },
        "Neutrophil left shift",
      ),
    ],
  )
}
