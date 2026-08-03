///|
pub(all) struct GcsInput {
  eye : Int
  verbal : Int
  motor : Int
} derive(Debug, Eq)

///|
pub(all) struct GcsReport {
  total : Int
  eye : Int
  verbal : Int
  motor : Int
  severity : Severity
  explanations : Array[Explanation]
  disclaimer : String
} derive(Debug, Eq)

///|
pub fn validate_gcs(input : GcsInput) -> ValidationError? {
  match validate_range("eye", input.eye, 1, 4) {
    Some(err) => Some(err)
    None =>
      match validate_range("verbal", input.verbal, 1, 5) {
        Some(err) => Some(err)
        None => validate_range("motor", input.motor, 1, 6)
      }
  }
}

///|
pub fn gcs_total(input : GcsInput) -> Int {
  input.eye + input.verbal + input.motor
}

///|
pub fn gcs_severity(total : Int) -> Severity {
  if total <= 8 {
    Critical
  } else if total <= 12 {
    High
  } else if total <= 14 {
    Medium
  } else {
    Low
  }
}

///|
fn gcs_eye_detail(score : Int) -> String {
  match score {
    4 => "Eyes open spontaneously"
    3 => "Eyes open to speech"
    2 => "Eyes open to pain"
    _ => "No eye opening"
  }
}

///|
fn gcs_verbal_detail(score : Int) -> String {
  match score {
    5 => "Oriented verbal response"
    4 => "Confused verbal response"
    3 => "Inappropriate words"
    2 => "Incomprehensible sounds"
    _ => "No verbal response"
  }
}

///|
fn gcs_motor_detail(score : Int) -> String {
  match score {
    6 => "Obeys commands"
    5 => "Localizes pain"
    4 => "Withdraws from pain"
    3 => "Abnormal flexion"
    2 => "Abnormal extension"
    _ => "No motor response"
  }
}

///|
pub fn score_gcs(input : GcsInput) -> GcsReport {
  let total = gcs_total(input)
  {
    total,
    eye: input.eye,
    verbal: input.verbal,
    motor: input.motor,
    severity: gcs_severity(total),
    explanations: [
      explanation("Eye response", input.eye, gcs_eye_detail(input.eye)),
      explanation(
        "Verbal response",
        input.verbal,
        gcs_verbal_detail(input.verbal),
      ),
      explanation("Motor response", input.motor, gcs_motor_detail(input.motor)),
    ],
    disclaimer: triage_disclaimer(),
  }
}

///|
pub fn score_gcs_as_report(input : GcsInput) -> ScoreReport {
  let gcs = score_gcs(input)
  report(
    "Glasgow Coma Scale",
    gcs.total,
    gcs.severity,
    "GCS total is a neurological responsiveness score and must be interpreted in clinical context.",
    gcs.explanations,
  )
}
