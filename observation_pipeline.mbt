///|
pub(all) enum MeasurementUnit {
  BeatsPerMinute
  BreathsPerMinute
  MillimetersMercury
  Percent
  CelsiusTenths
  MilligramsPerDeciliter
  MillimolesPerLiter
  MicromolesPerLiter
  ScorePoints
  Unknown
} derive(Debug, Eq)

///|
pub(all) enum ObservationKind {
  HeartRate
  RespiratoryRate
  SystolicBloodPressure
  DiastolicBloodPressure
  OxygenSaturation
  Temperature
  GlasgowComaScale
  WhiteCellCount
  PlateletCount
  Bilirubin
  Creatinine
  Custom
} derive(Debug, Eq)

///|
pub(all) struct Observation {
  kind : ObservationKind
  value : Int
  unit : MeasurementUnit
  timestamp_minutes : Int
  source : String
} derive(Debug, Eq)

///|
pub fn observation(
  kind : ObservationKind,
  value : Int,
  unit : MeasurementUnit,
  timestamp_minutes : Int,
  source : String,
) -> Observation {
  { kind, value, unit, timestamp_minutes, source }
}

///|
pub fn observation_is_ordered(left : Observation, right : Observation) -> Bool {
  left.timestamp_minutes <= right.timestamp_minutes
}

///|
pub fn observation_age_minutes(now : Int, item : Observation) -> Int {
  if now <= item.timestamp_minutes {
    0
  } else {
    now - item.timestamp_minutes
  }
}

///|
pub fn observation_is_fresh(
  now : Int,
  item : Observation,
  window_minutes : Int,
) -> Bool {
  observation_age_minutes(now, item) <= window_minutes
}

///|
pub fn observation_delta(older : Observation, newer : Observation) -> Int {
  newer.value - older.value
}

///|
pub fn observation_unit_label(unit : MeasurementUnit) -> String {
  match unit {
    BeatsPerMinute => "bpm"
    BreathsPerMinute => "breaths/min"
    MillimetersMercury => "mmHg"
    Percent => "%"
    CelsiusTenths => "0.1C"
    MilligramsPerDeciliter => "mg/dL"
    MillimolesPerLiter => "mmol/L"
    MicromolesPerLiter => "umol/L"
    ScorePoints => "points"
    Unknown => "unknown"
  }
}

///|
pub fn observation_kind_label(kind : ObservationKind) -> String {
  match kind {
    HeartRate => "heart_rate"
    RespiratoryRate => "respiratory_rate"
    SystolicBloodPressure => "systolic_bp"
    DiastolicBloodPressure => "diastolic_bp"
    OxygenSaturation => "oxygen_saturation"
    Temperature => "temperature"
    GlasgowComaScale => "gcs"
    WhiteCellCount => "white_cell_count"
    PlateletCount => "platelet_count"
    Bilirubin => "bilirubin"
    Creatinine => "creatinine"
    Custom => "custom"
  }
}

///|
pub(all) enum ObservationIssue {
  NegativeTimestamp
  EmptySource
  UnitMismatch
  NonFiniteRange
} derive(Debug, Eq)

///|
pub fn validate_observation(item : Observation) -> ObservationIssue? {
  if item.timestamp_minutes < 0 {
    Some(NegativeTimestamp)
  } else if item.source.length() == 0 {
    Some(EmptySource)
  } else if item.unit == Unknown {
    Some(UnitMismatch)
  } else if item.value < -1000000 || item.value > 1000000 {
    Some(NonFiniteRange)
  } else {
    None
  }
}

///|
pub fn observation_issue_label(issue : ObservationIssue) -> String {
  match issue {
    NegativeTimestamp => "negative timestamp"
    EmptySource => "empty source"
    UnitMismatch => "unknown measurement unit"
    NonFiniteRange => "measurement outside safe integer range"
  }
}

///|
pub(all) struct Timeline {
  observations : Array[Observation]
  last_timestamp_minutes : Int
} derive(Debug, Eq)

///|
pub fn empty_timeline() -> Timeline {
  { observations: [], last_timestamp_minutes: 0 }
}

///|
pub fn timeline_length(timeline : Timeline) -> Int {
  timeline.observations.length()
}

///|
pub fn timeline_add(timeline : Timeline, item : Observation) -> Timeline {
  let next_timestamp = if item.timestamp_minutes >
    timeline.last_timestamp_minutes {
    item.timestamp_minutes
  } else {
    timeline.last_timestamp_minutes
  }
  let observations = timeline.observations.copy()
  observations.push(item)
  { observations, last_timestamp_minutes: next_timestamp }
}

///|
pub fn timeline_valid(timeline : Timeline) -> Bool {
  for i in 0..<timeline.observations.length() {
    if validate_observation(timeline.observations[i]) is Some(_) {
      return false
    }
  }
  true
}

///|
pub fn timeline_latest(timeline : Timeline) -> Observation? {
  if timeline.observations.length() == 0 {
    None
  } else {
    Some(timeline.observations[timeline.observations.length() - 1])
  }
}

///|
pub fn timeline_latest_of(
  timeline : Timeline,
  kind : ObservationKind,
) -> Observation? {
  let mut result : Observation? = None
  for item in timeline.observations {
    if item.kind == kind {
      result = Some(item)
    }
  }
  result
}

///|
pub fn timeline_count_of(timeline : Timeline, kind : ObservationKind) -> Int {
  let mut count = 0
  for item in timeline.observations {
    if item.kind == kind {
      count += 1
    }
  }
  count
}

///|
pub(all) struct Trend {
  kind : ObservationKind
  first_value : Int
  latest_value : Int
  delta : Int
  samples : Int
  rising : Bool
  falling : Bool
  stable : Bool
} derive(Debug, Eq)

///|
pub fn trend_for(timeline : Timeline, kind : ObservationKind) -> Trend? {
  let mut first : Observation? = None
  let mut latest : Observation? = None
  let mut samples = 0
  for item in timeline.observations {
    if item.kind == kind {
      if first is None {
        first = Some(item)
      }
      latest = Some(item)
      samples += 1
    }
  }
  match (first, latest) {
    (Some(first), Some(latest)) => {
      let delta = latest.value - first.value
      Some({
        kind,
        first_value: first.value,
        latest_value: latest.value,
        delta,
        samples,
        rising: delta > 0,
        falling: delta < 0,
        stable: delta == 0,
      })
    }
    _ => None
  }
}

///|
pub fn trend_direction(trend : Trend) -> String {
  if trend.rising {
    "rising"
  } else if trend.falling {
    "falling"
  } else {
    "stable"
  }
}

///|
pub(all) struct TimelineSummary {
  observations : Int
  distinct_kinds : Int
  invalid_observations : Int
  earliest_timestamp : Int
  latest_timestamp : Int
  span_minutes : Int
} derive(Debug, Eq)

///|
pub fn timeline_summary(timeline : Timeline) -> TimelineSummary {
  if timeline.observations.length() == 0 {
    return {
      observations: 0,
      distinct_kinds: 0,
      invalid_observations: 0,
      earliest_timestamp: 0,
      latest_timestamp: 0,
      span_minutes: 0,
    }
  }
  let mut invalid = 0
  let mut earliest = timeline.observations[0].timestamp_minutes
  let mut latest = earliest
  let kinds : Array[ObservationKind] = []
  for item in timeline.observations {
    if validate_observation(item) is Some(_) {
      invalid += 1
    }
    if item.timestamp_minutes < earliest {
      earliest = item.timestamp_minutes
    }
    if item.timestamp_minutes > latest {
      latest = item.timestamp_minutes
    }
    if !kinds.contains(item.kind) {
      kinds.push(item.kind)
    }
  }
  {
    observations: timeline.observations.length(),
    distinct_kinds: kinds.length(),
    invalid_observations: invalid,
    earliest_timestamp: earliest,
    latest_timestamp: latest,
    span_minutes: latest - earliest,
  }
}

///|
pub(all) struct ThresholdBand {
  label : String
  minimum : Int
  maximum : Int
  points : Int
  explanation : String
} derive(Debug, Eq)

///|
pub fn threshold_band(
  label : String,
  minimum : Int,
  maximum : Int,
  points : Int,
  explanation : String,
) -> ThresholdBand {
  { label, minimum, maximum, points, explanation }
}

///|
pub fn threshold_contains(band : ThresholdBand, value : Int) -> Bool {
  value >= band.minimum && value <= band.maximum
}

///|
pub fn threshold_find(
  bands : Array[ThresholdBand],
  value : Int,
) -> ThresholdBand? {
  for band in bands {
    if threshold_contains(band, value) {
      return Some(band)
    }
  }
  None
}

///|
pub fn threshold_points(bands : Array[ThresholdBand], value : Int) -> Int? {
  match threshold_find(bands, value) {
    Some(band) => Some(band.points)
    None => None
  }
}

///|
pub fn threshold_labels(bands : Array[ThresholdBand]) -> Array[String] {
  bands.map(band => band.label)
}

///|
pub(all) struct RuleEvaluation {
  rule_name : String
  value : Int
  matched : Bool
  points : Int
  band : String
  explanation : String
} derive(Debug, Eq)

///|
pub fn evaluate_threshold(
  rule_name : String,
  value : Int,
  bands : Array[ThresholdBand],
) -> RuleEvaluation {
  match threshold_find(bands, value) {
    Some(band) =>
      {
        rule_name,
        value,
        matched: true,
        points: band.points,
        band: band.label,
        explanation: band.explanation,
      }
    None =>
      {
        rule_name,
        value,
        matched: false,
        points: 0,
        band: "unmatched",
        explanation: "Value did not match a declared threshold band",
      }
  }
}

///|
pub fn sum_evaluations(evaluations : Array[RuleEvaluation]) -> Int {
  evaluations.fold(init=0, (sum, item) => sum + item.points)
}

///|
pub fn matched_evaluations(
  evaluations : Array[RuleEvaluation],
) -> Array[RuleEvaluation] {
  evaluations.filter(item => item.matched)
}

///|
pub fn evaluation_labels(evaluations : Array[RuleEvaluation]) -> Array[String] {
  evaluations.map(item => item.band)
}
