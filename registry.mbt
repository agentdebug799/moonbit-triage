///|
pub(all) enum InstrumentCategory {
  EarlyWarning
  Cardiorespiratory
  Neurology
  Trauma
  Gastrointestinal
  RenalHepatic
  Perioperative
  ObstetricPediatric
  Workflow
} derive(Debug, Eq)

///|
pub(all) struct InstrumentMetadata {
  id : String
  display_name : String
  category : InstrumentCategory
  unit : String
  minimum : Int
  maximum : Int
  source_url : String
  version : String
  caution : String
  keywords : Array[String]
} derive(Debug, Eq)

///|
pub(all) struct InstrumentRegistry {
  entries : Array[InstrumentMetadata]
  revision : String
} derive(Debug, Eq)

///|
pub fn instrument_category_label(category : InstrumentCategory) -> String {
  match category {
    EarlyWarning => "early_warning"
    Cardiorespiratory => "cardiorespiratory"
    Neurology => "neurology"
    Trauma => "trauma"
    Gastrointestinal => "gastrointestinal"
    RenalHepatic => "renal_hepatic"
    Perioperative => "perioperative"
    ObstetricPediatric => "obstetric_pediatric"
    Workflow => "workflow"
  }
}

///|
pub fn metadata(
  id : String,
  display_name : String,
  category : InstrumentCategory,
  unit : String,
  minimum : Int,
  maximum : Int,
  source_url : String,
  version : String,
  caution : String,
  keywords : Array[String],
) -> InstrumentMetadata {
  {
    id,
    display_name,
    category,
    unit,
    minimum,
    maximum,
    source_url,
    version,
    caution,
    keywords,
  }
}

///|
pub fn empty_registry(revision : String) -> InstrumentRegistry {
  { entries: [], revision }
}

///|
pub fn registry_size(registry : InstrumentRegistry) -> Int {
  registry.entries.length()
}

///|
pub fn registry_add(
  registry : InstrumentRegistry,
  entry : InstrumentMetadata,
) -> InstrumentRegistry {
  let entries = registry.entries.copy()
  entries.push(entry)
  { entries, revision: registry.revision }
}

///|
pub fn registry_find(
  registry : InstrumentRegistry,
  id : String,
) -> InstrumentMetadata? {
  for entry in registry.entries {
    if entry.id == id {
      return Some(entry)
    }
  }
  None
}

///|
pub fn registry_contains(registry : InstrumentRegistry, id : String) -> Bool {
  registry_find(registry, id) is Some(_)
}

///|
pub fn registry_category_entries(
  registry : InstrumentRegistry,
  category : InstrumentCategory,
) -> Array[InstrumentMetadata] {
  registry.entries.filter(fn(entry) { entry.category == category })
}

///|
pub fn registry_keyword_search(
  registry : InstrumentRegistry,
  keyword : String,
) -> Array[InstrumentMetadata] {
  registry.entries.filter(fn(entry) {
    entry.id.contains(keyword) ||
    entry.display_name.contains(keyword) ||
    entry.keywords.any(fn(item) { item.contains(keyword) })
  })
}

///|
pub fn validate_metadata(entry : InstrumentMetadata) -> Bool {
  entry.id != "" &&
  entry.display_name != "" &&
  entry.unit != "" &&
  entry.minimum <= entry.maximum &&
  entry.source_url.has_prefix("http") &&
  entry.version != ""
}

///|
pub fn registry_validate(registry : InstrumentRegistry) -> Bool {
  if registry.revision == "" {
    return false
  }
  for entry in registry.entries {
    if !validate_metadata(entry) {
      return false
    }
  }
  true
}

///|
pub fn registry_ids(registry : InstrumentRegistry) -> Array[String] {
  registry.entries.map(fn(entry) { entry.id })
}

///|
pub fn registry_display_labels(registry : InstrumentRegistry) -> Array[String] {
  registry.entries.map(fn(entry) {
    entry.id +
    " — " +
    entry.display_name +
    " [" +
    instrument_category_label(entry.category) +
    "]"
  })
}

///|
pub fn render_metadata(entry : InstrumentMetadata) -> String {
  entry.id +
  " " +
  entry.display_name +
  " category=" +
  instrument_category_label(entry.category) +
  " range=" +
  entry.minimum.to_string() +
  ".." +
  entry.maximum.to_string() +
  " unit=" +
  entry.unit +
  " version=" +
  entry.version
}

///|
pub fn render_registry(registry : InstrumentRegistry) -> String {
  "revision=" +
  registry.revision +
  "; entries=" +
  registry.entries.map(render_metadata).join(" | ")
}

///|
pub fn default_registry() -> InstrumentRegistry {
  let base = empty_registry("2026.08")
  let news2 = metadata(
    "NEWS2",
    "National Early Warning Score 2",
    EarlyWarning,
    "points",
    0,
    20,
    "https://www.rcp.ac.uk/resources/national-early-warning-score-news-2/",
    "2017",
    "Use the official chart and local escalation policy.",
    ["acute", "ward", "vitals"],
  )
  let qsofa = metadata(
    "qSOFA",
    "Quick Sequential Organ Failure Assessment",
    EarlyWarning,
    "points",
    0,
    3,
    "https://jamanetwork.com/journals/jama/fullarticle/2492881",
    "2016",
    "Not a stand-alone sepsis rule-out test.",
    ["sepsis", "organ_failure"],
  )
  let sofa = metadata(
    "SOFA",
    "Sequential Organ Failure Assessment",
    EarlyWarning,
    "points",
    0,
    24,
    "https://doi.org/10.1007/BF01709751",
    "1996",
    "Compare with a valid baseline when used longitudinally.",
    ["icu", "organ_failure"],
  )
  let heart = metadata(
    "HEART",
    "HEART chest-pain score",
    Cardiorespiratory,
    "points",
    0,
    10,
    "https://pubmed.ncbi.nlm.nih.gov/24240112/",
    "2008",
    "Requires clinical context and troponin assay interpretation.",
    ["chest_pain", "acs"],
  )
  let pesi = metadata(
    "PESI",
    "Pulmonary Embolism Severity Index",
    Cardiorespiratory,
    "points",
    0,
    400,
    "https://www.nice.org.uk/guidance/ng158",
    "2012",
    "Does not independently determine disposition.",
    ["pulmonary_embolism", "vte"],
  )
  let nihss = metadata(
    "NIHSS",
    "National Institutes of Health Stroke Scale",
    Neurology,
    "points",
    0,
    42,
    "https://www.ninds.nih.gov/sites/default/files/migrate-documents/nih_stroke_scale_booklet_508c.pdf",
    "2024",
    "Administer with official instructions and trained raters.",
    ["stroke", "neurology"],
  )
  let iss = metadata(
    "ISS",
    "Injury Severity Score",
    Trauma,
    "points",
    0,
    75,
    "https://pubmed.ncbi.nlm.nih.gov/4854191/",
    "1974",
    "AIS coding and region selection must be traceable.",
    ["trauma", "injury"],
  )
  let gbs = metadata(
    "Glasgow-Blatchford",
    "Upper gastrointestinal bleeding risk",
    Gastrointestinal,
    "points",
    0,
    30,
    "https://pubmed.ncbi.nlm.nih.gov/11073021/",
    "2000",
    "Not a substitute for resuscitation or endoscopic assessment.",
    ["bleeding", "gi"],
  )
  let child = metadata(
    "Child-Pugh",
    "Chronic liver disease classification",
    RenalHepatic,
    "points",
    5,
    15,
    "https://pubmed.ncbi.nlm.nih.gov/3610046/",
    "1973",
    "Interpret with the underlying liver disease and current labs.",
    ["liver", "cirrhosis"],
  )
  let caprini = metadata(
    "Caprini",
    "Perioperative VTE risk assessment",
    Perioperative,
    "points",
    0,
    30,
    "https://pubmed.ncbi.nlm.nih.gov/30939898/",
    "2013",
    "Pair VTE risk with bleeding risk and local protocol.",
    ["vte", "surgery"],
  )
  let alvarado = metadata(
    "Alvarado",
    "Appendicitis clinical score",
    ObstetricPediatric,
    "points",
    0,
    10,
    "https://pubmed.ncbi.nlm.nih.gov/7042080/",
    "1986",
    "Serial examination and imaging remain clinical decisions.",
    ["appendicitis", "abdomen"],
  )
  registry_add(
    registry_add(
      registry_add(
        registry_add(
          registry_add(
            registry_add(
              registry_add(
                registry_add(
                  registry_add(
                    registry_add(registry_add(base, news2), qsofa),
                    sofa,
                  ),
                  heart,
                ),
                pesi,
              ),
              nihss,
            ),
            iss,
          ),
          gbs,
        ),
        child,
      ),
      caprini,
    ),
    alvarado,
  )
}
