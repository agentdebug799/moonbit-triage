///|
pub fn severity_label(severity : Severity) -> String {
  match severity {
    Low => "low"
    Medium => "medium"
    High => "high"
    Critical => "critical"
  }
}

///|
pub fn validation_error_field(err : ValidationError) -> String {
  match err {
    OutOfRange(field~, ..) => field
    InvalidScale(field~, ..) => field
  }
}

///|
pub fn validation_error_message(err : ValidationError) -> String {
  match err {
    OutOfRange(field~, value~, min~, max~) =>
      "\{field} value \{value} is outside the accepted range \{min}..\{max}"
    InvalidScale(field~, value~) =>
      "\{field} value \{value} is not a supported scale value"
  }
}
