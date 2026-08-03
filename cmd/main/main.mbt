///|
fn main {
  let bundle = @triage.score_triage({
    news2: {
      respiratory_rate: 24,
      oxygen_saturation: 93,
      spo2_scale: @triage.Scale1,
      supplemental_oxygen: false,
      temperature_tenths_c: 382,
      systolic_bp: 104,
      heart_rate: 118,
      consciousness: @triage.Alert,
    },
    gcs: { eye: 4, verbal: 5, motor: 6 },
  })
  println("moonbit-triage sample")
  println("NEWS2: \{bundle.news2.score}")
  println("qSOFA: \{bundle.qsofa.score}")
  println("GCS: \{bundle.gcs.score}")
  println("Summary: \{bundle.summary}")
}
