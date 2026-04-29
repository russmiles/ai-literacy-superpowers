# model-cards

Research and author Mitchell-extended model cards from a model name.

A sister plugin to [ai-literacy-superpowers](../ai-literacy-superpowers/) in
the same marketplace. Aimed at evaluators researching new models.

## What it does

- `/model-card create <model-name> [--provider X] [--out path]` — researches
  the model through a tiered source strategy (provider docs → HuggingFace →
  arXiv → web), produces a draft card, presents a review summary, and (on
  accept) writes the card to your library.
- `/model-card seed` — populates the library with cards for a shipped list of
  14 frontier LLMs from major providers.

## Install

```bash
# In Claude Code
claude plugin install model-cards@ai-literacy-superpowers

# In Copilot CLI
copilot plugin install model-cards@ai-literacy-superpowers
```

## Library location

Default: `~/.claude/model-cards/<provider>/<model-name>.md`

Override with the `--out` flag (directory override; cards still land beneath
it as `<provider>/<model-name>.md`) or the `MODEL_CARDS_DIR` env var.

## Card format

10-section Mitchell-extended:

1. Model Details
2. Intended Use
3. Factors
4. Metrics
5. Evaluation Data
6. Training Data
7. Quantitative Analyses
8. Ethical Considerations
9. Caveats and Recommendations
10. Operational Details (this plugin's extension — pricing, context window,
    knowledge cutoff, supported APIs/SDKs, latency, tool/structured-output
    support, function calling, fine-tuning availability, rate limit notes)

Cards include per-claim citations of the form `[T<n>.<m>]` where `n` is the
source tier (1 = provider docs, 2 = HuggingFace, 3 = arXiv, 4 = web).

## Honesty rules

- Sections that the agent cannot find information for are filled with "Not
  publicly available" — never fabricated.
- If tier-1 and tier-2 are both silent on the model itself (the agent
  cannot confirm the model exists), the agent refuses to create the card and
  surfaces the result to the user. Cards are not produced for non-existent or
  unconfirmed model names.
- If a tier-4 (web) claim conflicts with a tier-1 (provider docs) claim,
  tier-1 wins; the conflict is flagged in Caveats.

## Roadmap

- `/model-card list` — browse the library (issue #233)
- `/model-card compare <a> <b>` — side-by-side card comparison (issue #234)
- `/model-card refresh <name>` — re-research a specific card (issue #235)
