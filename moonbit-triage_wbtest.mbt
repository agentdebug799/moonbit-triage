///|
test "NEWS2 respiratory thresholds" {
  inspect(news2_respiratory_rate_points(8), content="3")
  inspect(news2_respiratory_rate_points(9), content="1")
  inspect(news2_respiratory_rate_points(12), content="0")
  inspect(news2_respiratory_rate_points(21), content="2")
  inspect(news2_respiratory_rate_points(25), content="3")
}

///|
test "NEWS2 blood pressure thresholds" {
  inspect(news2_systolic_bp_points(90), content="3")
  inspect(news2_systolic_bp_points(91), content="2")
  inspect(news2_systolic_bp_points(101), content="1")
  inspect(news2_systolic_bp_points(111), content="0")
  inspect(news2_systolic_bp_points(220), content="3")
}

///|
test "NEWS2 pulse thresholds" {
  inspect(news2_heart_rate_points(40), content="3")
  inspect(news2_heart_rate_points(41), content="1")
  inspect(news2_heart_rate_points(51), content="0")
  inspect(news2_heart_rate_points(91), content="1")
  inspect(news2_heart_rate_points(111), content="2")
  inspect(news2_heart_rate_points(131), content="3")
}

///|
test "GCS severity thresholds" {
  debug_inspect(gcs_severity(8), content="Critical")
  debug_inspect(gcs_severity(9), content="High")
  debug_inspect(gcs_severity(13), content="Medium")
  debug_inspect(gcs_severity(15), content="Low")
}
