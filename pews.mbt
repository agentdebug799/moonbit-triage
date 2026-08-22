///|
pub(all) enum PewsBehavior {
  Playing
  Sleeping
  Irritable
  Lethargic
} derive(Debug, Eq)

///|
pub(all) enum PewsCardiovascular {
  Normal
  Tachycardic
  PoorPerfusion
} derive(Debug, Eq)

///|
pub(all) enum PewsRespiratory {
  Normal
  ModerateDistress
  SevereDistress
} derive(Debug, Eq)

///|
pub(all) enum PewsOxygenSupport {
  RoomAir
  LowFlow
  HighFlow
} derive(Debug, Eq)

///|
pub(all) struct PewsInput {
  behavior : PewsBehavior
  cardiovascular : PewsCardiovascular
  respiratory : PewsRespiratory
  oxygen_support : PewsOxygenSupport
  nebulizer_count : Int
} derive(Debug, Eq)

///|
pub fn validate_pews(input : PewsInput) -> ValidationError? {
  validate_range("nebulizer_count", input.nebulizer_count, 0, 100)
}

///|
pub fn pews_behavior_points(value : PewsBehavior) -> Int {
  match value {
    Playing | Sleeping => 0
    Irritable => 2
    Lethargic => 3
  }
}

///|
pub fn pews_cardiovascular_points(value : PewsCardiovascular) -> Int {
  match value {
    Normal => 0
    Tachycardic => 2
    PoorPerfusion => 3
  }
}

///|
pub fn pews_respiratory_points(value : PewsRespiratory) -> Int {
  match value {
    Normal => 0
    ModerateDistress => 2
    SevereDistress => 3
  }
}

///|
pub fn pews_oxygen_points(value : PewsOxygenSupport) -> Int {
  match value {
    RoomAir => 0
    LowFlow => 2
    HighFlow => 3
  }
}

///|
pub fn pews_nebulizer_points(value : Int) -> Int {
  if value >= 4 {
    1
  } else if value >= 1 {
    0
  } else {
    0
  }
}

///|
pub fn pews_severity(score : Int) -> Severity {
  if score >= 9 {
    Critical
  } else if score >= 6 {
    High
  } else if score >= 3 {
    Medium
  } else {
    Low
  }
}

///|
pub fn score_pews(input : PewsInput) -> ScoreReport {
  let behavior = pews_behavior_points(input.behavior)
  let cardiovascular = pews_cardiovascular_points(input.cardiovascular)
  let respiratory = pews_respiratory_points(input.respiratory)
  let oxygen = pews_oxygen_points(input.oxygen_support)
  let nebulizer = pews_nebulizer_points(input.nebulizer_count)
  let score = behavior + cardiovascular + respiratory + oxygen + nebulizer
  report(
    "PEWS",
    score,
    pews_severity(score),
    "PEWS is an age- and pathway-dependent pediatric early-warning aid; confirm local band definitions.",
    [
      explanation("Behavior", behavior, "Behavior and interaction band"),
      explanation("Cardiovascular", cardiovascular, "Pulse and perfusion band"),
      explanation("Respiratory", respiratory, "Work-of-breathing band"),
      explanation("Oxygen support", oxygen, "Respiratory support band"),
      explanation("Nebulizer use", nebulizer, "Nebulizer-frequency modifier"),
    ],
  )
}
