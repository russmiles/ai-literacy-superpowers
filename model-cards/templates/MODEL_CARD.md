---
model_name: <provider>/<model-name>
provider: <Anthropic | OpenAI | Google | Meta | Mistral | xAI | Cohere | Alibaba | other>
model_version: <as-stated-by-provider>
last_researched: YYYY-MM-DD
card_version: 0.1.0
researcher: model-card-researcher (claude-opus-4-7[1m])
sources:
  - tier: 1
    url: <provider docs URL>
    fetched: YYYY-MM-DD
  - tier: 2
    url: <huggingface URL or "n/a">
    fetched: YYYY-MM-DD
  - tier: 3
    url: <arxiv URL or "n/a">
    fetched: YYYY-MM-DD
  - tier: 4
    url: <web URL or "n/a">
    fetched: YYYY-MM-DD
---

# Model Card: {{provider}}/{{model-name}}

## 1. Model Details

What this model is, who released it, when, what kind of model it is. Cite
provider-stated identity, release date, model family, parameter count if
disclosed.

## 2. Intended Use

Primary uses, primary users, out-of-scope uses (per the provider's published
statements).

## 3. Factors

Relevant subgroups, environmental factors, instrumentation factors. Often
sparse for proprietary API-served models — fill with "Not publicly available"
where the provider has not disclosed.

## 4. Metrics

Performance measures the provider reports. Cite each metric with its source
tier; prefer tier-1 (provider docs) and tier-3 (release paper).

## 5. Evaluation Data

Datasets used to evaluate (per the provider's published statements). Often
"Not publicly available" for proprietary models — say so explicitly.

## 6. Training Data

Datasets used to train (per the provider's published statements). Frequently
"Not publicly available" for proprietary models — say so explicitly.

## 7. Quantitative Analyses

Disaggregated performance, where provider has published this. Cite metrics
table from release paper or provider docs; record the date of the analysis.

## 8. Ethical Considerations

Risks, mitigations, known failure modes — preferring the release paper as
primary source (tier 3); supplemented by provider statements (tier 1) and
independent evaluations (tier 4) where relevant.

## 9. Caveats and Recommendations

What this card cannot tell you (sections marked "Not publicly available" and
why). Recommendations for use given the model's documented strengths and
limitations. Conflicts between tier-1 and tier-4 sources are recorded here.

## 10. Operational Details

Best-effort structured fields; missing values are written as "Not publicly
available" rather than omitted:

- **Pricing** — input/output cost per million tokens; pricing tier; as-of
  date. Cite the pricing page (tier 1).
- **Context window** — maximum input + output tokens.
- **Knowledge cutoff** — provider-stated training cutoff date.
- **Supported APIs/SDKs** — provider's API name(s); language SDKs; OpenAI
  Chat Completions compatibility if applicable.
- **Latency tier** — provider's stated latency tier or category, if any.
- **Tool / structured-output support** — function calling, JSON mode, tool
  use, parallel tool calls.
- **Function calling** — supported, parallel-supported, schema format.
- **Fine-tuning availability** — yes/no/limited; cite the fine-tuning docs
  page if available.
- **Rate-limit notes** — provider-published rate limit tiers or quotas.
