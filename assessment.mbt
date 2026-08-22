///|
pub(all) struct ScoreSnapshot {
  instrument : String
  score : Int
  severity : Severity
  timestamp_minutes : Int
  source : String
} derive(Debug, Eq)

///|
pub fn snapshot(
  instrument : String,
  score : Int,
  severity : Severity,
  timestamp_minutes : Int,
  source : String,
) -> ScoreSnapshot {
  { instrument, score, severity, timestamp_minutes, source }
}

///|
pub fn snapshot_from_report(
  report : ScoreReport,
  timestamp_minutes : Int,
  source : String,
) -> ScoreSnapshot {
  snapshot(
    report.instrument,
    report.score,
    report.severity,
    timestamp_minutes,
    source,
  )
}

///|
pub fn snapshot_age_minutes(now : Int, item : ScoreSnapshot) -> Int {
  if now <= item.timestamp_minutes {
    0
  } else {
    now - item.timestamp_minutes
  }
}

///|
pub fn snapshot_is_fresh(
  now : Int,
  item : ScoreSnapshot,
  window_minutes : Int,
) -> Bool {
  snapshot_age_minutes(now, item) <= window_minutes
}

///|
pub(all) enum SnapshotChange {
  Increased(Int)
  Decreased(Int)
  Unchanged
  InstrumentChanged
} derive(Debug, Eq)

///|
pub fn compare_snapshots(
  left : ScoreSnapshot,
  right : ScoreSnapshot,
) -> SnapshotChange {
  if left.instrument != right.instrument {
    InstrumentChanged
  } else if right.score > left.score {
    Increased(right.score - left.score)
  } else if right.score < left.score {
    Decreased(left.score - right.score)
  } else {
    Unchanged
  }
}

///|
pub fn snapshot_change_label(change : SnapshotChange) -> String {
  match change {
    Increased(_) => "increased"
    Decreased(_) => "decreased"
    Unchanged => "unchanged"
    InstrumentChanged => "instrument-changed"
  }
}

///|
pub fn snapshot_change_amount(change : SnapshotChange) -> Int {
  match change {
    Increased(amount) | Decreased(amount) => amount
    Unchanged | InstrumentChanged => 0
  }
}

///|
pub(all) struct AssessmentLedger {
  snapshots : Array[ScoreSnapshot]
  last_timestamp_minutes : Int
} derive(Debug, Eq)

///|
pub fn empty_ledger() -> AssessmentLedger {
  { snapshots: [], last_timestamp_minutes: 0 }
}

///|
pub fn ledger_size(ledger : AssessmentLedger) -> Int {
  ledger.snapshots.length()
}

///|
pub fn ledger_add(
  ledger : AssessmentLedger,
  item : ScoreSnapshot,
) -> AssessmentLedger {
  let snapshots = ledger.snapshots.copy()
  snapshots.push(item)
  let timestamp = if item.timestamp_minutes > ledger.last_timestamp_minutes {
    item.timestamp_minutes
  } else {
    ledger.last_timestamp_minutes
  }
  { snapshots, last_timestamp_minutes: timestamp }
}

///|
pub fn ledger_latest(ledger : AssessmentLedger) -> ScoreSnapshot? {
  if ledger.snapshots.length() == 0 {
    None
  } else {
    Some(ledger.snapshots[ledger.snapshots.length() - 1])
  }
}

///|
pub fn ledger_latest_instrument(
  ledger : AssessmentLedger,
  instrument : String,
) -> ScoreSnapshot? {
  let mut latest : ScoreSnapshot? = None
  for item in ledger.snapshots {
    if item.instrument == instrument {
      latest = Some(item)
    }
  }
  latest
}

///|
pub fn ledger_count_instrument(
  ledger : AssessmentLedger,
  instrument : String,
) -> Int {
  let mut count = 0
  for item in ledger.snapshots {
    if item.instrument == instrument {
      count += 1
    }
  }
  count
}

///|
pub fn ledger_total_score(ledger : AssessmentLedger) -> Int {
  ledger.snapshots.fold(init=0, (total, item) => total + item.score)
}

///|
pub fn ledger_highest_severity(ledger : AssessmentLedger) -> Severity {
  let mut result = Low
  for item in ledger.snapshots {
    match (result, item.severity) {
      (Critical, _) | (_, Critical) => result = Critical
      (High, _) | (_, High) => result = High
      (Medium, _) | (_, Medium) => result = Medium
      _ => result = Low
    }
  }
  result
}

///|
pub fn ledger_scores(ledger : AssessmentLedger) -> Array[Int] {
  ledger.snapshots.map(item => item.score)
}

///|
pub fn ledger_instruments(ledger : AssessmentLedger) -> Array[String] {
  ledger.snapshots.map(item => item.instrument)
}

///|
pub fn render_snapshot(item : ScoreSnapshot) -> String {
  "\{item.instrument}: score=\{item.score}, severity=\{severity_label(item.severity)}, time=\{item.timestamp_minutes}, source=\{item.source}"
}

///|
pub fn render_ledger(ledger : AssessmentLedger) -> String {
  ledger.snapshots.map(render_snapshot).join("; ")
}

///|
pub fn render_change(left : ScoreSnapshot, right : ScoreSnapshot) -> String {
  let change = compare_snapshots(left, right)
  "\{left.instrument} \{snapshot_change_label(change)}"
}

///|
pub(all) struct AssessmentSummary {
  snapshots : Int
  instruments : Int
  total_score : Int
  highest : Severity
  latest_timestamp_minutes : Int
} derive(Debug, Eq)

///|
pub fn assessment_summary(ledger : AssessmentLedger) -> AssessmentSummary {
  let names : Array[String] = []
  for item in ledger.snapshots {
    if !names.contains(item.instrument) {
      names.push(item.instrument)
    }
  }
  {
    snapshots: ledger_size(ledger),
    instruments: names.length(),
    total_score: ledger_total_score(ledger),
    highest: ledger_highest_severity(ledger),
    latest_timestamp_minutes: match ledger_latest(ledger) {
      Some(item) => item.timestamp_minutes
      None => 0
    },
  }
}
