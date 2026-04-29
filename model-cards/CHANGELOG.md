# Changelog

## 0.1.0 — 2026-04-29

### Added

- Initial release. `/model-card create <name>` for research-and-author flow with
  hybrid review-before-commit. `/model-card seed` for bulk-populate from the
  shipped 14-model frontier seed list.
- Mitchell-extended card template (9 canonical sections + Operational Details).
- Tiered source strategy: provider docs → HuggingFace → arXiv → web search.
- Per-claim citation format: `[T<n>.<m>]` resolving via per-card frontmatter.
- Default library at `~/.claude/model-cards/<provider>/<model-name>.md`;
  configurable via `--out` flag (directory override) and `MODEL_CARDS_DIR` env var.
- Spec, diaboli adjudication, and choice-cartograph stories preserved at
  `docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md` and the
  matching objections / stories records.
