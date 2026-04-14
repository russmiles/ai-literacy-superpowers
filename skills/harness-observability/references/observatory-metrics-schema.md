# Observatory Metrics Schema

This document defines the versioning policy for the YAML metrics block
appended to every harness health snapshot. The Observatory and any other
machine consumer of snapshot files relies on this schema being stable
and versioned.

## Current Version: 1.1.0

The `observatory_metrics` block contains structured, typed metrics
across five top-level sections:

| Section | Purpose |
|---------|---------|
| `habitat_configuration` | Context depth, constraint maturity, entropy management, compound learning, feedback loops, agent delegation, observability |
| `outcomes` | Mutation kill rates and cost indicators |
| `operational_cadence` | Days since key operations and overdue flags |
| `schema_version` | The version of this schema (string) |
| `plugin_version` | The plugin version that generated the snapshot |
| `timestamp` | ISO 8601 UTC timestamp of snapshot generation |

For the full field definitions and generation rules, see
`snapshot-format.md` section Observatory Metrics Block.

## Versioning Policy

The `schema_version` field in the YAML block identifies which version
of this schema was used to generate the snapshot. Consumers check this
field before parsing.

### Patch (1.0.x)

Documentation clarification only. No structural change to the YAML
block. Observatory parsers are unaffected and do not need updating.

**Examples:** fixing a typo in this document, clarifying a generation
rule, adding an explanatory note.

### Minor (1.x.0)

A new field is added. Existing fields are unchanged in name, type, and
semantics. The change is backwards-compatible — Observatory parsers
should add extraction for the new field but will not break on older
snapshots that lack it.

**Examples:** adding a new metric under `habitat_configuration`,
adding a new section alongside `outcomes`.

**Parser guidance:** Use safe access (e.g. `.get()` or optional
chaining) for fields introduced after 1.0.0. Check `schema_version`
to know which fields are guaranteed to be present.

### Major (x.0.0)

A field is renamed, removed, or its semantics change. This is a
breaking change. Observatory parsers must be updated before consuming
snapshots with the new major version. Major bumps should be extremely
rare.

**Examples:** renaming `enforcement_ratio` to `enforcement_score`,
removing the `signal_distribution` object, changing `velocity` from
promotions-per-week to promotions-per-month.

**Parser guidance:** On encountering an unrecognised major version,
parsers should log a warning and skip the block rather than crash.

## Release Process

When the schema changes:

1. Update the schema definition in `snapshot-format.md`
2. Bump the version in this document's "Current Version" heading
3. Add an entry to the Changelog section below
4. Update the `schema_version` value in the snapshot format spec
5. Flag the schema version bump in the plugin's release notes and
   CHANGELOG.md so Observatory maintainers are aware

## Changelog

### 1.1.0

Backwards-compatible additions:

- Added `regression_indicators` section with `snapshot_stale`,
  `snapshot_age_days`, `cadence_non_compliant_count`,
  `consecutive_zero_reflection_weeks`, and `regression_flag` fields
- Expanded `feedback_loops` with per-loop `active` and
  `first_activated` fields (replaces flat `advisory_active` etc.
  booleans). The `coverage` summary field is retained for backwards
  compatibility
- Added `configured_cadence` and `cadence_threshold_days` to the
  `observability` section
- Expanded governance YAML block (separate `schema_version`) with
  `falsifiable_count`, `vague_count`, `drift_stage`, and
  `debt_total_score` fields
- Added session metadata to reflection entry format (not in YAML
  block — in REFLECTION_LOG.md entries)

### 1.0.0

Initial release. Includes:

- `habitat_configuration`: context depth with per-layer freshness,
  constraint maturity with per-constraint detail, entropy management,
  compound learning with signal distribution and velocity, feedback
  loops, agent delegation, and observability with meta-checks
- `outcomes`: mutation kill rates (aggregate and per-language) and
  cost indicators
- `operational_cadence`: days since audit/assess/reflect with overdue
  flags
