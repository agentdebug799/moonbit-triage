///|
pub(all) enum EscalationTier {
  Routine
  Review
  Urgent
  Immediate
} derive(Debug, Eq)

///|
pub(all) enum EvidenceStatus {
  EvidenceComplete
  EvidencePartial
  EvidenceMissing
  EvidenceInvalid
} derive(Debug, Eq)

///|
pub(all) struct PathwayRule {
  code : String
  title : String
  tier : EscalationTier
  required_instruments : Array[String]
  minimum_severity : Severity
  rationale : String
} derive(Debug, Eq)

///|
pub(all) struct PathwayDecision {
  tier : EscalationTier
  evidence : EvidenceStatus
  matched_rules : Array[String]
  missing_instruments : Array[String]
  highest_severity : Severity
  score_count : Int
  explanation : String
} derive(Debug, Eq)

///|
pub fn escalation_tier_label(tier : EscalationTier) -> String {
  match tier {
    Routine => "routine"
    Review => "review"
    Urgent => "urgent"
    Immediate => "immediate"
  }
}

///|
pub fn evidence_status_label(status : EvidenceStatus) -> String {
  match status {
    EvidenceComplete => "complete"
    EvidencePartial => "partial"
    EvidenceMissing => "missing"
    EvidenceInvalid => "invalid"
  }
}

///|
pub fn severity_rank(severity : Severity) -> Int {
  match severity {
    Low => 0
    Medium => 1
    High => 2
    Critical => 3
  }
}

///|
pub fn escalation_rank(tier : EscalationTier) -> Int {
  match tier {
    Routine => 0
    Review => 1
    Urgent => 2
    Immediate => 3
  }
}

///|
pub fn max_tier(
  left : EscalationTier,
  right : EscalationTier,
) -> EscalationTier {
  if escalation_rank(left) >= escalation_rank(right) {
    left
  } else {
    right
  }
}

///|
pub fn max_pathway_severity(left : Severity, right : Severity) -> Severity {
  if severity_rank(left) >= severity_rank(right) {
    left
  } else {
    right
  }
}

///|
pub fn instrument_present(reports : Array[ScoreReport], name : String) -> Bool {
  for report in reports {
    if report.instrument == name {
      return true
    }
  }
  false
}

///|
pub fn reports_highest_severity(reports : Array[ScoreReport]) -> Severity {
  let mut highest = Low
  for report in reports {
    highest = max_pathway_severity(highest, report.severity)
  }
  highest
}

///|
pub fn reports_have_invalid_score(reports : Array[ScoreReport]) -> Bool {
  for report in reports {
    if report.score < 0 {
      return true
    }
  }
  false
}

///|
pub fn pathway_rule_matches(
  rule : PathwayRule,
  reports : Array[ScoreReport],
) -> Bool {
  if severity_rank(reports_highest_severity(reports)) <
    severity_rank(rule.minimum_severity) {
    false
  } else {
    for instrument in rule.required_instruments {
      if !instrument_present(reports, instrument) {
        return false
      }
    }
    true
  }
}

///|
pub fn pathway_missing_instruments(
  rule : PathwayRule,
  reports : Array[ScoreReport],
) -> Array[String] {
  let missing = []
  for instrument in rule.required_instruments {
    if !instrument_present(reports, instrument) {
      missing.push(instrument)
    }
  }
  missing
}

///|
pub fn pathway_rule_labels(rules : Array[PathwayRule]) -> Array[String] {
  rules.map(fn(rule) { rule.code + ": " + rule.title })
}

///|
pub fn evaluate_pathway(
  rules : Array[PathwayRule],
  reports : Array[ScoreReport],
) -> PathwayDecision {
  let mut tier = Routine
  let matched = []
  let missing = []
  for rule in rules {
    if pathway_rule_matches(rule, reports) {
      tier = max_tier(tier, rule.tier)
      matched.push(rule.code + ": " + rule.rationale)
    } else {
      let rule_missing = pathway_missing_instruments(rule, reports)
      for item in rule_missing {
        if !missing.contains(item) {
          missing.push(item)
        }
      }
    }
  }
  let evidence = if reports_have_invalid_score(reports) {
    EvidenceInvalid
  } else if reports.length() == 0 {
    EvidenceMissing
  } else if missing.length() > 0 {
    EvidencePartial
  } else {
    EvidenceComplete
  }
  let highest = reports_highest_severity(reports)
  let explanation = pathway_decision_explanation(
    tier,
    evidence,
    highest,
    matched.length(),
  )
  {
    tier,
    evidence,
    matched_rules: matched,
    missing_instruments: missing,
    highest_severity: highest,
    score_count: reports.length(),
    explanation,
  }
}

///|
pub fn pathway_decision_explanation(
  tier : EscalationTier,
  evidence : EvidenceStatus,
  severity : Severity,
  matched_count : Int,
) -> String {
  escalation_tier_label(tier) +
  " tier; evidence=" +
  evidence_status_label(evidence) +
  "; highest=" +
  severity_label(severity) +
  "; matched_rules=" +
  matched_count.to_string()
}

///|
pub fn render_pathway_decision(decision : PathwayDecision) -> String {
  let matched = decision.matched_rules.join(" | ")
  let missing = decision.missing_instruments.join(",")
  "tier=" +
  escalation_tier_label(decision.tier) +
  "; evidence=" +
  evidence_status_label(decision.evidence) +
  "; highest=" +
  severity_label(decision.highest_severity) +
  "; scores=" +
  decision.score_count.to_string() +
  "; matched=[" +
  matched +
  "]; missing=[" +
  missing +
  "]; " +
  decision.explanation
}

///|
pub(all) struct AuditEvent {
  sequence : Int
  event_type : String
  instrument : String
  score : Int
  severity : Severity
  timestamp_minutes : Int
  source : String
  note : String
} derive(Debug, Eq)

///|
pub fn audit_event(
  sequence : Int,
  event_type : String,
  instrument : String,
  report : ScoreReport,
  timestamp_minutes : Int,
  source : String,
  note : String,
) -> AuditEvent {
  {
    sequence,
    event_type,
    instrument,
    score: report.score,
    severity: report.severity,
    timestamp_minutes,
    source,
    note,
  }
}

///|
pub fn validate_audit_event(event : AuditEvent) -> ValidationError? {
  match validate_range("sequence", event.sequence, 0, 1000000000) {
    Some(err) => Some(err)
    None =>
      match
        validate_range(
          "timestamp_minutes",
          event.timestamp_minutes,
          0,
          1000000000,
        ) {
        Some(err) => Some(err)
        None => validate_range("score", event.score, 0, 1000000000)
      }
  }
}

///|
pub fn audit_event_label(event : AuditEvent) -> String {
  event.sequence.to_string() +
  "@" +
  event.timestamp_minutes.to_string() +
  " " +
  event.event_type +
  " " +
  event.instrument +
  " score=" +
  event.score.to_string() +
  " severity=" +
  severity_label(event.severity) +
  " source=" +
  event.source
}

///|
pub fn audit_ordered(left : AuditEvent, right : AuditEvent) -> Bool {
  if left.sequence == right.sequence {
    left.timestamp_minutes <= right.timestamp_minutes
  } else {
    left.sequence < right.sequence
  }
}

///|
pub fn sort_audit_events(events : Array[AuditEvent]) -> Array[AuditEvent] {
  let sorted = events.copy()
  for index = 1; index < sorted.length(); index = index + 1 {
    let current = sorted[index]
    let mut cursor = index
    while cursor > 0 && !audit_ordered(sorted[cursor - 1], current) {
      sorted[cursor] = sorted[cursor - 1]
      cursor = cursor - 1
    }
    sorted[cursor] = current
  }
  sorted
}

///|
pub fn audit_event_labels(events : Array[AuditEvent]) -> Array[String] {
  sort_audit_events(events).map(audit_event_label)
}

///|
pub(all) struct TraceSummary {
  event_count : Int
  unique_instruments : Int
  first_timestamp : Int?
  last_timestamp : Int?
  invalid_event_count : Int
  source_labels : Array[String]
} derive(Debug, Eq)

///|
pub fn trace_summary(events : Array[AuditEvent]) -> TraceSummary {
  let ordered = sort_audit_events(events)
  let instruments = []
  let sources = []
  let mut invalid = 0
  for event in ordered {
    if !instruments.contains(event.instrument) {
      instruments.push(event.instrument)
    }
    if !sources.contains(event.source) {
      sources.push(event.source)
    }
    if validate_audit_event(event) is Some(_) {
      invalid += 1
    }
  }
  let first_timestamp : Int? = if ordered.length() == 0 {
    None
  } else {
    Some(ordered[0].timestamp_minutes)
  }
  let last_timestamp : Int? = if ordered.length() == 0 {
    None
  } else {
    Some(ordered[ordered.length() - 1].timestamp_minutes)
  }
  {
    event_count: events.length(),
    unique_instruments: instruments.length(),
    first_timestamp,
    last_timestamp,
    invalid_event_count: invalid,
    source_labels: sources,
  }
}

///|
pub fn render_trace_summary(summary : TraceSummary) -> String {
  let first = match summary.first_timestamp {
    Some(value) => value.to_string()
    None => "none"
  }
  let last = match summary.last_timestamp {
    Some(value) => value.to_string()
    None => "none"
  }
  "events=" +
  summary.event_count.to_string() +
  "; instruments=" +
  summary.unique_instruments.to_string() +
  "; first=" +
  first +
  "; last=" +
  last +
  "; invalid=" +
  summary.invalid_event_count.to_string() +
  "; sources=" +
  summary.source_labels.join(",")
}
