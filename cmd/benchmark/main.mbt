///|
fn main {
  let mut checksum = 0
  let mut critical = 0
  for i in 0..<10000 {
    let offset = i % 20
    let report = @moonbit-triage.score_news2({
      respiratory_rate: 12 + offset,
      oxygen_saturation: 96 - offset / 2,
      spo2_scale: @moonbit-triage.Scale1,
      supplemental_oxygen: offset % 3 == 0,
      temperature_tenths_c: 365 + offset,
      systolic_bp: 120 - offset,
      heart_rate: 70 + offset * 2,
      consciousness: @moonbit-triage.Alert,
    })
    checksum += report.score
    match report.severity {
      @moonbit-triage.Critical => critical += 1
      _ => ()
    }
  }
  println("iterations=10000")
  println("checksum=\{checksum}")
  println("critical_reports=\{critical}")
}
