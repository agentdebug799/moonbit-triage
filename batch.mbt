///|
pub(all) struct ReportSummary {
  count : Int
  total_score : Int
  highest : Severity
  low_count : Int
  medium_count : Int
  high_count : Int
  critical_count : Int
} derive(Debug, Eq)

///|
pub fn summarize_reports(reports : Array[ScoreReport]) -> ReportSummary {
  let mut total = 0
  let mut low = 0
  let mut medium = 0
  let mut high = 0
  let mut critical = 0
  for report in reports {
    total += report.score
    match report.severity {
      Low => low += 1
      Medium => medium += 1
      High => high += 1
      Critical => critical += 1
    }
  }
  let highest = if critical > 0 {
    Critical
  } else if high > 0 {
    High
  } else if medium > 0 {
    Medium
  } else {
    Low
  }
  {
    count: reports.length(),
    total_score: total,
    highest,
    low_count: low,
    medium_count: medium,
    high_count: high,
    critical_count: critical,
  }
}
