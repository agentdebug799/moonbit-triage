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

///|
test "display helpers produce stable labels" {
  inspect(
    @moonbit-triage.severity_label(@moonbit-triage.Critical),
    content="critical",
  )
  let err = @moonbit-triage.ValidationError::OutOfRange(
    field="heart_rate",
    value=260,
    min=0,
    max=250,
  )
  inspect(@moonbit-triage.validation_error_field(err), content="heart_rate")
  inspect(
    @moonbit-triage.validation_error_message(err),
    content="heart_rate value 260 is outside the accepted range 0..250",
  )
}

///|
test "SIRS counts independent criteria" {
  let report = @moonbit-triage.score_sirs({
    temperature_tenths_c: 391,
    heart_rate: 101,
    respiratory_rate: 21,
    white_cell_count: 13,
    immature_neutrophils_percent: 0,
  })
  inspect(report.score, content="4")
  debug_inspect(report.severity, content="High")
}

///|
test "MEWS thresholds are inclusive at band edges" {
  let report = @moonbit-triage.score_mews({
    systolic_bp: 70,
    heart_rate: 130,
    respiratory_rate: 29,
    temperature_tenths_c: 350,
    consciousness: @moonbit-triage.Voice,
  })
  inspect(report.score, content="11")
  debug_inspect(report.severity, content="Critical")
}

///|
test "SOFA aggregates six organ domains" {
  let report = @moonbit-triage.score_sofa({
    pao2_fio2: 90,
    respiratory_support: true,
    platelets: 19,
    bilirubin_micromol: 210,
    mean_arterial_pressure: 55,
    vasopressor: @moonbit-triage.NorepinephrineHigh,
    gcs_total: 5,
    creatinine_micromol: 450,
    urine_ml_day: 150,
  })
  inspect(report.score, content="24")
  debug_inspect(report.severity, content="Critical")
}

///|
test "PEWS records pediatric domains" {
  let report = @moonbit-triage.score_pews({
    behavior: @moonbit-triage.Lethargic,
    cardiovascular: @moonbit-triage.Tachycardic,
    respiratory: @moonbit-triage.SevereDistress,
    oxygen_support: @moonbit-triage.HighFlow,
    nebulizer_count: 4,
  })
  inspect(report.score, content="12")
  debug_inspect(report.severity, content="Critical")
}

///|
test "batch summary is deterministic for empty and mixed inputs" {
  let empty = @moonbit-triage.summarize_reports([])
  inspect(empty.count, content="0")
  inspect(empty.total_score, content="0")
  let reports = [
    @moonbit-triage.score_qsofa({
      respiratory_rate: 22,
      systolic_bp: 120,
      gcs_total: 15,
    }),
    @moonbit-triage.score_sirs({
      temperature_tenths_c: 370,
      heart_rate: 80,
      respiratory_rate: 16,
      white_cell_count: 7,
      immature_neutrophils_percent: 0,
    }),
  ]
  let summary = @moonbit-triage.summarize_reports(reports)
  inspect(summary.count, content="2")
  inspect(summary.total_score, content="1")
  debug_inspect(summary.highest, content="Medium")
}

///|
test "CURB-65 counts all five criteria" {
  let report = @moonbit-triage.score_curbs65({
    confusion: true,
    urea_mmol: 8,
    respiratory_rate: 30,
    systolic_bp: 89,
    diastolic_bp: 60,
    age: 65,
  })
  inspect(report.score, content="5")
  debug_inspect(report.severity, content="Critical")
}

///|
test "ratio scores preserve deterministic integer scaling" {
  inspect(
    @moonbit-triage.shock_index_x100({ heart_rate: 120, systolic_bp: 100 }),
    content="120",
  )
  inspect(
    @moonbit-triage.rox_x100({
      oxygen_saturation: 95,
      fio2_percent: 50,
      respiratory_rate: 20,
    }),
    content="950",
  )
}

///|
test "quality summary distinguishes usable boundaries" {
  let flags = [
    @moonbit-triage.quality_for_int("hr", 80, 0, 200),
    @moonbit-triage.quality_for_int("bp", 0, 0, 200),
    @moonbit-triage.quality_for_optional("temp", None),
    @moonbit-triage.quality_for_int("spo2", 110, 0, 100),
  ]
  let summary = @moonbit-triage.summarize_quality(flags)
  inspect(summary.total, content="4")
  inspect(summary.complete, content="1")
  inspect(summary.suspicious, content="1")
  inspect(summary.missing, content="1")
  inspect(summary.out_of_range, content="1")
  assert_true(@moonbit-triage.quality_is_usable(flags[1]))
  assert_true(!@moonbit-triage.quality_is_usable(flags[2]))
}
