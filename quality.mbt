///|
pub(all) enum MeasurementQuality {
  Complete
  Missing
  OutOfRange
  Suspicious
} derive(Debug, Eq)

///|
pub(all) struct QualityFlag {
  field : String
  quality : MeasurementQuality
  message : String
} derive(Debug, Eq)

///|
pub fn quality_flag(
  field : String,
  quality : MeasurementQuality,
  message : String,
) -> QualityFlag {
  { field, quality, message }
}

///|
pub fn quality_for_int(
  field : String,
  value : Int,
  min : Int,
  max : Int,
) -> QualityFlag {
  if value < min || value > max {
    quality_flag(
      field,
      OutOfRange,
      "value is outside the declared measurement range",
    )
  } else if value == min || value == max {
    quality_flag(
      field,
      Suspicious,
      "value is accepted but lies on the measurement boundary",
    )
  } else {
    quality_flag(
      field,
      Complete,
      "value is inside the declared measurement range",
    )
  }
}

///|
pub fn quality_for_optional(field : String, value : Int?) -> QualityFlag {
  match value {
    None => quality_flag(field, Missing, "required measurement is absent")
    Some(_) => quality_flag(field, Complete, "measurement is present")
  }
}

///|
pub fn quality_is_usable(flag : QualityFlag) -> Bool {
  match flag.quality {
    Complete | Suspicious => true
    Missing | OutOfRange => false
  }
}

///|
pub fn quality_label(quality : MeasurementQuality) -> String {
  match quality {
    Complete => "complete"
    Missing => "missing"
    OutOfRange => "out-of-range"
    Suspicious => "suspicious"
  }
}

///|
pub(all) struct QualitySummary {
  total : Int
  complete : Int
  missing : Int
  out_of_range : Int
  suspicious : Int
} derive(Debug, Eq)

///|
pub fn summarize_quality(flags : Array[QualityFlag]) -> QualitySummary {
  let mut complete = 0
  let mut missing = 0
  let mut out_of_range = 0
  let mut suspicious = 0
  for flag in flags {
    match flag.quality {
      Complete => complete += 1
      Missing => missing += 1
      OutOfRange => out_of_range += 1
      Suspicious => suspicious += 1
    }
  }
  { total: flags.length(), complete, missing, out_of_range, suspicious }
}

///|
pub fn quality_for_news2(input : News2Input) -> Array[QualityFlag] {
  [
    quality_for_int("respiratory_rate", input.respiratory_rate, 0, 80),
    quality_for_int("oxygen_saturation", input.oxygen_saturation, 0, 100),
    quality_for_int(
      "temperature_tenths_c",
      input.temperature_tenths_c,
      250,
      450,
    ),
    quality_for_int("systolic_bp", input.systolic_bp, 40, 300),
    quality_for_int("heart_rate", input.heart_rate, 0, 250),
  ]
}
