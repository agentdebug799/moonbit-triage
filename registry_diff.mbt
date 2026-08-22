///|
pub(all) enum RegistryChangeKind {
  Added
  Removed
  Updated
  Unchanged
} derive(Debug, Eq)

///|
pub(all) struct RegistryChange {
  id : String
  kind : RegistryChangeKind
  before_version : String
  after_version : String
  detail : String
} derive(Debug, Eq)

///|
pub fn registry_change_kind_label(kind : RegistryChangeKind) -> String {
  match kind {
    Added => "added"
    Removed => "removed"
    Updated => "updated"
    Unchanged => "unchanged"
  }
}

///|
pub fn metadata_same(
  left : InstrumentMetadata,
  right : InstrumentMetadata,
) -> Bool {
  left.id == right.id &&
  left.display_name == right.display_name &&
  left.category == right.category &&
  left.unit == right.unit &&
  left.minimum == right.minimum &&
  left.maximum == right.maximum &&
  left.source_url == right.source_url &&
  left.version == right.version &&
  left.caution == right.caution &&
  left.keywords == right.keywords
}

///|
pub fn compare_metadata(
  before : InstrumentMetadata?,
  after : InstrumentMetadata?,
  id : String,
) -> RegistryChange {
  match (before, after) {
    (None, Some(next)) =>
      {
        id,
        kind: Added,
        before_version: "none",
        after_version: next.version,
        detail: "instrument entered registry",
      }
    (Some(previous), None) =>
      {
        id,
        kind: Removed,
        before_version: previous.version,
        after_version: "none",
        detail: "instrument removed from registry",
      }
    (Some(previous), Some(next)) => {
      let same = metadata_same(previous, next)
      {
        id,
        kind: if same {
          Unchanged
        } else {
          Updated
        },
        before_version: previous.version,
        after_version: next.version,
        detail: if same {
          "metadata unchanged"
        } else {
          "metadata fields changed"
        },
      }
    }
    (None, None) =>
      {
        id,
        kind: Unchanged,
        before_version: "none",
        after_version: "none",
        detail: "no metadata in either registry",
      }
  }
}

///|
pub fn registry_changes(
  before : InstrumentRegistry,
  after : InstrumentRegistry,
) -> Array[RegistryChange] {
  let ids = registry_ids(before)
  for id in registry_ids(after) {
    if !ids.contains(id) {
      ids.push(id)
    }
  }
  ids.map(fn(id) {
    compare_metadata(registry_find(before, id), registry_find(after, id), id)
  })
}

///|
pub fn registry_added(changes : Array[RegistryChange]) -> Array[RegistryChange] {
  changes.filter(fn(change) { change.kind == Added })
}

///|
pub fn registry_removed(
  changes : Array[RegistryChange],
) -> Array[RegistryChange] {
  changes.filter(fn(change) { change.kind == Removed })
}

///|
pub fn registry_updated(
  changes : Array[RegistryChange],
) -> Array[RegistryChange] {
  changes.filter(fn(change) { change.kind == Updated })
}

///|
pub fn registry_unchanged(
  changes : Array[RegistryChange],
) -> Array[RegistryChange] {
  changes.filter(fn(change) { change.kind == Unchanged })
}

///|
pub fn render_registry_change(change : RegistryChange) -> String {
  change.id +
  " " +
  registry_change_kind_label(change.kind) +
  " " +
  change.before_version +
  " -> " +
  change.after_version +
  ": " +
  change.detail
}

///|
pub fn render_registry_changes(changes : Array[RegistryChange]) -> String {
  changes.map(render_registry_change).join(" | ")
}

///|
pub fn registry_category_count(
  registry : InstrumentRegistry,
  category : InstrumentCategory,
) -> Int {
  registry_category_entries(registry, category).length()
}

///|
pub fn registry_category_counts(registry : InstrumentRegistry) -> Array[String] {
  [
    instrument_category_label(EarlyWarning) +
    "=" +
    registry_category_count(registry, EarlyWarning).to_string(),
    instrument_category_label(Cardiorespiratory) +
    "=" +
    registry_category_count(registry, Cardiorespiratory).to_string(),
    instrument_category_label(Neurology) +
    "=" +
    registry_category_count(registry, Neurology).to_string(),
    instrument_category_label(Trauma) +
    "=" +
    registry_category_count(registry, Trauma).to_string(),
    instrument_category_label(Gastrointestinal) +
    "=" +
    registry_category_count(registry, Gastrointestinal).to_string(),
    instrument_category_label(RenalHepatic) +
    "=" +
    registry_category_count(registry, RenalHepatic).to_string(),
    instrument_category_label(Perioperative) +
    "=" +
    registry_category_count(registry, Perioperative).to_string(),
    instrument_category_label(ObstetricPediatric) +
    "=" +
    registry_category_count(registry, ObstetricPediatric).to_string(),
    instrument_category_label(Workflow) +
    "=" +
    registry_category_count(registry, Workflow).to_string(),
  ]
}

///|
pub fn registry_has_duplicate_ids(registry : InstrumentRegistry) -> Bool {
  let ids = []
  for entry in registry.entries {
    if ids.contains(entry.id) {
      return true
    }
    ids.push(entry.id)
  }
  false
}

///|
pub fn registry_is_release_ready(registry : InstrumentRegistry) -> Bool {
  registry_validate(registry) && !registry_has_duplicate_ids(registry)
}

///|
pub fn registry_filter_valid(
  registry : InstrumentRegistry,
) -> InstrumentRegistry {
  let entries = registry.entries.filter(validate_metadata)
  { entries, revision: registry.revision }
}

///|
pub fn registry_merge(
  primary : InstrumentRegistry,
  additions : InstrumentRegistry,
) -> InstrumentRegistry {
  let merged = primary.entries.copy()
  for candidate in additions.entries {
    let mut replaced = false
    for index = 0; index < merged.length(); index = index + 1 {
      if merged[index].id == candidate.id {
        merged[index] = candidate
        replaced = true
      }
    }
    if !replaced {
      merged.push(candidate)
    }
  }
  { entries: merged, revision: additions.revision }
}

///|
pub fn registry_select(
  registry : InstrumentRegistry,
  ids : Array[String],
) -> InstrumentRegistry {
  let entries = []
  for id in ids {
    match registry_find(registry, id) {
      Some(entry) => entries.push(entry)
      None => ()
    }
  }
  { entries, revision: registry.revision }
}

///|
pub fn registry_revision_label(registry : InstrumentRegistry) -> String {
  "registry/" + registry.revision + "/" + registry_size(registry).to_string()
}
