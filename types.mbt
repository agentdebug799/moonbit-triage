///|
pub(all) enum Severity {
  Low
  Medium
  High
  Critical
} derive(Debug, Eq)

///|
pub(all) struct Explanation {
  label : String
  points : Int
  detail : String
} derive(Debug, Eq)

///|
pub(all) struct ScoreReport {
  instrument : String
  score : Int
  severity : Severity
  interpretation : String
  explanations : Array[Explanation]
  disclaimer : String
} derive(Debug, Eq)

///|
pub fn triage_disclaimer() -> String {
  "For education, audit, and software validation only. This library computes public scoring rules and never provides diagnosis, treatment advice, or patient disposition."
}

///|
pub fn explanation(
  label : String,
  points : Int,
  detail : String,
) -> Explanation {
  { label, points, detail }
}

///|
pub fn report(
  instrument : String,
  score : Int,
  severity : Severity,
  interpretation : String,
  explanations : Array[Explanation],
) -> ScoreReport {
  {
    instrument,
    score,
    severity,
    interpretation,
    explanations,
    disclaimer: triage_disclaimer(),
  }
}

///|
pub fn clamp(value : Int, low : Int, high : Int) -> Int {
  if value < low {
    low
  } else if value > high {
    high
  } else {
    value
  }
}
