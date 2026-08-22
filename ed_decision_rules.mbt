///|
pub(all) struct NexusCspineInput {
  posterior_midline_tenderness : Bool
  focal_neurologic_deficit : Bool
  altered_alertness : Bool
  intoxication : Bool
  painful_distracting_injury : Bool
} derive(Debug, Eq)

///|
pub fn nexus_positive_count(input : NexusCspineInput) -> Int {
  let midline = if input.posterior_midline_tenderness { 1 } else { 0 }
  let neurologic = if input.focal_neurologic_deficit { 1 } else { 0 }
  let alertness = if input.altered_alertness { 1 } else { 0 }
  let intoxication = if input.intoxication { 1 } else { 0 }
  let distracting = if input.painful_distracting_injury { 1 } else { 0 }
  midline + neurologic + alertness + intoxication + distracting
}

///|
pub fn nexus_clears_cspine(input : NexusCspineInput) -> Bool {
  nexus_positive_count(input) == 0
}

///|
pub fn score_nexus_cspine(input : NexusCspineInput) -> ScoreReport {
  let score = nexus_positive_count(input)
  let severity = if score == 0 { Low } else { High }
  report(
    "NEXUS C-spine",
    score,
    severity,
    "NEXUS exposes cervical-spine imaging criteria for appropriately selected blunt-trauma patients.",
    [
      explanation(
        "Midline tenderness",
        if input.posterior_midline_tenderness {
          1
        } else {
          0
        },
        "Posterior midline tenderness",
      ),
      explanation(
        "Neurologic deficit",
        if input.focal_neurologic_deficit {
          1
        } else {
          0
        },
        "Focal neurologic deficit",
      ),
      explanation(
        "Alertness",
        if input.altered_alertness {
          1
        } else {
          0
        },
        "Altered level of alertness",
      ),
      explanation(
        "Intoxication",
        if input.intoxication {
          1
        } else {
          0
        },
        "Evidence of intoxication",
      ),
      explanation(
        "Distracting injury",
        if input.painful_distracting_injury {
          1
        } else {
          0
        },
        "Painful distracting injury",
      ),
    ],
  )
}

///|
pub(all) struct CanadianCspineInput {
  age : Int
  dangerous_mechanism : Bool
  paresthesias : Bool
  low_risk_simple_rear_end_collision : Bool
  low_risk_sitting_in_ed : Bool
  low_risk_ambulatory : Bool
  low_risk_delayed_neck_pain : Bool
  low_risk_no_midline_tenderness : Bool
  rotates_neck_45_degrees : Bool
} derive(Debug, Eq)

///|
pub fn validate_canadian_cspine(
  input : CanadianCspineInput,
) -> ValidationError? {
  validate_range("age", input.age, 0, 150)
}

///|
pub fn canadian_cspine_high_risk_count(input : CanadianCspineInput) -> Int {
  let age = if input.age >= 65 { 1 } else { 0 }
  let mechanism = if input.dangerous_mechanism { 1 } else { 0 }
  let paresthesia = if input.paresthesias { 1 } else { 0 }
  age + mechanism + paresthesia
}

///|
pub fn canadian_cspine_low_risk_count(input : CanadianCspineInput) -> Int {
  let rear = if input.low_risk_simple_rear_end_collision { 1 } else { 0 }
  let sitting = if input.low_risk_sitting_in_ed { 1 } else { 0 }
  let ambulatory = if input.low_risk_ambulatory { 1 } else { 0 }
  let delayed = if input.low_risk_delayed_neck_pain { 1 } else { 0 }
  let no_tenderness = if input.low_risk_no_midline_tenderness { 1 } else { 0 }
  rear + sitting + ambulatory + delayed + no_tenderness
}

///|
pub fn canadian_cspine_positive(input : CanadianCspineInput) -> Bool {
  canadian_cspine_high_risk_count(input) > 0 || !input.rotates_neck_45_degrees
}

///|
pub fn score_canadian_cspine(input : CanadianCspineInput) -> ScoreReport {
  let high = canadian_cspine_high_risk_count(input)
  let low = canadian_cspine_low_risk_count(input)
  let rotation = if input.rotates_neck_45_degrees { 0 } else { 1 }
  let score = high + rotation
  let severity = if canadian_cspine_positive(input) { High } else { Low }
  report(
    "Canadian C-spine",
    score,
    severity,
    "The Canadian C-spine rule separates high-risk features, low-risk assessment, and active neck rotation.",
    [
      explanation("High-risk criteria", high, "Age, mechanism, or paresthesia"),
      explanation("Low-risk criteria", low, "Low-risk clinical features"),
      explanation("Neck rotation", rotation, "Unable to rotate neck 45 degrees"),
    ],
  )
}

///|
pub(all) struct PercInput {
  age : Int
  heart_rate : Int
  oxygen_saturation : Int
  hemoptysis : Bool
  estrogen_use : Bool
  prior_vte : Bool
  recent_surgery_or_trauma : Bool
  unilateral_leg_swelling : Bool
} derive(Debug, Eq)

///|
pub fn validate_perc(input : PercInput) -> ValidationError? {
  match validate_range("age", input.age, 0, 150) {
    Some(err) => Some(err)
    None =>
      match validate_range("heart_rate", input.heart_rate, 0, 300) {
        Some(err) => Some(err)
        None =>
          validate_range("oxygen_saturation", input.oxygen_saturation, 0, 100)
      }
  }
}

///|
pub fn perc_positive_count(input : PercInput) -> Int {
  let age = if input.age >= 50 { 1 } else { 0 }
  let pulse = if input.heart_rate >= 100 { 1 } else { 0 }
  let oxygen = if input.oxygen_saturation < 95 { 1 } else { 0 }
  let hemoptysis = if input.hemoptysis { 1 } else { 0 }
  let estrogen = if input.estrogen_use { 1 } else { 0 }
  let prior = if input.prior_vte { 1 } else { 0 }
  let surgery = if input.recent_surgery_or_trauma { 1 } else { 0 }
  let swelling = if input.unilateral_leg_swelling { 1 } else { 0 }
  age + pulse + oxygen + hemoptysis + estrogen + prior + surgery + swelling
}

///|
pub fn perc_negative(input : PercInput) -> Bool {
  perc_positive_count(input) == 0
}

///|
pub fn score_perc(input : PercInput) -> ScoreReport {
  let score = perc_positive_count(input)
  report(
    "PERC",
    score,
    if score == 0 {
      Low
    } else {
      Medium
    },
    "PERC counts pulmonary-embolism exclusion criteria only after a clinician has established low pretest probability.",
    [
      explanation("Age", if input.age >= 50 { 1 } else { 0 }, "Age threshold"),
      explanation(
        "Pulse",
        if input.heart_rate >= 100 {
          1
        } else {
          0
        },
        "Heart rate threshold",
      ),
      explanation(
        "Oxygen",
        if input.oxygen_saturation < 95 {
          1
        } else {
          0
        },
        "Oxygen saturation threshold",
      ),
      explanation(
        "Hemoptysis",
        if input.hemoptysis {
          1
        } else {
          0
        },
        "Hemoptysis",
      ),
      explanation(
        "Estrogen",
        if input.estrogen_use {
          1
        } else {
          0
        },
        "Estrogen exposure",
      ),
      explanation(
        "Prior VTE",
        if input.prior_vte {
          1
        } else {
          0
        },
        "Previous venous thromboembolism",
      ),
      explanation(
        "Surgery or trauma",
        if input.recent_surgery_or_trauma {
          1
        } else {
          0
        },
        "Recent surgery or trauma",
      ),
      explanation(
        "Leg swelling",
        if input.unilateral_leg_swelling {
          1
        } else {
          0
        },
        "Unilateral leg swelling",
      ),
    ],
  )
}

///|
pub(all) struct OttawaAnkleInput {
  posterior_edge_lateral_malleolus_tender : Bool
  posterior_edge_medial_malleolus_tender : Bool
  base_of_fifth_metatarsal_tender : Bool
  navicular_tender : Bool
  unable_to_bear_four_steps : Bool
} derive(Debug, Eq)

///|
pub fn ottawa_ankle_positive(input : OttawaAnkleInput) -> Bool {
  input.posterior_edge_lateral_malleolus_tender ||
  input.posterior_edge_medial_malleolus_tender ||
  input.base_of_fifth_metatarsal_tender ||
  input.navicular_tender ||
  input.unable_to_bear_four_steps
}

///|
pub fn ottawa_ankle_criterion_count(input : OttawaAnkleInput) -> Int {
  let lateral = if input.posterior_edge_lateral_malleolus_tender {
    1
  } else {
    0
  }
  let medial = if input.posterior_edge_medial_malleolus_tender { 1 } else { 0 }
  let fifth = if input.base_of_fifth_metatarsal_tender { 1 } else { 0 }
  let navicular = if input.navicular_tender { 1 } else { 0 }
  let steps = if input.unable_to_bear_four_steps { 1 } else { 0 }
  lateral + medial + fifth + navicular + steps
}

///|
pub fn score_ottawa_ankle(input : OttawaAnkleInput) -> ScoreReport {
  let score = ottawa_ankle_criterion_count(input)
  report(
    "Ottawa Ankle",
    score,
    if ottawa_ankle_positive(input) {
      High
    } else {
      Low
    },
    "Ottawa ankle criteria identify when ankle or foot radiographs should be considered after acute injury.",
    [
      explanation(
        "Lateral malleolus",
        if input.posterior_edge_lateral_malleolus_tender {
          1
        } else {
          0
        },
        "Posterior edge tenderness",
      ),
      explanation(
        "Medial malleolus",
        if input.posterior_edge_medial_malleolus_tender {
          1
        } else {
          0
        },
        "Posterior edge tenderness",
      ),
      explanation(
        "Fifth metatarsal",
        if input.base_of_fifth_metatarsal_tender {
          1
        } else {
          0
        },
        "Base tenderness",
      ),
      explanation(
        "Navicular",
        if input.navicular_tender {
          1
        } else {
          0
        },
        "Navicular tenderness",
      ),
      explanation(
        "Weight bearing",
        if input.unable_to_bear_four_steps {
          1
        } else {
          0
        },
        "Unable to bear four steps",
      ),
    ],
  )
}

///|
pub(all) struct PecarnHeadInput {
  age_under_two : Bool
  altered_mentation : Bool
  palpable_skull_fracture : Bool
  nonfrontal_scalp_hematoma : Bool
  loss_of_consciousness_minutes : Int
  severe_mechanism : Bool
  not_behaving_normally : Bool
  signs_of_basilar_skull_fracture : Bool
  severe_headache : Bool
} derive(Debug, Eq)

///|
pub fn validate_pecarn_head(input : PecarnHeadInput) -> ValidationError? {
  validate_range(
    "loss_of_consciousness_minutes",
    input.loss_of_consciousness_minutes,
    0,
    1000,
  )
}

///|
pub fn pecarn_high_risk_count(input : PecarnHeadInput) -> Int {
  let mentation = if input.altered_mentation { 1 } else { 0 }
  let skull = if input.palpable_skull_fracture { 1 } else { 0 }
  let basilar = if input.signs_of_basilar_skull_fracture { 1 } else { 0 }
  mentation + skull + basilar
}

///|
pub fn pecarn_intermediate_count(input : PecarnHeadInput) -> Int {
  let scalp = if input.nonfrontal_scalp_hematoma { 1 } else { 0 }
  let loc = if input.loss_of_consciousness_minutes > 0 { 1 } else { 0 }
  let mechanism = if input.severe_mechanism { 1 } else { 0 }
  let behavior = if input.not_behaving_normally { 1 } else { 0 }
  let headache = if input.severe_headache { 1 } else { 0 }
  scalp + loc + mechanism + behavior + headache
}

///|
pub fn score_pecarn_head(input : PecarnHeadInput) -> ScoreReport {
  let high = pecarn_high_risk_count(input)
  let intermediate = pecarn_intermediate_count(input)
  let score = high * 2 + intermediate
  report(
    "PECARN Head Injury",
    score,
    if high > 0 {
      Critical
    } else if intermediate > 0 {
      Medium
    } else {
      Low
    },
    "PECARN exposes age-specific pediatric head-injury risk features and is not a substitute for clinical assessment.",
    [
      explanation("High-risk criteria", high, "High-risk feature count"),
      explanation(
        "Intermediate criteria", intermediate, "Intermediate-risk feature count",
      ),
      explanation(
        "Age group",
        if input.age_under_two {
          0
        } else {
          1
        },
        "Age-group branch selected",
      ),
    ],
  )
}
