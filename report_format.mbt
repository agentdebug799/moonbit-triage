///|
pub fn explanation_label(item : Explanation) -> String {
  item.label + "=" + item.points.to_string()
}

///|
pub fn explanation_labels(items : Array[Explanation]) -> Array[String] {
  items.map(explanation_label)
}

///|
pub fn render_explanation(item : Explanation) -> String {
  item.label + ": " + item.points.to_string() + " (" + item.detail + ")"
}

///|
pub fn render_explanations(items : Array[Explanation]) -> String {
  items.map(render_explanation).join("; ")
}

///|
pub fn report_severity_rank(report : ScoreReport) -> Int {
  severity_rank(report.severity)
}

///|
pub fn report_header(report : ScoreReport) -> String {
  report.instrument +
  " score=" +
  report.score.to_string() +
  " severity=" +
  severity_label(report.severity)
}

///|
pub fn render_report(report : ScoreReport) -> String {
  report_header(report) +
  "; interpretation=" +
  report.interpretation +
  "; explanations=[" +
  render_explanations(report.explanations) +
  "]"
}

///|
pub fn report_csv_header() -> String {
  "instrument,score,severity,interpretation,explanations"
}

///|
pub fn report_csv_row(report : ScoreReport) -> String {
  report.instrument +
  "," +
  report.score.to_string() +
  "," +
  severity_label(report.severity) +
  "," +
  report.interpretation +
  "," +
  explanation_labels(report.explanations).join("|")
}

///|
pub fn reports_csv(reports : Array[ScoreReport]) -> String {
  let lines = [report_csv_header()]
  for report in reports {
    lines.push(report_csv_row(report))
  }
  lines.join("\n")
}

///|
pub fn report_is_more_concerning(
  left : ScoreReport,
  right : ScoreReport,
) -> Bool {
  let left_rank = report_severity_rank(left)
  let right_rank = report_severity_rank(right)
  left_rank > right_rank ||
  (left_rank == right_rank && left.score > right.score)
}

///|
pub fn highest_concern_report(reports : Array[ScoreReport]) -> ScoreReport? {
  let mut highest : ScoreReport? = None
  for report in reports {
    match highest {
      None => highest = Some(report)
      Some(current) =>
        if report_is_more_concerning(report, current) {
          highest = Some(report)
        }
    }
  }
  highest
}

///|
pub fn report_interpretations(reports : Array[ScoreReport]) -> Array[String] {
  reports.map(fn(report) { report.instrument + ": " + report.interpretation })
}

///|
pub fn report_explanation_count(reports : Array[ScoreReport]) -> Int {
  let mut count = 0
  for report in reports {
    count += report.explanations.length()
  }
  count
}

///|
pub fn report_summary_line(reports : Array[ScoreReport]) -> String {
  let summary = summarize_reports(reports)
  "count=" +
  summary.count.to_string() +
  "; total=" +
  summary.total_score.to_string() +
  "; highest=" +
  severity_label(summary.highest) +
  "; explanations=" +
  report_explanation_count(reports).to_string()
}

///|
pub fn report_find(
  reports : Array[ScoreReport],
  instrument : String,
) -> ScoreReport? {
  for report in reports {
    if report.instrument == instrument {
      return Some(report)
    }
  }
  None
}

///|
pub fn reports_with_severity(
  reports : Array[ScoreReport],
  severity : Severity,
) -> Array[ScoreReport] {
  reports.filter(fn(report) { report.severity == severity })
}

///|
pub fn reports_at_or_above(
  reports : Array[ScoreReport],
  severity : Severity,
) -> Array[ScoreReport] {
  reports.filter(fn(report) {
    severity_rank(report.severity) >= severity_rank(severity)
  })
}

///|
pub fn report_points_for_label(report : ScoreReport, label : String) -> Int? {
  for item in report.explanations {
    if item.label == label {
      return Some(item.points)
    }
  }
  None
}

///|
pub fn report_has_explanation(report : ScoreReport, label : String) -> Bool {
  report_points_for_label(report, label) is Some(_)
}

///|
pub fn report_explanation_total(report : ScoreReport) -> Int {
  let mut total = 0
  for item in report.explanations {
    total += item.points
  }
  total
}

///|
pub fn report_score_reconciles(report : ScoreReport) -> Bool {
  report_score_reconciles_with_explanations(report, report.explanations)
}

///|
pub fn report_score_reconciles_with_explanations(
  report : ScoreReport,
  explanations : Array[Explanation],
) -> Bool {
  let mut total = 0
  for item in explanations {
    total += item.points
  }
  total == report.score || report.explanations.length() == 0
}

///|
pub fn report_value_vector(reports : Array[ScoreReport]) -> Array[Int] {
  reports.map(fn(report) { report.score })
}

///|
pub fn report_severity_vector(reports : Array[ScoreReport]) -> Array[String] {
  reports.map(fn(report) { severity_label(report.severity) })
}

///|
pub fn reports_render_lines(reports : Array[ScoreReport]) -> Array[String] {
  reports.map(render_report)
}

///|
pub fn report_catalog_line(report : ScoreReport) -> String {
  report.instrument +
  " | " +
  severity_label(report.severity) +
  " | " +
  report.score.to_string() +
  " | " +
  report.explanations.length().to_string() +
  " explanations"
}

///|
pub fn report_catalog(reports : Array[ScoreReport]) -> String {
  reports.map(report_catalog_line).join("\n")
}

///|
pub fn report_disclaimer_set(reports : Array[ScoreReport]) -> Array[String] {
  let disclaimers = []
  for report in reports {
    if !disclaimers.contains(report.disclaimer) {
      disclaimers.push(report.disclaimer)
    }
  }
  disclaimers
}

///|
pub fn report_bundle_is_coherent(reports : Array[ScoreReport]) -> Bool {
  if reports.length() == 0 {
    return true
  }
  let disclaimers = report_disclaimer_set(reports)
  disclaimers.length() == 1 &&
  reports.all(fn(report) { report.instrument != "" && report.score >= 0 })
}

///|
pub fn report_max_score(reports : Array[ScoreReport]) -> Int {
  let mut maximum = 0
  for report in reports {
    if report.score > maximum {
      maximum = report.score
    }
  }
  maximum
}

///|
pub fn report_min_score(reports : Array[ScoreReport]) -> Int? {
  if reports.length() == 0 {
    None
  } else {
    let mut minimum = reports[0].score
    for report in reports {
      if report.score < minimum {
        minimum = report.score
      }
    }
    Some(minimum)
  }
}

///|
pub fn report_range(reports : Array[ScoreReport]) -> Int {
  match report_min_score(reports) {
    None => 0
    Some(minimum) => report_max_score(reports) - minimum
  }
}

///|
pub fn report_instrument_names(reports : Array[ScoreReport]) -> Array[String] {
  reports.map(fn(report) { report.instrument })
}

///|
pub fn report_is_empty(report : ScoreReport) -> Bool {
  report.instrument == "" || report.explanations.length() == 0
}

///|
pub fn report_nonempty(reports : Array[ScoreReport]) -> Array[ScoreReport] {
  reports.filter(fn(report) { !report_is_empty(report) })
}

///|
pub fn report_count_at_or_above(
  reports : Array[ScoreReport],
  severity : Severity,
) -> Int {
  reports_at_or_above(reports, severity).length()
}

///|
pub fn report_score_sum(reports : Array[ScoreReport]) -> Int {
  let mut total = 0
  for report in reports {
    total += report.score
  }
  total
}

///|
pub fn report_average_score_x100(reports : Array[ScoreReport]) -> Int {
  if reports.length() == 0 {
    0
  } else {
    report_score_sum(reports) * 100 / reports.length()
  }
}

///|
pub fn report_has_severity(
  reports : Array[ScoreReport],
  severity : Severity,
) -> Bool {
  reports.any(fn(report) { report.severity == severity })
}

///|
pub(all) struct ReportQuality {
  total : Int
  nonempty : Int
  reconciled : Int
  coherent : Bool
  disclaimer_count : Int
} derive(Debug, Eq)

///|
pub fn report_quality(reports : Array[ScoreReport]) -> ReportQuality {
  let valid = report_nonempty(reports)
  let mut reconciled = 0
  for report in valid {
    if report_score_reconciles(report) {
      reconciled += 1
    }
  }
  {
    total: reports.length(),
    nonempty: valid.length(),
    reconciled,
    coherent: report_bundle_is_coherent(valid),
    disclaimer_count: report_disclaimer_set(valid).length(),
  }
}

///|
pub fn report_quality_ready(quality : ReportQuality) -> Bool {
  quality.total > 0 &&
  quality.total == quality.nonempty &&
  quality.nonempty == quality.reconciled &&
  quality.coherent &&
  quality.disclaimer_count == 1
}

///|
pub fn render_report_quality(quality : ReportQuality) -> String {
  "total=" +
  quality.total.to_string() +
  "; nonempty=" +
  quality.nonempty.to_string() +
  "; reconciled=" +
  quality.reconciled.to_string() +
  "; coherent=" +
  quality.coherent.to_string() +
  "; disclaimers=" +
  quality.disclaimer_count.to_string()
}

///|
pub(all) struct ReportComparison {
  left_instrument : String
  right_instrument : String
  left_score : Int
  right_score : Int
  left_more_concerning : Bool
  score_delta : Int
} derive(Debug, Eq)

///|
pub fn compare_reports(
  left : ScoreReport,
  right : ScoreReport,
) -> ReportComparison {
  {
    left_instrument: left.instrument,
    right_instrument: right.instrument,
    left_score: left.score,
    right_score: right.score,
    left_more_concerning: report_is_more_concerning(left, right),
    score_delta: left.score - right.score,
  }
}

///|
pub fn render_report_comparison(comparison : ReportComparison) -> String {
  comparison.left_instrument +
  " vs " +
  comparison.right_instrument +
  ": delta=" +
  comparison.score_delta.to_string() +
  "; left_more_concerning=" +
  comparison.left_more_concerning.to_string()
}

///|
pub fn report_delta_label(delta : Int) -> String {
  if delta > 0 {
    "increased"
  } else if delta < 0 {
    "decreased"
  } else {
    "unchanged"
  }
}

///|
pub fn report_comparison_label(comparison : ReportComparison) -> String {
  comparison.left_instrument +
  " " +
  report_delta_label(comparison.score_delta) +
  " vs " +
  comparison.right_instrument
}

///|
pub fn report_average_delta_x100(
  left : Array[ScoreReport],
  right : Array[ScoreReport],
) -> Int {
  if left.length() == 0 || right.length() == 0 {
    0
  } else {
    report_score_sum(left) * 100 / left.length() -
    report_score_sum(right) * 100 / right.length()
  }
}
