///|
pub(all) struct NihssInput {
  consciousness : Int
  questions : Int
  commands : Int
  gaze : Int
  visual : Int
  facial : Int
  left_arm : Int
  right_arm : Int
  left_leg : Int
  right_leg : Int
  ataxia : Int
  sensory : Int
  language : Int
  dysarthria : Int
  neglect : Int
} derive(Debug, Eq)

///|
fn validate_nihss_field(
  field : String,
  value : Int,
  high : Int,
) -> ValidationError? {
  validate_range(field, value, 0, high)
}

///|
pub fn validate_nihss(input : NihssInput) -> ValidationError? {
  match validate_nihss_field("consciousness", input.consciousness, 3) {
    Some(err) => Some(err)
    None =>
      match validate_nihss_field("questions", input.questions, 2) {
        Some(err) => Some(err)
        None =>
          match validate_nihss_field("commands", input.commands, 2) {
            Some(err) => Some(err)
            None =>
              match validate_nihss_field("gaze", input.gaze, 2) {
                Some(err) => Some(err)
                None =>
                  match validate_nihss_field("visual", input.visual, 3) {
                    Some(err) => Some(err)
                    None =>
                      match validate_nihss_field("facial", input.facial, 3) {
                        Some(err) => Some(err)
                        None =>
                          match
                            validate_nihss_field("left_arm", input.left_arm, 4) {
                            Some(err) => Some(err)
                            None =>
                              match
                                validate_nihss_field(
                                  "right_arm",
                                  input.right_arm,
                                  4,
                                ) {
                                Some(err) => Some(err)
                                None =>
                                  match
                                    validate_nihss_field(
                                      "left_leg",
                                      input.left_leg,
                                      4,
                                    ) {
                                    Some(err) => Some(err)
                                    None =>
                                      match
                                        validate_nihss_field(
                                          "right_leg",
                                          input.right_leg,
                                          4,
                                        ) {
                                        Some(err) => Some(err)
                                        None =>
                                          match
                                            validate_nihss_field(
                                              "ataxia",
                                              input.ataxia,
                                              2,
                                            ) {
                                            Some(err) => Some(err)
                                            None =>
                                              match
                                                validate_nihss_field(
                                                  "sensory",
                                                  input.sensory,
                                                  2,
                                                ) {
                                                Some(err) => Some(err)
                                                None =>
                                                  match
                                                    validate_nihss_field(
                                                      "language",
                                                      input.language,
                                                      3,
                                                    ) {
                                                    Some(err) => Some(err)
                                                    None =>
                                                      match
                                                        validate_nihss_field(
                                                          "dysarthria",
                                                          input.dysarthria,
                                                          2,
                                                        ) {
                                                        Some(err) => Some(err)
                                                        None =>
                                                          validate_nihss_field(
                                                            "neglect",
                                                            input.neglect,
                                                            2,
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
  }
}

///|
pub fn nihss_total(input : NihssInput) -> Int {
  input.consciousness +
  input.questions +
  input.commands +
  input.gaze +
  input.visual +
  input.facial +
  input.left_arm +
  input.right_arm +
  input.left_leg +
  input.right_leg +
  input.ataxia +
  input.sensory +
  input.language +
  input.dysarthria +
  input.neglect
}

///|
pub fn nihss_severity(score : Int) -> Severity {
  if score == 0 {
    Low
  } else if score <= 4 {
    Medium
  } else if score <= 15 {
    High
  } else {
    Critical
  }
}

///|
pub fn score_nihss(input : NihssInput) -> ScoreReport {
  let score = nihss_total(input)
  report(
    "NIHSS",
    score,
    nihss_severity(score),
    "NIHSS quantifies observed neurologic deficit and should be administered with the official instructions.",
    [
      explanation(
        "Consciousness",
        input.consciousness,
        "Level of consciousness",
      ),
      explanation("Questions", input.questions, "Orientation questions"),
      explanation("Commands", input.commands, "Response to commands"),
      explanation("Gaze", input.gaze, "Best gaze"),
      explanation("Visual", input.visual, "Visual fields"),
      explanation("Facial", input.facial, "Facial palsy"),
      explanation("Left arm", input.left_arm, "Left arm motor"),
      explanation("Right arm", input.right_arm, "Right arm motor"),
      explanation("Left leg", input.left_leg, "Left leg motor"),
      explanation("Right leg", input.right_leg, "Right leg motor"),
      explanation("Ataxia", input.ataxia, "Limb ataxia"),
      explanation("Sensory", input.sensory, "Sensory loss"),
      explanation("Language", input.language, "Best language"),
      explanation("Dysarthria", input.dysarthria, "Dysarthria"),
      explanation("Neglect", input.neglect, "Extinction and inattention"),
    ],
  )
}

///|
pub(all) struct FourScoreInput {
  eye_response : Int
  motor_response : Int
  brainstem_reflexes : Int
  respiration : Int
} derive(Debug, Eq)

///|
pub fn validate_four_score(input : FourScoreInput) -> ValidationError? {
  match validate_range("eye_response", input.eye_response, 0, 4) {
    Some(err) => Some(err)
    None =>
      match validate_range("motor_response", input.motor_response, 0, 4) {
        Some(err) => Some(err)
        None =>
          match
            validate_range("brainstem_reflexes", input.brainstem_reflexes, 0, 4) {
            Some(err) => Some(err)
            None => validate_range("respiration", input.respiration, 0, 4)
          }
      }
  }
}

///|
pub fn four_score_total(input : FourScoreInput) -> Int {
  input.eye_response +
  input.motor_response +
  input.brainstem_reflexes +
  input.respiration
}

///|
pub fn four_score_severity(score : Int) -> Severity {
  if score <= 4 {
    Critical
  } else if score <= 8 {
    High
  } else if score <= 12 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_four(input : FourScoreInput) -> ScoreReport {
  let score = four_score_total(input)
  report(
    "FOUR",
    score,
    four_score_severity(score),
    "FOUR evaluates eye, motor, brainstem, and respiration domains when verbal assessment is limited.",
    [
      explanation("Eye", input.eye_response, "Eye response domain"),
      explanation("Motor", input.motor_response, "Motor response domain"),
      explanation(
        "Brainstem",
        input.brainstem_reflexes,
        "Brainstem reflex domain",
      ),
      explanation("Respiration", input.respiration, "Respiration domain"),
    ],
  )
}

///|
pub(all) struct Abcd2Input {
  age : Int
  systolic_bp : Int
  diastolic_bp : Int
  unilateral_weakness : Bool
  speech_impairment_without_weakness : Bool
  symptom_duration_minutes : Int
  diabetes : Bool
} derive(Debug, Eq)

///|
pub fn validate_abcd2(input : Abcd2Input) -> ValidationError? {
  match validate_range("age", input.age, 0, 150) {
    Some(err) => Some(err)
    None =>
      match validate_range("systolic_bp", input.systolic_bp, 0, 300) {
        Some(err) => Some(err)
        None =>
          match validate_range("diastolic_bp", input.diastolic_bp, 0, 200) {
            Some(err) => Some(err)
            None =>
              validate_range(
                "symptom_duration_minutes",
                input.symptom_duration_minutes,
                0,
                10000,
              )
          }
      }
  }
}

///|
pub fn abcd2_age_points(value : Int) -> Int {
  if value >= 60 {
    1
  } else {
    0
  }
}

///|
pub fn abcd2_pressure_points(systolic : Int, diastolic : Int) -> Int {
  if systolic >= 140 || diastolic >= 90 {
    1
  } else {
    0
  }
}

///|
pub fn abcd2_clinical_points(unilateral : Bool, speech_only : Bool) -> Int {
  if unilateral {
    2
  } else if speech_only {
    1
  } else {
    0
  }
}

///|
pub fn abcd2_duration_points(minutes : Int) -> Int {
  if minutes >= 60 {
    2
  } else if minutes >= 10 {
    1
  } else {
    0
  }
}

///|
pub fn abcd2_diabetes_points(value : Bool) -> Int {
  if value {
    1
  } else {
    0
  }
}

///|
pub fn abcd2_severity(score : Int) -> Severity {
  if score >= 6 {
    Critical
  } else if score >= 4 {
    High
  } else if score >= 2 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_abcd2(input : Abcd2Input) -> ScoreReport {
  let age = abcd2_age_points(input.age)
  let pressure = abcd2_pressure_points(input.systolic_bp, input.diastolic_bp)
  let clinical = abcd2_clinical_points(
    input.unilateral_weakness,
    input.speech_impairment_without_weakness,
  )
  let duration = abcd2_duration_points(input.symptom_duration_minutes)
  let diabetes = abcd2_diabetes_points(input.diabetes)
  let score = age + pressure + clinical + duration + diabetes
  report(
    "ABCD2",
    score,
    abcd2_severity(score),
    "ABCD2 summarizes early stroke risk domains after a transient ischemic attack; it does not replace evaluation.",
    [
      explanation("Age", age, "Age at least 60 years"),
      explanation(
        "Blood pressure", pressure, "Blood pressure at or above 140/90",
      ),
      explanation(
        "Clinical features", clinical, "Weakness or isolated speech impairment",
      ),
      explanation("Duration", duration, "Focal symptom duration"),
      explanation("Diabetes", diabetes, "Known diabetes"),
    ],
  )
}

///|
pub(all) struct CanadianCtHeadInput {
  age : Int
  gcs_less_than_15_at_two_hours : Bool
  suspected_open_skull_fracture : Bool
  signs_of_basal_skull_fracture : Bool
  vomiting_episodes : Int
  age_at_least_65 : Bool
  retrograde_amnesia_minutes : Int
  dangerous_mechanism : Bool
  anticoagulant_or_antiplatelet : Bool
} derive(Debug, Eq)

///|
pub fn validate_canadian_ct_head(
  input : CanadianCtHeadInput,
) -> ValidationError? {
  match validate_range("age", input.age, 0, 150) {
    Some(err) => Some(err)
    None =>
      match
        validate_range("vomiting_episodes", input.vomiting_episodes, 0, 100) {
        Some(err) => Some(err)
        None =>
          validate_range(
            "retrograde_amnesia_minutes",
            input.retrograde_amnesia_minutes,
            0,
            100000,
          )
      }
  }
}

///|
pub fn canadian_ct_head_high_risk_count(input : CanadianCtHeadInput) -> Int {
  let skull = if input.suspected_open_skull_fracture { 1 } else { 0 }
  let basal = if input.signs_of_basal_skull_fracture { 1 } else { 0 }
  let gcs = if input.gcs_less_than_15_at_two_hours { 1 } else { 0 }
  skull + basal + gcs
}

///|
pub fn canadian_ct_head_medium_risk_count(input : CanadianCtHeadInput) -> Int {
  let vomiting = if input.vomiting_episodes >= 2 { 1 } else { 0 }
  let age = if input.age_at_least_65 { 1 } else { 0 }
  let memory = if input.retrograde_amnesia_minutes > 30 { 1 } else { 0 }
  let mechanism = if input.dangerous_mechanism { 1 } else { 0 }
  vomiting + age + memory + mechanism
}

///|
pub fn canadian_ct_head_positive(input : CanadianCtHeadInput) -> Bool {
  canadian_ct_head_high_risk_count(input) > 0 ||
  canadian_ct_head_medium_risk_count(input) > 0 ||
  input.anticoagulant_or_antiplatelet
}

///|
pub fn score_canadian_ct_head(input : CanadianCtHeadInput) -> ScoreReport {
  let high = canadian_ct_head_high_risk_count(input)
  let medium = canadian_ct_head_medium_risk_count(input)
  let medication = if input.anticoagulant_or_antiplatelet { 1 } else { 0 }
  let score = high + medium + medication
  let severity = if canadian_ct_head_positive(input) { High } else { Low }
  report(
    "Canadian CT Head Rule",
    score,
    severity,
    "This rule exposes high- and medium-risk criteria for adult minor head injury review; confirm inclusion criteria before use.",
    [
      explanation("High-risk criteria", high, "High-risk rule count"),
      explanation("Medium-risk criteria", medium, "Medium-risk rule count"),
      explanation(
        "Medication modifier", medication, "Anticoagulant or antiplatelet flag",
      ),
    ],
  )
}
