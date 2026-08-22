///|
pub(all) struct PediatricAppendicitisInput {
  migration_of_pain : Bool
  anorexia : Bool
  nausea_or_vomiting : Bool
  right_lower_quadrant_tenderness : Bool
  cough_hopping_percussion_pain : Bool
  fever_tenths_c : Int
  leukocytosis : Bool
  neutrophilia : Bool
} derive(Debug, Eq)

///|
pub fn validate_pediatric_appendicitis(
  input : PediatricAppendicitisInput,
) -> ValidationError? {
  validate_range("fever_tenths_c", input.fever_tenths_c, 250, 450)
}

///|
pub fn pediatric_appendicitis_migration_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn pediatric_appendicitis_anorexia_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn pediatric_appendicitis_nausea_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn pediatric_appendicitis_tenderness_points(value : Bool) -> Int {
  if value {
    2
  } else {
    0
  }
}

///|
pub fn pediatric_appendicitis_cough_points(value : Bool) -> Int {
  if value {
    2
  } else {
    0
  }
}

///|
pub fn pediatric_appendicitis_fever_points(value : Int) -> Int {
  if value >= 380 {
    1
  } else {
    0
  }
}

///|
pub fn pediatric_appendicitis_lab_points(
  leukocytosis : Bool,
  neutrophilia : Bool,
) -> Int {
  let white_cells = if leukocytosis { 1 } else { 0 }
  let neutrophils = if neutrophilia { 1 } else { 0 }
  white_cells + neutrophils
}

///|
pub fn pediatric_appendicitis_score(input : PediatricAppendicitisInput) -> Int {
  pediatric_appendicitis_migration_points(input.migration_of_pain) +
  pediatric_appendicitis_anorexia_points(input.anorexia) +
  pediatric_appendicitis_nausea_points(input.nausea_or_vomiting) +
  pediatric_appendicitis_tenderness_points(
    input.right_lower_quadrant_tenderness,
  ) +
  pediatric_appendicitis_cough_points(input.cough_hopping_percussion_pain) +
  pediatric_appendicitis_fever_points(input.fever_tenths_c) +
  pediatric_appendicitis_lab_points(input.leukocytosis, input.neutrophilia)
}

///|
pub fn pediatric_appendicitis_severity(score : Int) -> Severity {
  if score >= 7 {
    High
  } else if score >= 4 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_pediatric_appendicitis(
  input : PediatricAppendicitisInput,
) -> ScoreReport {
  let score = pediatric_appendicitis_score(input)
  report(
    "Pediatric Appendicitis",
    score,
    pediatric_appendicitis_severity(score),
    "This pediatric appendicitis score organizes symptoms, examination, fever, and inflammatory findings for serial assessment.",
    [
      explanation(
        "Migration",
        pediatric_appendicitis_migration_points(input.migration_of_pain),
        "Migration of pain",
      ),
      explanation(
        "Anorexia",
        pediatric_appendicitis_anorexia_points(input.anorexia),
        "Anorexia",
      ),
      explanation(
        "Nausea",
        pediatric_appendicitis_nausea_points(input.nausea_or_vomiting),
        "Nausea or vomiting",
      ),
      explanation(
        "Tenderness",
        pediatric_appendicitis_tenderness_points(
          input.right_lower_quadrant_tenderness,
        ),
        "Right lower quadrant tenderness",
      ),
      explanation(
        "Cough or movement",
        pediatric_appendicitis_cough_points(input.cough_hopping_percussion_pain),
        "Pain with cough, hopping, or percussion",
      ),
      explanation(
        "Fever",
        pediatric_appendicitis_fever_points(input.fever_tenths_c),
        "Fever threshold",
      ),
      explanation(
        "Laboratory",
        pediatric_appendicitis_lab_points(
          input.leukocytosis,
          input.neutrophilia,
        ),
        "Leukocytosis and neutrophilia",
      ),
    ],
  )
}

///|
pub(all) struct BishopInput {
  dilation_cm : Int
  effacement_percent : Int
  fetal_station : Int
  cervical_consistency : Int
  cervical_position : Int
} derive(Debug, Eq)

///|
pub fn validate_bishop(input : BishopInput) -> ValidationError? {
  match validate_range("dilation_cm", input.dilation_cm, 0, 10) {
    Some(err) => Some(err)
    None =>
      match
        validate_range("effacement_percent", input.effacement_percent, 0, 100) {
        Some(err) => Some(err)
        None =>
          match validate_range("fetal_station", input.fetal_station, -3, 3) {
            Some(err) => Some(err)
            None =>
              match
                validate_range(
                  "cervical_consistency",
                  input.cervical_consistency,
                  0,
                  2,
                ) {
                Some(err) => Some(err)
                None =>
                  validate_range(
                    "cervical_position",
                    input.cervical_position,
                    0,
                    2,
                  )
              }
          }
      }
  }
}

///|
pub fn bishop_dilation_points(value : Int) -> Int {
  if value == 0 {
    0
  } else if value <= 2 {
    1
  } else if value <= 4 {
    2
  } else if value <= 7 {
    3
  } else {
    4
  }
}

///|
pub fn bishop_effacement_points(value : Int) -> Int {
  if value < 40 {
    0
  } else if value < 60 {
    1
  } else if value < 80 {
    2
  } else {
    3
  }
}

///|
pub fn bishop_station_points(value : Int) -> Int {
  if value <= -3 {
    0
  } else if value <= -1 {
    1
  } else if value == 0 {
    2
  } else if value == 1 {
    3
  } else {
    4
  }
}

///|
pub fn bishop_consistency_points(value : Int) -> Int {
  if value <= 0 {
    0
  } else if value == 1 {
    1
  } else {
    2
  }
}

///|
pub fn bishop_position_points(value : Int) -> Int {
  if value <= 0 {
    0
  } else if value == 1 {
    1
  } else {
    2
  }
}

///|
pub fn bishop_score(input : BishopInput) -> Int {
  bishop_dilation_points(input.dilation_cm) +
  bishop_effacement_points(input.effacement_percent) +
  bishop_station_points(input.fetal_station) +
  bishop_consistency_points(input.cervical_consistency) +
  bishop_position_points(input.cervical_position)
}

///|
pub fn bishop_severity(score : Int) -> Severity {
  if score >= 8 {
    High
  } else if score >= 6 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_bishop(input : BishopInput) -> ScoreReport {
  let dilation = bishop_dilation_points(input.dilation_cm)
  let effacement = bishop_effacement_points(input.effacement_percent)
  let station = bishop_station_points(input.fetal_station)
  let consistency = bishop_consistency_points(input.cervical_consistency)
  let position = bishop_position_points(input.cervical_position)
  let score = dilation + effacement + station + consistency + position
  report(
    "Bishop",
    score,
    bishop_severity(score),
    "The Bishop score summarizes cervical favorability using dilation, effacement, station, consistency, and position.",
    [
      explanation("Dilation", dilation, "Cervical dilation"),
      explanation("Effacement", effacement, "Cervical effacement"),
      explanation("Station", station, "Fetal station"),
      explanation("Consistency", consistency, "Cervical consistency"),
      explanation("Position", position, "Cervical position"),
    ],
  )
}

///|
pub(all) struct PreeclampsiaInput {
  systolic_bp : Int
  diastolic_bp : Int
  platelets_thousands : Int
  creatinine_hundredths_mg_dl : Int
  ast_units : Int
  alt_units : Int
  pulmonary_edema : Bool
  persistent_headache : Bool
  visual_symptoms : Bool
  right_upper_quadrant_pain : Bool
  fetal_growth_restriction : Bool
} derive(Debug, Eq)

///|
pub fn validate_preeclampsia(input : PreeclampsiaInput) -> ValidationError? {
  match validate_range("systolic_bp", input.systolic_bp, 0, 300) {
    Some(err) => Some(err)
    None =>
      match validate_range("diastolic_bp", input.diastolic_bp, 0, 200) {
        Some(err) => Some(err)
        None =>
          match
            validate_range(
              "platelets_thousands",
              input.platelets_thousands,
              0,
              1000,
            ) {
            Some(err) => Some(err)
            None =>
              validate_range(
                "creatinine_hundredths_mg_dl",
                input.creatinine_hundredths_mg_dl,
                0,
                1000,
              )
          }
      }
  }
}

///|
pub fn preeclampsia_pressure_points(systolic : Int, diastolic : Int) -> Int {
  if systolic >= 160 || diastolic >= 110 {
    2
  } else if systolic >= 140 || diastolic >= 90 {
    1
  } else {
    0
  }
}

///|
pub fn preeclampsia_platelet_points(value : Int) -> Int {
  if value < 100 {
    2
  } else {
    0
  }
}

///|
pub fn preeclampsia_renal_points(value : Int) -> Int {
  if value >= 110 {
    2
  } else {
    0
  }
}

///|
pub fn preeclampsia_liver_points(ast : Int, alt : Int, pain : Bool) -> Int {
  let enzyme = if ast >= 140 || alt >= 140 { 1 } else { 0 }
  let symptom = if pain { 1 } else { 0 }
  enzyme + symptom
}

///|
pub fn preeclampsia_neurologic_points(headache : Bool, visual : Bool) -> Int {
  let headache_points = if headache { 1 } else { 0 }
  let visual_points = if visual { 1 } else { 0 }
  headache_points + visual_points
}

///|
pub fn preeclampsia_other_points(edema : Bool, growth : Bool) -> Int {
  let pulmonary = if edema { 2 } else { 0 }
  let fetus = if growth { 1 } else { 0 }
  pulmonary + fetus
}

///|
pub fn preeclampsia_score(input : PreeclampsiaInput) -> Int {
  preeclampsia_pressure_points(input.systolic_bp, input.diastolic_bp) +
  preeclampsia_platelet_points(input.platelets_thousands) +
  preeclampsia_renal_points(input.creatinine_hundredths_mg_dl) +
  preeclampsia_liver_points(
    input.ast_units,
    input.alt_units,
    input.right_upper_quadrant_pain,
  ) +
  preeclampsia_neurologic_points(
    input.persistent_headache,
    input.visual_symptoms,
  ) +
  preeclampsia_other_points(
    input.pulmonary_edema,
    input.fetal_growth_restriction,
  )
}

///|
pub fn preeclampsia_severity(score : Int) -> Severity {
  if score >= 4 {
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
pub fn score_preeclampsia(input : PreeclampsiaInput) -> ScoreReport {
  let pressure = preeclampsia_pressure_points(
    input.systolic_bp,
    input.diastolic_bp,
  )
  let platelets = preeclampsia_platelet_points(input.platelets_thousands)
  let renal = preeclampsia_renal_points(input.creatinine_hundredths_mg_dl)
  let liver = preeclampsia_liver_points(
    input.ast_units,
    input.alt_units,
    input.right_upper_quadrant_pain,
  )
  let neurologic = preeclampsia_neurologic_points(
    input.persistent_headache,
    input.visual_symptoms,
  )
  let other = preeclampsia_other_points(
    input.pulmonary_edema,
    input.fetal_growth_restriction,
  )
  let score = pressure + platelets + renal + liver + neurologic + other
  report(
    "Preeclampsia Features",
    score,
    preeclampsia_severity(score),
    "This checklist makes severe-feature domains explicit for obstetric escalation pathways and is not a diagnosis.",
    [
      explanation("Blood pressure", pressure, "Blood pressure category"),
      explanation("Platelets", platelets, "Platelet category"),
      explanation("Renal", renal, "Creatinine category"),
      explanation("Liver", liver, "Liver enzyme or right-upper-quadrant domain"),
      explanation("Neurologic", neurologic, "Headache or visual symptoms"),
      explanation("Other", other, "Pulmonary edema or fetal growth restriction"),
    ],
  )
}
