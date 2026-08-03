///|
pub(all) enum ValidationError {
  OutOfRange(field~ : String, value~ : Int, min~ : Int, max~ : Int)
  InvalidScale(field~ : String, value~ : Int)
} derive(Debug, Eq)

///|
pub fn validate_range(
  field : String,
  value : Int,
  min : Int,
  max : Int,
) -> ValidationError? {
  if value < min || value > max {
    Some(ValidationError::OutOfRange(field~, value~, min~, max~))
  } else {
    None
  }
}

///|
pub fn validate_bool_scale(field : String, value : Int) -> ValidationError? {
  if value != 0 && value != 1 {
    Some(ValidationError::InvalidScale(field~, value~))
  } else {
    None
  }
}
