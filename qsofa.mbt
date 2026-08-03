///|
pub(all) struct QsofaInput {
  respiratory_rate : Int
  systolic_bp : Int
  gcs_total : Int
} derive(Debug, Eq)

///|
pub fn validate_qsofa(input : QsofaInput) -> ValidationError? {
  match validate_range("respiratory_rate", input.respiratory_rate, 0, 80) {
    Some(err) => Some(err)
    None =>
      match validate_range("systolic_bp", input.systolic_bp, 40, 300) {
        Some(err) => Some(err)
        None => validate_range("gcs_total", input.gcs_total, 3, 15)
      }
  }
}

///|
pub fn qsofa_respiratory_rate_points(respiratory_rate : Int) -> Int {
  if respiratory_rate >= 22 {
    1
  } else {
    0
  }
}

///|
pub fn qsofa_systolic_bp_points(systolic_bp : Int) -> Int {
  if systolic_bp <= 100 {
    1
  } else {
    0
  }
}

///|
pub fn qsofa_mentation_points(gcs_total : Int) -> Int {
  if gcs_total < 15 {
    1
  } else {
    0
  }
}

///|
pub fn qsofa_severity(score : Int) -> Severity {
  if score >= 2 {
    High
  } else if score == 1 {
    Medium
  } else {
    Low
  }
}

///|
fn qsofa_interpretation(score : Int) -> String {
  if score >= 2 {
    "qSOFA is positive: this is a bedside prompt for higher risk in suspected infection, not a sepsis diagnosis."
  } else if score == 1 {
    "One qSOFA criterion is present; repeat assessment may be useful if the patient changes."
  } else {
    "No qSOFA criteria are present from the supplied values."
  }
}

///|
pub fn score_qsofa(input : QsofaInput) -> ScoreReport {
  let rr = qsofa_respiratory_rate_points(input.respiratory_rate)
  let bp = qsofa_systolic_bp_points(input.systolic_bp)
  let mentation = qsofa_mentation_points(input.gcs_total)
  let score = rr + bp + mentation
  report("qSOFA", score, qsofa_severity(score), qsofa_interpretation(score), [
    explanation(
      "Respiratory rate >= 22", rr, "One point when respiratory rate is at least 22/min",
    ),
    explanation(
      "Systolic BP <= 100", bp, "One point when systolic blood pressure is 100 mmHg or lower",
    ),
    explanation(
      "GCS < 15", mentation, "One point when the Glasgow Coma Scale total is below 15",
    ),
  ])
}
