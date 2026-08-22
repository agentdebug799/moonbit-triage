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
