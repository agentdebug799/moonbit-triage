///|
pub(all) struct TriageInput {
  news2 : News2Input
  gcs : GcsInput
} derive(Debug, Eq)

///|
pub(all) struct TriageBundle {
  news2 : ScoreReport
  qsofa : ScoreReport
  gcs : ScoreReport
  overall : Severity
  summary : String
  disclaimer : String
} derive(Debug, Eq)

///|
fn max_severity(left : Severity, right : Severity) -> Severity {
  match (left, right) {
    (Critical, _) | (_, Critical) => Critical
    (High, _) | (_, High) => High
    (Medium, _) | (_, Medium) => Medium
    _ => Low
  }
}

///|
fn bundle_summary(overall : Severity) -> String {
  match overall {
    Critical =>
      "At least one score is in its highest concern band. Use local escalation policy and clinical judgment."
    High =>
      "At least one score indicates raised concern. Review the component explanations before acting."
    Medium => "One or more mild-to-moderate scoring triggers are present."
    Low => "No supplied score produced a raised concern band."
  }
}

///|
pub fn score_triage(input : TriageInput) -> TriageBundle {
  let news2 = score_news2(input.news2)
  let gcs_report = score_gcs_as_report(input.gcs)
  let qsofa = score_qsofa({
    respiratory_rate: input.news2.respiratory_rate,
    systolic_bp: input.news2.systolic_bp,
    gcs_total: gcs_total(input.gcs),
  })
  let overall = max_severity(
    max_severity(news2.severity, qsofa.severity),
    gcs_report.severity,
  )
  {
    news2,
    qsofa,
    gcs: gcs_report,
    overall,
    summary: bundle_summary(overall),
    disclaimer: triage_disclaimer(),
  }
}

///|
pub fn validate_triage(input : TriageInput) -> ValidationError? {
  match validate_news2(input.news2) {
    Some(err) => Some(err)
    None => validate_gcs(input.gcs)
  }
}
