///|
test "NEWS2 low aggregate score" {
  let report = @moonbit-triage.score_news2({
    respiratory_rate: 16,
    oxygen_saturation: 98,
    spo2_scale: @moonbit-triage.Scale1,
    supplemental_oxygen: false,
    temperature_tenths_c: 370,
    systolic_bp: 120,
    heart_rate: 72,
    consciousness: @moonbit-triage.Alert,
  })
  inspect(report.score, content="0")
  debug_inspect(report.severity, content="Low")
}

///|
test "NEWS2 detects high concern from aggregate score" {
  let report = @moonbit-triage.score_news2({
    respiratory_rate: 26,
    oxygen_saturation: 90,
    spo2_scale: @moonbit-triage.Scale1,
    supplemental_oxygen: true,
    temperature_tenths_c: 392,
    systolic_bp: 88,
    heart_rate: 134,
    consciousness: @moonbit-triage.Voice,
  })
  inspect(report.score, content="19")
  debug_inspect(report.severity, content="Critical")
}

///|
test "NEWS2 scale two oxygen logic" {
  inspect(
    @moonbit-triage.news2_oxygen_saturation_points(
      97,
      @moonbit-triage.Scale2,
      true,
    ),
    content="3",
  )
  inspect(
    @moonbit-triage.news2_oxygen_saturation_points(
      97,
      @moonbit-triage.Scale2,
      false,
    ),
    content="0",
  )
}

///|
test "qSOFA criteria add independently" {
  let report = @moonbit-triage.score_qsofa({
    respiratory_rate: 24,
    systolic_bp: 100,
    gcs_total: 14,
  })
  inspect(report.score, content="3")
  debug_inspect(report.severity, content="High")
}

///|
test "GCS component total and severity" {
  let report = @moonbit-triage.score_gcs({ eye: 3, verbal: 4, motor: 6 })
  inspect(report.total, content="13")
  debug_inspect(report.severity, content="Medium")
}

///|
test "combined triage uses highest concern level" {
  let bundle = @moonbit-triage.score_triage({
    news2: {
      respiratory_rate: 23,
      oxygen_saturation: 96,
      spo2_scale: @moonbit-triage.Scale1,
      supplemental_oxygen: false,
      temperature_tenths_c: 370,
      systolic_bp: 118,
      heart_rate: 96,
      consciousness: @moonbit-triage.Alert,
    },
    gcs: { eye: 4, verbal: 5, motor: 6 },
  })
  inspect(bundle.news2.score, content="3")
  inspect(bundle.qsofa.score, content="1")
  debug_inspect(
    bundle.overall,
    content=(
      #|Medium
    ),
  )
}

///|
test "validation reports first out of range field" {
  let err = @moonbit-triage.validate_gcs({ eye: 0, verbal: 5, motor: 6 })
  debug_inspect(
    err,
    content="Some(OutOfRange(field=\"eye\", value=0, min=1, max=4))",
  )
}
