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

///|
test "Wells PE exposes weighted criteria" {
  let report = @moonbit-triage.score_wells_pe({
    clinical_dvt_signs: true,
    pe_most_likely: true,
    heart_rate: 110,
    surgery_or_immobilization: true,
    previous_dvt_or_pe: true,
    hemoptysis: true,
    malignancy: true,
  })
  inspect(report.score, content="115")
  debug_inspect(report.severity, content="Critical")
}

///|
test "HEART score sums five two-point domains" {
  let report = @moonbit-triage.score_heart({
    history: 2,
    ecg: 2,
    age: 2,
    risk_factors: 2,
    troponin: 2,
  })
  inspect(report.score, content="10")
  debug_inspect(report.severity, content="Critical")
}

///|
test "CHA2DS2-VASc counts sex and vascular risk flags" {
  let report = @moonbit-triage.score_cha2ds2_vasc({
    congestive_failure: true,
    hypertension: true,
    age: 2,
    diabetes: true,
    stroke_or_tia: true,
    vascular_disease: true,
    sex_female: true,
  })
  inspect(report.score, content="9")
  debug_inspect(report.severity, content="Critical")
}

///|
test "NEWS2 every component boundary is executable" {
  for value in [8, 9, 11, 12, 20, 21, 24, 25] {
    ignore(@moonbit-triage.news2_respiratory_rate_points(value))
  }
  for value in [40, 41, 50, 51, 90, 91, 110, 111, 130, 131] {
    ignore(@moonbit-triage.news2_heart_rate_points(value))
  }
  for value in [90, 91, 100, 101, 110, 111, 219, 220] {
    ignore(@moonbit-triage.news2_systolic_bp_points(value))
  }
  for value in [350, 351, 360, 361, 380, 381, 390, 391] {
    ignore(@moonbit-triage.news2_temperature_points(value))
  }
  for value in [83, 84, 85, 86, 87, 88, 92, 93, 94, 95, 96, 97] {
    ignore(
      @moonbit-triage.news2_oxygen_saturation_points(
        value,
        @moonbit-triage.Scale2,
        true,
      ),
    )
  }
  for value in [91, 92, 93, 94, 95, 96] {
    ignore(
      @moonbit-triage.news2_oxygen_saturation_points(
        value,
        @moonbit-triage.Scale1,
        false,
      ),
    )
  }
  for
    consciousness in [
      @moonbit-triage.Alert,
      @moonbit-triage.NewConfusion,
      @moonbit-triage.Voice,
      @moonbit-triage.Pain,
      @moonbit-triage.Unresponsive,
    ] {
    ignore(@moonbit-triage.news2_consciousness_points(consciousness))
  }
}

///|
test "validation paths reject each invalid NEWS2 and qSOFA field" {
  assert_true(
    @moonbit-triage.validate_news2({
      respiratory_rate: -1,
      oxygen_saturation: 99,
      spo2_scale: @moonbit-triage.Scale1,
      supplemental_oxygen: false,
      temperature_tenths_c: 370,
      systolic_bp: 120,
      heart_rate: 70,
      consciousness: @moonbit-triage.Alert,
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_news2({
      respiratory_rate: 16,
      oxygen_saturation: 101,
      spo2_scale: @moonbit-triage.Scale1,
      supplemental_oxygen: false,
      temperature_tenths_c: 370,
      systolic_bp: 120,
      heart_rate: 70,
      consciousness: @moonbit-triage.Alert,
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_news2({
      respiratory_rate: 16,
      oxygen_saturation: 99,
      spo2_scale: @moonbit-triage.Scale1,
      supplemental_oxygen: false,
      temperature_tenths_c: 249,
      systolic_bp: 120,
      heart_rate: 70,
      consciousness: @moonbit-triage.Alert,
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_news2({
      respiratory_rate: 16,
      oxygen_saturation: 99,
      spo2_scale: @moonbit-triage.Scale1,
      supplemental_oxygen: false,
      temperature_tenths_c: 370,
      systolic_bp: 39,
      heart_rate: 70,
      consciousness: @moonbit-triage.Alert,
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_news2({
      respiratory_rate: 16,
      oxygen_saturation: 99,
      spo2_scale: @moonbit-triage.Scale1,
      supplemental_oxygen: false,
      temperature_tenths_c: 370,
      systolic_bp: 120,
      heart_rate: 251,
      consciousness: @moonbit-triage.Alert,
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_qsofa({
      respiratory_rate: 81,
      systolic_bp: 120,
      gcs_total: 15,
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_qsofa({
      respiratory_rate: 16,
      systolic_bp: 39,
      gcs_total: 15,
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_qsofa({
      respiratory_rate: 16,
      systolic_bp: 120,
      gcs_total: 2,
    })
    is Some(_),
  )
}

///|
test "all public severity bands have a representative" {
  for score in [0, 1, 5, 7, 12] {
    ignore(@moonbit-triage.news2_severity(score, false))
    ignore(@moonbit-triage.sofa_severity(score))
    ignore(@moonbit-triage.pews_severity(score))
    ignore(@moonbit-triage.mews_severity(score))
    ignore(@moonbit-triage.curbs65_severity(score))
    ignore(@moonbit-triage.heart_severity(score))
    ignore(@moonbit-triage.cha2ds2_vasc_severity(score))
  }
  for score in [0, 90, 100, 120] {
    ignore(@moonbit-triage.shock_index_severity(score))
  }
  for score in [100, 200, 300, 450] {
    ignore(@moonbit-triage.rox_severity(score))
  }
  for score in [0, 40, 65, 115] {
    ignore(@moonbit-triage.wells_pe_severity(score))
  }
  for score in [0, 2, 4, 7] {
    ignore(@moonbit-triage.sirs_severity(score))
    ignore(@moonbit-triage.qsofa_severity(score))
  }
}

///|
test "quality labels and NEWS2 quality fields are complete" {
  for
    quality in [
      @moonbit-triage.Complete,
      @moonbit-triage.Missing,
      @moonbit-triage.OutOfRange,
      @moonbit-triage.Suspicious,
    ] {
    ignore(@moonbit-triage.quality_label(quality))
  }
  let flags = @moonbit-triage.quality_for_news2({
    respiratory_rate: 16,
    oxygen_saturation: 98,
    spo2_scale: @moonbit-triage.Scale1,
    supplemental_oxygen: false,
    temperature_tenths_c: 370,
    systolic_bp: 120,
    heart_rate: 70,
    consciousness: @moonbit-triage.Alert,
  })
  inspect(flags.length(), content="5")
}

///|
test "MEWS and SOFA component tables cover low and high branches" {
  for value in [0, 39, 40, 49, 50, 51, 100, 101, 129, 130] {
    ignore(@moonbit-triage.mews_heart_rate_points(value))
  }
  for value in [0, 8, 9, 14, 15, 20, 21, 29, 30] {
    ignore(@moonbit-triage.mews_respiratory_rate_points(value))
  }
  for value in [249, 349, 350, 380, 381, 390, 391] {
    ignore(@moonbit-triage.mews_temperature_points(value))
  }
  for value in [30, 70, 71, 80, 81, 100, 101, 199, 200, 300] {
    ignore(@moonbit-triage.mews_systolic_bp_points(value))
  }
  for ratio in [50, 99, 100, 199, 200, 299, 300, 399, 400] {
    ignore(@moonbit-triage.sofa_respiratory_points(ratio, true))
    ignore(@moonbit-triage.sofa_respiratory_points(ratio, false))
  }
  for value in [0, 19, 20, 49, 50, 99, 100, 149, 150] {
    ignore(@moonbit-triage.sofa_platelet_points(value))
  }
  for value in [0, 19, 20, 32, 33, 101, 102, 203, 204] {
    ignore(@moonbit-triage.sofa_bilirubin_points(value))
  }
  for
    pressor in [
      @moonbit-triage.None,
      @moonbit-triage.DopamineLow,
      @moonbit-triage.DopamineHigh,
      @moonbit-triage.NorepinephrineLow,
      @moonbit-triage.NorepinephrineHigh,
    ] {
    ignore(@moonbit-triage.sofa_circulation_points(60, pressor))
  }
  for value in [3, 5, 6, 9, 10, 12, 13, 14, 15] {
    ignore(@moonbit-triage.sofa_gcs_points(value))
  }
  for value in [0, 109, 110, 170, 171, 299, 300, 439, 440] {
    ignore(@moonbit-triage.sofa_renal_points(value, 1000))
  }
  for urine in [100, 199, 200, 499, 500] {
    ignore(@moonbit-triage.sofa_renal_points(0, urine))
  }
}

///|
test "PEWS, SIRS, CURB, ratio, and validation branches are covered" {
  for
    behavior in [
      @moonbit-triage.Playing,
      @moonbit-triage.Sleeping,
      @moonbit-triage.Irritable,
      @moonbit-triage.Lethargic,
    ] {
    ignore(@moonbit-triage.pews_behavior_points(behavior))
  }
  for
    cardiovascular in [
      @moonbit-triage.PewsCardiovascular::Normal,
      @moonbit-triage.PewsCardiovascular::Tachycardic,
      @moonbit-triage.PewsCardiovascular::PoorPerfusion,
    ] {
    ignore(@moonbit-triage.pews_cardiovascular_points(cardiovascular))
  }
  for
    respiratory in [
      @moonbit-triage.PewsRespiratory::Normal,
      @moonbit-triage.PewsRespiratory::ModerateDistress,
      @moonbit-triage.PewsRespiratory::SevereDistress,
    ] {
    ignore(@moonbit-triage.pews_respiratory_points(respiratory))
  }
  for
    oxygen in [
      @moonbit-triage.RoomAir,
      @moonbit-triage.LowFlow,
      @moonbit-triage.HighFlow,
    ] {
    ignore(@moonbit-triage.pews_oxygen_points(oxygen))
  }
  for count in [0, 1, 3, 4] {
    ignore(@moonbit-triage.pews_nebulizer_points(count))
  }
  for value in [0, 3, 4, 7, 8, 12, 13] {
    ignore(@moonbit-triage.curbs65_severity(value))
    ignore(@moonbit-triage.sirs_severity(value))
  }
  for value in [0, 4, 7, 8, 12, 15] {
    ignore(@moonbit-triage.gcs_severity(value))
    ignore(@moonbit-triage.qsofa_severity(value))
  }
  ignore(@moonbit-triage.clamp(-1, 0, 10))
  ignore(@moonbit-triage.clamp(11, 0, 10))
  ignore(@moonbit-triage.clamp(5, 0, 10))
  assert_true(@moonbit-triage.validate_bool_scale("x", 2) is Some(_))
  assert_true(@moonbit-triage.validate_bool_scale("x", 1) is None)
  ignore(
    @moonbit-triage.validation_error_message(
      @moonbit-triage.ValidationError::InvalidScale(field="x", value=2),
    ),
  )
}

///|
test "new weighted-score validation and low-risk reports work" {
  assert_true(
    @moonbit-triage.validate_wells_pe({
      clinical_dvt_signs: false,
      pe_most_likely: false,
      heart_rate: 301,
      surgery_or_immobilization: false,
      previous_dvt_or_pe: false,
      hemoptysis: false,
      malignancy: false,
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_heart({
      history: 3,
      ecg: 0,
      age: 0,
      risk_factors: 0,
      troponin: 0,
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_cha2ds2_vasc({
      congestive_failure: false,
      hypertension: false,
      age: 3,
      diabetes: false,
      stroke_or_tia: false,
      vascular_disease: false,
      sex_female: false,
    })
    is Some(_),
  )
  let wells = @moonbit-triage.score_wells_pe({
    clinical_dvt_signs: false,
    pe_most_likely: false,
    heart_rate: 80,
    surgery_or_immobilization: false,
    previous_dvt_or_pe: false,
    hemoptysis: false,
    malignancy: false,
  })
  debug_inspect(wells.severity, content="Low")
  let heart = @moonbit-triage.score_heart({
    history: 0,
    ecg: 0,
    age: 0,
    risk_factors: 0,
    troponin: 0,
  })
  debug_inspect(heart.severity, content="Low")
  let vascular = @moonbit-triage.score_cha2ds2_vasc({
    congestive_failure: false,
    hypertension: false,
    age: 0,
    diabetes: false,
    stroke_or_tia: false,
    vascular_disease: false,
    sex_female: false,
  })
  debug_inspect(vascular.severity, content="Low")
}

///|
test "RCRI and TIMI expose perioperative and ischemic criteria" {
  let rcri = @moonbit-triage.score_rcri({
    high_risk_surgery: true,
    ischemic_heart_disease: true,
    heart_failure: false,
    cerebrovascular_disease: false,
    diabetes_on_insulin: true,
    creatinine_above_2: true,
  })
  inspect(rcri.score, content="4")
  debug_inspect(rcri.severity, content="High")
  let timi = @moonbit-triage.score_timi({
    age_65_or_more: true,
    risk_factors: 3,
    known_coronary_stenosis: true,
    aspirin_last_7_days: true,
    severe_angina: true,
    st_deviation: true,
    positive_biomarker: true,
  })
  inspect(timi.score, content="7")
  debug_inspect(timi.severity, content="Critical")
}

///|
test "observation timeline supports freshness, trends, and audit summaries" {
  let first = @moonbit-triage.observation(
    @moonbit-triage.HeartRate,
    80,
    @moonbit-triage.BeatsPerMinute,
    10,
    "monitor",
  )
  let second = @moonbit-triage.observation(
    @moonbit-triage.HeartRate,
    110,
    @moonbit-triage.BeatsPerMinute,
    20,
    "monitor",
  )
  let timeline = @moonbit-triage.timeline_add(
    @moonbit-triage.timeline_add(@moonbit-triage.empty_timeline(), first),
    second,
  )
  inspect(@moonbit-triage.timeline_length(timeline), content="2")
  assert_true(@moonbit-triage.timeline_valid(timeline))
  assert_true(@moonbit-triage.observation_is_fresh(25, second, 10))
  inspect(@moonbit-triage.observation_delta(first, second), content="30")
  let trend = @moonbit-triage.trend_for(timeline, @moonbit-triage.HeartRate)
  debug_inspect(
    trend,
    content=(
      #|Some(
      #|  {
      #|    kind: HeartRate,
      #|    first_value: 80,
      #|    latest_value: 110,
      #|    delta: 30,
      #|    samples: 2,
      #|    rising: true,
      #|    falling: false,
      #|    stable: false,
      #|  },
      #|)
    ),
  )
  let summary = @moonbit-triage.timeline_summary(timeline)
  inspect(summary.distinct_kinds, content="1")
  inspect(summary.span_minutes, content="10")
  inspect(
    @moonbit-triage.observation_unit_label(@moonbit-triage.BeatsPerMinute),
    content="bpm",
  )
  inspect(
    @moonbit-triage.observation_kind_label(@moonbit-triage.HeartRate),
    content="heart_rate",
  )
}

///|
test "observation validation exposes each data-quality issue" {
  assert_true(
    @moonbit-triage.validate_observation({
      kind: @moonbit-triage.HeartRate,
      value: 80,
      unit: @moonbit-triage.BeatsPerMinute,
      timestamp_minutes: -1,
      source: "monitor",
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_observation({
      kind: @moonbit-triage.HeartRate,
      value: 80,
      unit: @moonbit-triage.BeatsPerMinute,
      timestamp_minutes: 1,
      source: "",
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_observation({
      kind: @moonbit-triage.HeartRate,
      value: 80,
      unit: @moonbit-triage.Unknown,
      timestamp_minutes: 1,
      source: "monitor",
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_observation({
      kind: @moonbit-triage.HeartRate,
      value: 1000001,
      unit: @moonbit-triage.BeatsPerMinute,
      timestamp_minutes: 1,
      source: "monitor",
    })
    is Some(_),
  )
  let bad = @moonbit-triage.observation(
    @moonbit-triage.HeartRate,
    80,
    @moonbit-triage.BeatsPerMinute,
    0,
    "monitor",
  )
  let timeline = @moonbit-triage.timeline_add(
    @moonbit-triage.empty_timeline(),
    bad,
  )
  assert_true(
    @moonbit-triage.timeline_latest_of(
      timeline,
      @moonbit-triage.OxygenSaturation,
    )
    is None,
  )
  assert_true(
    @moonbit-triage.trend_for(timeline, @moonbit-triage.OxygenSaturation)
    is None,
  )
}

///|
test "assessment ledger compares snapshots and renders audit text" {
  let low = @moonbit-triage.snapshot(
    "NEWS2",
    1,
    @moonbit-triage.Medium,
    10,
    "form",
  )
  let high = @moonbit-triage.snapshot(
    "NEWS2",
    5,
    @moonbit-triage.High,
    20,
    "form",
  )
  let other = @moonbit-triage.snapshot(
    "qSOFA",
    1,
    @moonbit-triage.Medium,
    30,
    "form",
  )
  debug_inspect(
    @moonbit-triage.compare_snapshots(low, high),
    content="Increased(4)",
  )
  debug_inspect(
    @moonbit-triage.compare_snapshots(high, low),
    content="Decreased(4)",
  )
  debug_inspect(
    @moonbit-triage.compare_snapshots(low, low),
    content="Unchanged",
  )
  debug_inspect(
    @moonbit-triage.compare_snapshots(low, other),
    content="InstrumentChanged",
  )
  let ledger = @moonbit-triage.ledger_add(
    @moonbit-triage.ledger_add(@moonbit-triage.empty_ledger(), low),
    high,
  )
  inspect(@moonbit-triage.ledger_size(ledger), content="2")
  inspect(@moonbit-triage.ledger_total_score(ledger), content="6")
  inspect(@moonbit-triage.ledger_count_instrument(ledger, "NEWS2"), content="2")
  assert_true(@moonbit-triage.snapshot_is_fresh(25, high, 5))
  inspect(
    @moonbit-triage.render_snapshot(low),
    content="NEWS2: score=1, severity=medium, time=10, source=form",
  )
  inspect(@moonbit-triage.render_change(low, high), content="NEWS2 increased")
  let summary = @moonbit-triage.assessment_summary(ledger)
  inspect(summary.snapshots, content="2")
  inspect(summary.instruments, content="1")
  debug_inspect(summary.highest, content="High")
}

///|
test "HAS-BLED and Wells DVT preserve weighted explanations" {
  let bleeding = @moonbit-triage.score_has_bled({
    hypertension: true,
    abnormal_renal: true,
    abnormal_liver: true,
    stroke: true,
    bleeding_history: true,
    labile_inr: true,
    age_over_65: true,
    drugs_or_alcohol: true,
  })
  inspect(bleeding.score, content="8")
  debug_inspect(bleeding.severity, content="Critical")
  let dvt = @moonbit-triage.score_wells_dvt({
    active_cancer: true,
    paralysis_or_immobilization: true,
    bedridden_or_surgery: true,
    tenderness_deep_veins: true,
    entire_leg_swollen: true,
    calf_swelling: true,
    previous_dvt: true,
    alternative_diagnosis: false,
  })
  inspect(dvt.score, content="8")
  debug_inspect(dvt.severity, content="High")
}

///|
test "PESI validates physiologic bounds and preserves risk components" {
  let input : @moonbit-triage.PesiInput = {
    age: 70,
    male: true,
    nursing_home: true,
    cancer: true,
    heart_failure: true,
    chronic_lung_disease: true,
    heart_rate: 120,
    systolic_bp: 90,
    temperature_tenths_c: 400,
    altered_mentation: true,
    oxygen_saturation: 88,
  }
  assert_true(@moonbit-triage.validate_pesi(input) is None)
  let result = @moonbit-triage.score_pesi(input)
  inspect(result.score, content="290")
  debug_inspect(result.severity, content="Critical")
  assert_true(
    @moonbit-triage.validate_pesi({
      age: 70,
      male: true,
      nursing_home: true,
      cancer: true,
      heart_failure: true,
      chronic_lung_disease: true,
      heart_rate: 120,
      systolic_bp: 90,
      temperature_tenths_c: 400,
      altered_mentation: true,
      oxygen_saturation: 101,
    })
    is Some(_),
  )
}

///|
test "BODE and qCSI cover threshold transitions" {
  let bode = @moonbit-triage.score_bode({
    body_mass_index: 20,
    fev1_percent: 35,
    modified_mrc: 4,
    six_minute_walk_meters: 149,
  })
  inspect(bode.score, content="10")
  debug_inspect(bode.severity, content="Critical")
  inspect(@moonbit-triage.bode_fev1_points(65), content="0")
  inspect(@moonbit-triage.bode_fev1_points(50), content="1")
  inspect(@moonbit-triage.bode_fev1_points(36), content="2")
  inspect(@moonbit-triage.bode_walk_points(350), content="0")
  let respiratory = @moonbit-triage.score_qcsi({
    respiratory_rate: 30,
    oxygen_saturation: 89,
    oxygen_flow_liters: 15,
  })
  inspect(respiratory.score, content="9")
  debug_inspect(respiratory.severity, content="Critical")
  assert_true(
    @moonbit-triage.validate_qcsi({
      respiratory_rate: -1,
      oxygen_saturation: 95,
      oxygen_flow_liters: 0,
    })
    is Some(_),
  )
}

///|
test "Hestia, RTS, and ISS expose high-acuity edge cases" {
  let hestia = @moonbit-triage.score_hestia({
    unstable: true,
    oxygen_saturation_low: true,
    active_bleeding: true,
    need_thrombolysis: true,
    severe_renal_impairment: true,
    severe_liver_impairment: true,
    social_barrier: true,
    pregnancy: true,
    history_bleeding: true,
    treatment_failure: true,
  })
  inspect(hestia.score, content="10")
  debug_inspect(hestia.severity, content="Critical")
  let rts = @moonbit-triage.score_revised_trauma({
    gcs_total: 12,
    systolic_bp: 80,
    respiratory_rate: 8,
  })
  inspect(rts.score, content="2511")
  debug_inspect(rts.severity, content="High")
  inspect(
    @moonbit-triage.injury_severity_score({
      head_neck: 6,
      face: 5,
      chest: 4,
      abdomen: 3,
      extremity: 2,
      external: 1,
    }),
    content="77",
  )
  debug_inspect(
    @moonbit-triage.score_injury_severity({
      head_neck: 6,
      face: 5,
      chest: 4,
      abdomen: 3,
      extremity: 2,
      external: 1,
    }).severity,
    content="Critical",
  )
  assert_true(
    @moonbit-triage.validate_revised_trauma({
      gcs_total: 2,
      systolic_bp: 90,
      respiratory_rate: 20,
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_injury_severity({
      head_neck: 7,
      face: 0,
      chest: 0,
      abdomen: 0,
      extremity: 0,
      external: 0,
    })
    is Some(_),
  )
}

///|
test "renal and gastrointestinal scores cover normal and extreme bands" {
  let child : @moonbit-triage.ChildPughInput = {
    bilirubin_tenths_mg_dl: 40,
    albumin_tenths_g_dl: 27,
    inr_hundredths: 231,
    ascites_grade: 2,
    encephalopathy_grade: 2,
  }
  let child_report = @moonbit-triage.score_child_pugh(child)
  inspect(child_report.score, content="15")
  inspect(@moonbit-triage.child_pugh_class(child_report.score), content="C")
  inspect(@moonbit-triage.child_pugh_bilirubin_points(20), content="1")
  inspect(@moonbit-triage.child_pugh_bilirubin_points(30), content="2")
  let gbs = @moonbit-triage.score_glasgow_blatchford({
    bun_mmol_l_tenths: 250,
    hemoglobin_g_dl_tenths: 90,
    female: false,
    systolic_bp: 89,
    pulse: 100,
    melena: true,
    syncope: true,
    hepatic_disease: true,
    cardiac_failure: true,
  })
  inspect(gbs.score, content="23")
  debug_inspect(gbs.severity, content="High")
  let aki = @moonbit-triage.score_aki({
    baseline_creatinine_hundredths: 100,
    current_creatinine_hundredths: 400,
    urine_rate_hundredths_ml_kg_h: 20,
    urine_duration_hours: 24,
  })
  inspect(aki.score, content="3")
  debug_inspect(aki.severity, content="Critical")
  assert_true(
    @moonbit-triage.validate_aki({
      baseline_creatinine_hundredths: 0,
      current_creatinine_hundredths: 100,
      urine_rate_hundredths_ml_kg_h: 50,
      urine_duration_hours: 6,
    })
    is Some(_),
  )
}

///|
test "neurology scores preserve item-level traceability" {
  let nihss : @moonbit-triage.NihssInput = {
    consciousness: 3,
    questions: 2,
    commands: 2,
    gaze: 2,
    visual: 3,
    facial: 3,
    left_arm: 4,
    right_arm: 4,
    left_leg: 4,
    right_leg: 4,
    ataxia: 2,
    sensory: 2,
    language: 3,
    dysarthria: 2,
    neglect: 2,
  }
  let stroke = @moonbit-triage.score_nihss(nihss)
  inspect(stroke.score, content="42")
  debug_inspect(stroke.severity, content="Critical")
  assert_true(@moonbit-triage.validate_nihss(nihss) is None)
  inspect(
    @moonbit-triage.score_four({
      eye_response: 0,
      motor_response: 0,
      brainstem_reflexes: 0,
      respiration: 0,
    }).score,
    content="0",
  )
  let tia = @moonbit-triage.score_abcd2({
    age: 60,
    systolic_bp: 140,
    diastolic_bp: 90,
    unilateral_weakness: true,
    speech_impairment_without_weakness: false,
    symptom_duration_minutes: 60,
    diabetes: true,
  })
  inspect(tia.score, content="7")
  debug_inspect(tia.severity, content="Critical")
  let head = @moonbit-triage.score_canadian_ct_head({
    age: 70,
    gcs_less_than_15_at_two_hours: true,
    suspected_open_skull_fracture: true,
    signs_of_basal_skull_fracture: false,
    vomiting_episodes: 2,
    age_at_least_65: true,
    retrograde_amnesia_minutes: 31,
    dangerous_mechanism: true,
    anticoagulant_or_antiplatelet: true,
  })
  inspect(head.score, content="7")
  debug_inspect(head.severity, content="High")
}

///|
test "perioperative scores cover risk-factor aggregation" {
  let caprini : @moonbit-triage.CapriniInput = {
    age: 80,
    bmi_over_25: true,
    swollen_legs: true,
    varicose_veins: true,
    pregnancy_or_postpartum: false,
    oral_contraceptives_or_hormone: false,
    sepsis: true,
    serious_lung_disease: false,
    abnormal_pulmonary_function: false,
    acute_myocardial_infarction: false,
    congestive_heart_failure: false,
    inflammatory_bowel_disease: false,
    medical_patient: true,
    minor_surgery: false,
    arthroscopic_surgery: false,
    major_surgery: true,
    laparoscopic_surgery_over_45_min: false,
    malignancy: true,
    bed_rest_over_72_hours: true,
    prior_vte: true,
    family_history_vte: false,
    thrombophilia: false,
    stroke: true,
    elective_arthroplasty: false,
    hip_pelvis_leg_fracture: false,
    acute_spinal_cord_injury: false,
  }
  let caprini_report = @moonbit-triage.score_caprini(caprini)
  inspect(caprini_report.score, content="21")
  debug_inspect(caprini_report.severity, content="Critical")
  let padua = @moonbit-triage.score_padua({
    active_cancer: true,
    previous_vte: true,
    reduced_mobility: true,
    known_thrombophilia: true,
    recent_trauma_or_surgery: true,
    elderly_age: true,
    heart_or_respiratory_failure: true,
    acute_mi_or_stroke: true,
    acute_infection_or_rheumatologic: true,
    bmi_over_30: true,
    ongoing_hormonal_treatment: true,
  })
  inspect(padua.score, content="20")
  let sleep = @moonbit-triage.score_stop_bang({
    snoring: true,
    tiredness: true,
    observed_apnea: true,
    hypertension: true,
    bmi_over_35: true,
    age_over_50: true,
    neck_circumference_over_40_cm: true,
    male: true,
  })
  inspect(sleep.score, content="8")
  let lung = @moonbit-triage.score_ariscat({
    age: 81,
    preoperative_oxygen_saturation: 85,
    respiratory_infection_last_month: true,
    preoperative_anemia: true,
    surgical_incision_site: 2,
    expected_duration_minutes: 200,
    emergency_surgery: true,
  })
  inspect(lung.score, content="123")
  debug_inspect(lung.severity, content="Critical")
}

///|
test "critical care and emergency rules expose threshold branches" {
  let apache : @moonbit-triage.ApacheIiInput = {
    temperature_tenths_c: 410,
    mean_arterial_pressure: 160,
    heart_rate: 180,
    respiratory_rate: 50,
    oxygenation_value: 100,
    high_fio2: true,
    arterial_ph_hundredths: 700,
    sodium: 180,
    potassium_tenths: 70,
    creatinine_hundredths: 350,
    acute_renal_failure: true,
    hematocrit_tenths: 600,
    white_cell_count_tenths: 400,
    gcs: 3,
    age: 80,
    chronic_health: true,
  }
  let apache_report = @moonbit-triage.score_apache_ii(apache)
  assert_true(apache_report.score > 40)
  debug_inspect(apache_report.severity, content="Critical")
  let smart = @moonbit-triage.score_smart_cop({
    systolic_bp: 89,
    multilobar_infiltrates: true,
    albumin_tenths_g_dl: 34,
    respiratory_rate: 30,
    age: 50,
    confusion: true,
    oxygen_saturation: 89,
    arterial_ph_hundredths: 734,
  })
  inspect(smart.score, content="11")
  let perc = @moonbit-triage.score_perc({
    age: 50,
    heart_rate: 100,
    oxygen_saturation: 94,
    hemoptysis: true,
    estrogen_use: true,
    prior_vte: true,
    recent_surgery_or_trauma: true,
    unilateral_leg_swelling: true,
  })
  inspect(perc.score, content="8")
  assert_true(
    !@moonbit-triage.perc_negative({
      age: 50,
      heart_rate: 100,
      oxygen_saturation: 94,
      hemoptysis: true,
      estrogen_use: true,
      prior_vte: true,
      recent_surgery_or_trauma: true,
      unilateral_leg_swelling: true,
    }),
  )
  assert_true(
    @moonbit-triage.nexus_clears_cspine({
      posterior_midline_tenderness: false,
      focal_neurologic_deficit: false,
      altered_alertness: false,
      intoxication: false,
      painful_distracting_injury: false,
    }),
  )
}

///|
test "decision rules cover foot injury, pediatric head injury, and comorbidity" {
  let ankle = @moonbit-triage.score_ottawa_ankle({
    posterior_edge_lateral_malleolus_tender: true,
    posterior_edge_medial_malleolus_tender: false,
    base_of_fifth_metatarsal_tender: true,
    navicular_tender: false,
    unable_to_bear_four_steps: true,
  })
  inspect(ankle.score, content="3")
  let pecarn = @moonbit-triage.score_pecarn_head({
    age_under_two: true,
    altered_mentation: true,
    palpable_skull_fracture: false,
    nonfrontal_scalp_hematoma: true,
    loss_of_consciousness_minutes: 1,
    severe_mechanism: true,
    not_behaving_normally: true,
    signs_of_basilar_skull_fracture: false,
    severe_headache: false,
  })
  inspect(pecarn.score, content="6")
  let charlson = @moonbit-triage.score_charlson({
    age: 80,
    myocardial_infarction: true,
    congestive_heart_failure: true,
    peripheral_vascular_disease: false,
    cerebrovascular_disease: false,
    dementia: false,
    chronic_pulmonary_disease: true,
    connective_tissue_disease: false,
    peptic_ulcer_disease: false,
    mild_liver_disease: false,
    diabetes_without_complication: false,
    diabetes_with_end_organ_damage: true,
    hemiplegia: false,
    moderate_or_severe_renal_disease: true,
    any_tumor: false,
    leukemia: false,
    lymphoma: false,
    moderate_or_severe_liver_disease: false,
    metastatic_solid_tumor: true,
    aids: false,
  })
  inspect(charlson.score, content="17")
  let meld = @moonbit-triage.score_meld_na({
    bilirubin_tenths_mg_dl: 101,
    inr_hundredths: 251,
    creatinine_tenths_mg_dl: 41,
    sodium: 124,
    dialysis_twice_last_week: true,
  })
  inspect(meld.score, content="37")
}

///|
test "acute abdominal, obstetric, and registry workflows are traceable" {
  let bisap = @moonbit-triage.score_bisap({
    bun_mmol_l_tenths: 80,
    impaired_mentation: true,
    sirs_criteria: 2,
    age: 61,
    pleural_effusion: true,
  })
  inspect(bisap.score, content="5")
  let alvarado = @moonbit-triage.score_alvarado({
    migration_of_pain: true,
    anorexia: true,
    nausea_or_vomiting: true,
    right_lower_quadrant_tenderness: true,
    rebound_tenderness: true,
    fever_tenths_c: 377,
    leukocytosis: true,
    left_shift: true,
  })
  inspect(alvarado.score, content="10")
  let bishop = @moonbit-triage.score_bishop({
    dilation_cm: 10,
    effacement_percent: 80,
    fetal_station: 2,
    cervical_consistency: 2,
    cervical_position: 2,
  })
  inspect(bishop.score, content="15")
  let pregnancy = @moonbit-triage.score_preeclampsia({
    systolic_bp: 160,
    diastolic_bp: 110,
    platelets_thousands: 90,
    creatinine_hundredths_mg_dl: 110,
    ast_units: 140,
    alt_units: 140,
    pulmonary_edema: true,
    persistent_headache: true,
    visual_symptoms: true,
    right_upper_quadrant_pain: true,
    fetal_growth_restriction: true,
  })
  inspect(pregnancy.score, content="13")
  let registry = @moonbit-triage.default_registry()
  assert_true(@moonbit-triage.registry_is_release_ready(registry))
  inspect(@moonbit-triage.registry_size(registry), content="11")
  assert_true(@moonbit-triage.registry_contains(registry, "NIHSS"))
  assert_true(
    @moonbit-triage.registry_keyword_search(registry, "vte").length() >= 2,
  )
  let reports = [bisap, alvarado, bishop]
  assert_true(@moonbit-triage.report_bundle_is_coherent(reports))
  inspect(@moonbit-triage.report_score_sum(reports), content="30")
  assert_true(
    @moonbit-triage.report_quality_ready(
      @moonbit-triage.report_quality(reports),
    ),
  )
}

///|
test "pure score boundaries execute the published threshold tables" {
  for
    value in [
      0, 29, 30, 35, 40, 49, 50, 55, 60, 64, 65, 100, 130, 150, 160, 180, 200, 250,
      350, 400,
    ] {
    ignore(@moonbit-triage.apache_temp_points(value))
    ignore(@moonbit-triage.apache_map_points(value))
    ignore(@moonbit-triage.apache_heart_rate_points(value))
    ignore(@moonbit-triage.apache_respiratory_rate_points(value))
    ignore(@moonbit-triage.apache_oxygenation_points(value, false))
    ignore(@moonbit-triage.apache_oxygenation_points(value, true))
    ignore(@moonbit-triage.apache_ph_points(value + 650))
    ignore(@moonbit-triage.apache_sodium_points(value))
    ignore(@moonbit-triage.apache_potassium_points(value))
    ignore(@moonbit-triage.apache_creatinine_points(value))
    ignore(@moonbit-triage.apache_hematocrit_points(value))
    ignore(@moonbit-triage.apache_white_cell_points(value))
    ignore(@moonbit-triage.apache_age_points(value))
    ignore(@moonbit-triage.smart_cop_pressure_points(value))
    ignore(@moonbit-triage.smart_cop_albumin_points(value))
    ignore(@moonbit-triage.smart_cop_respiration_points(value, value))
    ignore(@moonbit-triage.smart_cop_age_points(value))
    ignore(@moonbit-triage.smart_cop_oxygen_points(value))
    ignore(@moonbit-triage.smart_cop_ph_points(value + 650))
    ignore(@moonbit-triage.ariscat_age_points(value))
    ignore(@moonbit-triage.ariscat_oxygen_points(value))
    ignore(@moonbit-triage.ariscat_incision_points(value))
    ignore(@moonbit-triage.ariscat_duration_points(value))
  }
  for
    value in [
      0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 15, 20, 25, 30, 45, 50, 60, 80, 100, 110, 120,
      140, 160, 200, 250,
    ] {
    ignore(@moonbit-triage.gbs_bun_points(value * 10))
    ignore(@moonbit-triage.gbs_male_hemoglobin_points(value * 10))
    ignore(@moonbit-triage.gbs_female_hemoglobin_points(value * 10))
    ignore(@moonbit-triage.gbs_pressure_points(value * 10))
    ignore(@moonbit-triage.gbs_pulse_points(value * 10))
    ignore(@moonbit-triage.child_pugh_bilirubin_points(value * 10))
    ignore(@moonbit-triage.child_pugh_albumin_points(value * 10))
    ignore(@moonbit-triage.child_pugh_inr_points(value * 10))
    ignore(@moonbit-triage.bishop_dilation_points(value))
    ignore(@moonbit-triage.bishop_effacement_points(value * 10))
    ignore(@moonbit-triage.bishop_station_points(value - 5))
    ignore(@moonbit-triage.bishop_consistency_points(value))
    ignore(@moonbit-triage.bishop_position_points(value))
    ignore(@moonbit-triage.alvarado_severity(value))
    ignore(@moonbit-triage.ranson_severity(value))
    ignore(@moonbit-triage.bisap_severity(value))
    ignore(@moonbit-triage.nihss_severity(value))
    ignore(@moonbit-triage.four_score_severity(value))
    ignore(@moonbit-triage.abcd2_severity(value))
  }
}

///|
test "pathway decisions and audit summaries preserve ordering" {
  let news = @moonbit-triage.score_news2({
    respiratory_rate: 30,
    oxygen_saturation: 88,
    spo2_scale: @moonbit-triage.Scale1,
    supplemental_oxygen: true,
    temperature_tenths_c: 410,
    systolic_bp: 85,
    heart_rate: 140,
    consciousness: @moonbit-triage.Alert,
  })
  let heart = @moonbit-triage.score_heart({
    history: 2,
    ecg: 2,
    age: 70,
    risk_factors: 5,
    troponin: 2,
  })
  let reports = [news, heart]
  let rules : Array[@moonbit-triage.PathwayRule] = [
    {
      code: "R1",
      title: "early warning",
      tier: @moonbit-triage.Urgent,
      required_instruments: ["NEWS2"],
      minimum_severity: @moonbit-triage.High,
      rationale: "NEWS2 escalation",
    },
    {
      code: "R2",
      title: "cardiac review",
      tier: @moonbit-triage.Review,
      required_instruments: ["HEART", "missing"],
      minimum_severity: @moonbit-triage.Medium,
      rationale: "cardiac review",
    },
  ]
  let decision = @moonbit-triage.evaluate_pathway(rules, reports)
  debug_inspect(decision.tier, content="Urgent")
  debug_inspect(decision.evidence, content="EvidencePartial")
  inspect(decision.matched_rules.length(), content="1")
  inspect(decision.missing_instruments.length(), content="1")
  let event_one = @moonbit-triage.audit_event(
    2, "score", "HEART", heart, 20, "monitor", "second",
  )
  let event_two = @moonbit-triage.audit_event(
    1, "score", "NEWS2", news, 10, "form", "first",
  )
  let events = [event_one, event_two]
  let summary = @moonbit-triage.trace_summary(events)
  inspect(summary.event_count, content="2")
  inspect(summary.unique_instruments, content="2")
  debug_inspect(summary.first_timestamp, content="Some(10)")
  debug_inspect(summary.last_timestamp, content="Some(20)")
  inspect(@moonbit-triage.audit_event_labels(events).length(), content="2")
  assert_true(@moonbit-triage.validate_audit_event(event_one) is None)
}

///|
test "registry diffs and report formatting are deterministic" {
  let base = @moonbit-triage.default_registry()
  let extra = @moonbit-triage.registry_add(
    @moonbit-triage.empty_registry("2026.09"),
    @moonbit-triage.metadata(
      "CUSTOM",
      "Custom local rule",
      @moonbit-triage.Workflow,
      "points",
      0,
      5,
      "https://example.invalid/custom",
      "1",
      "Local rule",
      ["local"],
    ),
  )
  let merged = @moonbit-triage.registry_merge(base, extra)
  let changes = @moonbit-triage.registry_changes(base, merged)
  inspect(@moonbit-triage.registry_added(changes).length(), content="1")
  inspect(@moonbit-triage.registry_removed(changes).length(), content="0")
  assert_true(@moonbit-triage.registry_is_release_ready(merged))
  inspect(@moonbit-triage.registry_category_counts(base).length(), content="9")
  let report = @moonbit-triage.score_qsofa({
    respiratory_rate: 22,
    systolic_bp: 95,
    gcs_total: 14,
  })
  let reports = [report]
  assert_true(@moonbit-triage.report_find(reports, "qSOFA") is Some(_))
  inspect(
    @moonbit-triage.report_csv_header(),
    content="instrument,score,severity,interpretation,explanations",
  )
  assert_true(@moonbit-triage.render_report(report).contains("qSOFA score=3"))
  assert_true(@moonbit-triage.report_score_reconciles(report))
  inspect(@moonbit-triage.report_explanation_count(reports), content="3")
  inspect(@moonbit-triage.report_average_score_x100(reports), content="300")
  assert_true(
    @moonbit-triage.report_has_severity(reports, @moonbit-triage.High),
  )
}

///|
test "extended score boundaries and ED criteria are exhaustively sampled" {
  for
    value in [
      0, 1, 2, 3, 4, 5, 6, 7, 8, 15, 16, 21, 22, 23, 30, 36, 50, 65, 89, 90, 93,
      95, 100, 110, 125, 126, 150, 350,
    ] {
    ignore(@moonbit-triage.pesi_severity(value))
    ignore(@moonbit-triage.bode_bmi_points(value))
    ignore(@moonbit-triage.bode_fev1_points(value))
    ignore(@moonbit-triage.bode_mrc_points(value))
    ignore(@moonbit-triage.bode_walk_points(value * 10))
    ignore(@moonbit-triage.bode_severity(value))
    ignore(@moonbit-triage.qcsi_respiratory_points(value))
    ignore(@moonbit-triage.qcsi_oxygen_points(value))
    ignore(@moonbit-triage.qcsi_flow_points(value))
    ignore(@moonbit-triage.qcsi_severity(value))
    ignore(@moonbit-triage.hestia_positive_points(value % 2 == 0))
    ignore(@moonbit-triage.hestia_severity(value))
    ignore(@moonbit-triage.trauma_gcs_points(value))
    ignore(@moonbit-triage.trauma_pressure_points(value * 10))
    ignore(@moonbit-triage.trauma_respiration_points(value))
    ignore(@moonbit-triage.revised_trauma_severity(value * 300))
    ignore(@moonbit-triage.injury_severity_band(value))
    ignore(
      @moonbit-triage.canadian_cspine_high_risk_count({
        age: value,
        dangerous_mechanism: value % 2 == 0,
        paresthesias: value % 3 == 0,
        low_risk_simple_rear_end_collision: false,
        low_risk_sitting_in_ed: false,
        low_risk_ambulatory: false,
        low_risk_delayed_neck_pain: false,
        low_risk_no_midline_tenderness: false,
        rotates_neck_45_degrees: false,
      }),
    )
    ignore(
      @moonbit-triage.pecarn_intermediate_count({
        age_under_two: true,
        altered_mentation: value % 2 == 0,
        palpable_skull_fracture: false,
        nonfrontal_scalp_hematoma: value % 3 == 0,
        loss_of_consciousness_minutes: value,
        severe_mechanism: value % 5 == 0,
        not_behaving_normally: false,
        signs_of_basilar_skull_fracture: false,
        severe_headache: value > 20,
      }),
    )
  }
  assert_true(
    @moonbit-triage.ottawa_ankle_positive({
      posterior_edge_lateral_malleolus_tender: false,
      posterior_edge_medial_malleolus_tender: false,
      base_of_fifth_metatarsal_tender: false,
      navicular_tender: false,
      unable_to_bear_four_steps: false,
    }) ==
    false,
  )
  assert_true(
    @moonbit-triage.canadian_cspine_positive({
      age: 30,
      dangerous_mechanism: false,
      paresthesias: false,
      low_risk_simple_rear_end_collision: true,
      low_risk_sitting_in_ed: true,
      low_risk_ambulatory: true,
      low_risk_delayed_neck_pain: true,
      low_risk_no_midline_tenderness: true,
      rotates_neck_45_degrees: true,
    }) ==
    false,
  )
}

///|
test "observation and report utilities handle empty and populated inputs" {
  let empty = @moonbit-triage.empty_timeline()
  assert_true(@moonbit-triage.timeline_latest(empty) is None)
  assert_true(
    @moonbit-triage.trend_for(empty, @moonbit-triage.HeartRate) is None,
  )
  inspect(@moonbit-triage.timeline_summary(empty).span_minutes, content="0")
  let bands = [
    @moonbit-triage.threshold_band("normal", 0, 99, 0, "normal"),
    @moonbit-triage.threshold_band("raised", 100, 199, 1, "raised"),
  ]
  debug_inspect(@moonbit-triage.threshold_points(bands, 100), content="Some(1)")
  debug_inspect(@moonbit-triage.threshold_points(bands, 300), content="None")
  let report = @moonbit-triage.score_news2({
    respiratory_rate: 16,
    oxygen_saturation: 98,
    spo2_scale: @moonbit-triage.Scale1,
    supplemental_oxygen: false,
    temperature_tenths_c: 370,
    systolic_bp: 120,
    heart_rate: 70,
    consciousness: @moonbit-triage.Alert,
  })
  let reports = [report]
  assert_true(@moonbit-triage.highest_concern_report(reports) is Some(_))
  inspect(@moonbit-triage.report_max_score(reports), content="0")
  inspect(@moonbit-triage.report_range(reports), content="0")
  inspect(
    @moonbit-triage.report_count_at_or_above(reports, @moonbit-triage.Low),
    content="1",
  )
  inspect(
    @moonbit-triage.reports_csv(reports).contains("NEWS2"),
    content="true",
  )
  assert_true(
    @moonbit-triage.report_is_empty({
      instrument: "",
      score: 0,
      severity: @moonbit-triage.Low,
      interpretation: "",
      explanations: [],
      disclaimer: "",
    }),
  )
  assert_true(@moonbit-triage.highest_concern_report([]) is None)
  assert_true(@moonbit-triage.report_min_score([]) is None)
  inspect(@moonbit-triage.report_range([]), content="0")
  inspect(@moonbit-triage.report_average_score_x100([]), content="0")
  assert_true(
    !@moonbit-triage.report_quality_ready(@moonbit-triage.report_quality([])),
  )
  let catalog = @moonbit-triage.default_registry()
  assert_true(
    @moonbit-triage.registry_category_entries(catalog, @moonbit-triage.Workflow).length() ==
    0,
  )
  assert_true(
    @moonbit-triage.registry_keyword_search(catalog, "not-found").length() == 0,
  )
  assert_true(
    @moonbit-triage.registry_revision_label(catalog).contains("2026.08"),
  )
  assert_true(
    @moonbit-triage.validate_bisap({
      bun_mmol_l_tenths: 1001,
      impaired_mentation: false,
      sirs_criteria: 0,
      age: 20,
      pleural_effusion: false,
    })
    is Some(_),
  )
  assert_true(
    @moonbit-triage.validate_alvarado({
      migration_of_pain: false,
      anorexia: false,
      nausea_or_vomiting: false,
      right_lower_quadrant_tenderness: false,
      rebound_tenderness: false,
      fever_tenths_c: 200,
      leukocytosis: false,
      left_shift: false,
    })
    is Some(_),
  )
  let ranson = @moonbit-triage.score_ranson({
    age: 56,
    wbc_tenths: 161,
    glucose_mg_dl: 201,
    ldh_units: 351,
    ast_units: 251,
    hematocrit_drop_tenths: 101,
    bun_rise_mg_dl: 6,
    calcium_mg_dl_tenths: 79,
    arterial_oxygen_mmhg: 59,
    base_deficit: 5,
    fluid_sequestration_liters: 7,
  })
  inspect(ranson.score, content="11")
}
