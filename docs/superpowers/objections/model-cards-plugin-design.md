---
spec: docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md
date: 2026-04-29
mode: spec
diaboli_model: claude-opus-4-7[1m]
objections:
  - id: O1
    category: premise
    severity: high
    claim: "The 'driver satisfied' claim conflates 'I am the user' with 'a downstream consumer asked with a concrete use case', which were the conditions yesterday's reflection set for revisit — meaning the spec may be answering its own door."
    evidence: "Cross-references mention satisfaction of Driver 2 from yesterday's Conditions for Revisit list — but Driver 2 was 'a downstream consumer of the plugin asks for it with a concrete use case', and the author named themselves as the user."
    disposition: rejected
    disposition_rationale: "The objection's substance is acknowledged: 'the user is the user' is a weak satisfaction of yesterday's gate as written. Author exercises author's judgment to proceed anyway. The work is being undertaken because the author wants the artefact and finds the marketplace-shipped form acceptable; this stance is recorded honestly here rather than rationalised through the gate. Future similar judgments will be calibrated against this precedent — and against whether real users emerge to use the resulting plugin."
  - id: O2
    category: premise
    severity: high
    claim: "The audience-asymmetry pivot does not actually solve the dilution risk that killed Option A-E yesterday — it relocates it. Marketplace consumers see the new plugin in the listing whether they want evaluator tooling or not."
    evidence: "Marketplace integration adds a second plugins[] entry and bumps the listing version. The spec does not articulate why marketplace consumers want a sister plugin shipped, only why the author does."
    disposition: rejected
    disposition_rationale: "Author accepts that adding a sister plugin imposes a marketplace-listing cost on consumers and judges that cost acceptable. Marketplace consumers can ignore plugins they don't want; listing growth is the explicit cost of operating a marketplace. The asymmetry the objection identifies (one-sided ledger) is real but the missing side is small: cost-of-an-extra-listing-line per consumer is genuinely low."
  - id: O3
    category: alternatives
    severity: high
    claim: "A simpler shape — a personal scratch repo, a CLI tool, or a single skill — is not weighed against a sister plugin. Plugin-with-marketplace-listing is the most expensive shape on offer."
    evidence: "The Decisions table lists six clarifying questions but none ask 'should this be a plugin at all'. Q6a only debates the name suffix."
    disposition: rejected
    disposition_rationale: "Author chose plugin shape deliberately. Claude Code marketplace integration IS the value-add over CLI/personal-repo/skill alternatives — the plugin is invoked from inside the same tool the author is already using when evaluating models, with hybrid review-before-commit gating. CLI lacks Claude-Code coupling; personal repo lacks discoverability; single-skill lacks coherent invocation surface; doc-page is not actionable. The 'plugin or not' fork was implicit in the user's initial framing ('I'd like this plugin to be runnable when new models are released') — not absent from consideration, but not formally tabulated. Recording here as adjudicated rejection."
  - id: O4
    category: risk
    severity: high
    claim: "Hallucination-and-staleness risk treated as documentation problem (last_researched date, citations) rather than structural one. Authoritative-looking cards are exactly what users trust without re-verifying."
    evidence: "Risks section mentions citations make verification cheap; no expiry, no banner, no agent-side refusal when tier-1 is unreachable, no honesty-rule for tier-4-only sections."
    disposition: rejected
    disposition_rationale: "Rejected for v0.1.0. Author accepts hallucination/staleness risk as inherent to AI-generated cards; per-claim citation + last_researched date provide the verification surface; users opting into AI-generated cards implicitly accept the limitation. The hybrid review-before-commit gate (Q4) is the structural mitigation. Will revisit if real cards in the wild surface specific authoritative-looking-but-wrong examples — the cards will be exposed to scrutiny via the library; failures will be visible."
  - id: O5
    category: risk
    severity: high
    claim: "Agent training cutoff bounds knowledge of model identity. Several seed-list models may not exist or be misnamed; agent has no way to distinguish 'doesn't exist' from 'I don't know yet'. Honesty rule applies per-claim, not per-card."
    evidence: "Seed list includes gpt-5, o4, o4-mini, llama-4, grok-4, qwen3-coder etc. Honesty rules cover claim-level fabrication; no rule says 'refuse to create a card when tier-1+tier-2 silent on the model itself'."
    disposition: rejected
    disposition_rationale: "Rejected for v0.1.0. The failure mode (card full of 'Not publicly available' for a possibly-non-existent model) is acceptable for personal evaluation use — users will notice when a card has no real content and move on. The implementation plan may add a card-level honesty rule ('refuse if tier-1+tier-2 both silent on model existence') as a small enhancement; this rationale records the door open for that without making it a v0.1.0 blocker."
  - id: O6
    category: risk
    severity: medium
    claim: "Agent has WebFetch + global file write to ~/.claude/model-cards/. No provenance-hygiene rule: no prohibition on excerpting from authenticated URLs, no scrubbing of session-specific tokens, no flagging of 401-redirected pages."
    evidence: "Tools list includes WebFetch + Write. Default path is global per-user. Honesty rules cover fabrication and conflict resolution but not content-class safety."
    disposition: rejected
    disposition_rationale: "WebFetch's behaviour with authenticated URLs is a tool-implementation concern, not a spec concern. If WebFetch leaks authenticated content into research outputs, that is a Claude Code framework issue affecting many tools, not a model-cards plugin issue. The plugin will not specifically prohibit excerpting from authenticated URLs because doing so requires the agent to reliably detect 'this URL was authenticated' — which is exactly what the framework would need to do globally. Out of scope for v0.1.0."
  - id: O7
    category: risk
    severity: medium
    claim: "Seed flow underspecified for failure: 14 sequential web operations over 30-60 minutes will hit rate limits, transient failures, 4xx/5xx in real conditions. Spec describes happy path with one-line failed counter."
    evidence: "Seed flow steps describe iteration and final summary; no resume semantics, no idempotency for partial cards, no rate-limit backoff."
    disposition: rejected
    disposition_rationale: "Rejected for v0.1.0. Seed flow happy-path is sufficient for the use case (one-time bulk populate by the author). If failures are common in practice, --resume / --retry-failed flags can be added in v0.1.x as small enhancements without spec rework. The 'skip if card exists' check provides natural resumability for the most common case (re-run after partial success). Adding full failure-mode treatment now is premature."
  - id: O8
    category: scope
    severity: medium
    claim: "Embedding 14 specific frontier-model names as shipped plugin payload creates a maintenance contract not committed to. Names age faster than release cadence."
    evidence: "frontier-models.json ships 14 entries. Risks section says 'worth a reflection if cadence becomes onerous' — not a maintenance plan."
    disposition: rejected
    disposition_rationale: "Embedded seed list is intentional starter content. Plugin patch releases for seed updates are an acceptable operational cost given the value of an immediately-functional plugin on first install. The 'fetch-from-remote' alternative the objection proposes would couple the plugin to an external service the author does not control — a worse maintenance contract than periodic patch releases. If the cadence becomes painful, the seed list can be slimmed or fetched dynamically in a future version."
  - id: O9
    category: specification quality
    severity: medium
    claim: "Several configurability decisions underspecified: (a) --out flag (file or directory?), (b) provider-name resolution rules, (c) re-run-section <N> reference (template number or summary number?), (d) 'Top 3 most-cited' metric."
    evidence: "create command flags described once with no semantics; review summary mentions 'top 3 most-cited' without defining metric; provider resolution says 'agent infers from research' which is not a rule."
    disposition: rejected
    disposition_rationale: "Rejected as a spec-time blocker. The plugin author and implementer are the same person and will resolve these ambiguities consistently during implementation. The plan will pin: --out as a directory override (cards still go to <provider>/<model-name>.md beneath it); provider resolution as agent-inferred with user confirmation in the review step (already in spec); re-run-section <N> as template section number 1-10; 'Top 3 most-cited' as raw citation count. Recording these picks here so they're visible at adjudication time."
  - id: O10
    category: specification quality
    severity: medium
    claim: "Mitchell-extended Section 10 described as comma-separated wishlist not schema. No required-vs-optional marking, no per-field schema (pricing currency? as-of date?), no agent rule for missing field-level claims."
    evidence: "Section 10 lists pricing, context window, knowledge cutoff, supported APIs/SDKs, latency tier, tool/structured-output, function calling, fine-tuning availability, rate limits in one sentence."
    disposition: rejected
    disposition_rationale: "Section 10 fields are an evolving list; locking down a strict schema in v0.1.0 would be premature optimisation. Real cards will reveal which fields matter and which are routinely opaque. The implementation will treat all listed fields as best-effort with field-level 'Not publicly available' as the canonical missing-data answer (extending the section-level honesty rule); future schema strictness can be added once enough cards exist to inform it."
  - id: O11
    category: alternatives
    severity: medium
    claim: "Extending Mitchell from 9 to 10 sections produces non-standard artefact. Simpler alternative — 9 sections + Operational Details in frontmatter — preserves interoperability with downstream Mitchell-aware tooling."
    evidence: "Q3 rationale invokes 'industry-recognised' as a benefit of Mitchell then breaks the recognition by adding section 10. Trade-off not weighed."
    disposition: rejected
    disposition_rationale: "Mitchell-extended is a deliberate choice to capture consumer-evaluator data the original framework lacks. Interoperability with strict-Mitchell tooling is not a stated goal of this plugin. The objection's frontmatter alternative is reasonable; the chosen 10-section approach was selected during brainstorming for self-documentation (an empty section is more visible than a missing frontmatter key) and the trade-off is accepted. Cards from this plugin are 'Mitchell-shaped, with operational details' — the honest framing is the section-10 form."
  - id: O12
    category: scope
    severity: medium
    claim: "v0.1.0 ships 'no harness, no hooks, no scripts' but the existing version-consistency CI reads ai-literacy-superpowers/.claude-plugin/plugin.json singular — likely won't see the new plugin's version. Spec assumes existing harness covers what's needed without verifying."
    evidence: "Architecture asserts no new scaffolding; testing strategy says existing harness covers it; CLAUDE.md describes version-consistency as singular check."
    disposition: rejected
    disposition_rationale: "Valid CI integration concern but not a spec-blocker. The implementation plan will include a small task to extend version-check.yml to enumerate plugins via marketplace.json's plugins[] array OR add a separate per-plugin version-check job. The 'YAGNI applies' framing in the spec was overconfident — this is a known scope item that will surface in the plan, not a hidden landmine."
---

## O1 — premise — high

### Claim

The spec claims the conditions for revisit set by yesterday's reflection are satisfied because "the user is the user." That claim is load-bearing — it is the bridge between yesterday's "no" and today's "yes" — and it is weak. Yesterday's reflection asked for "downstream consumer asks for it with a concrete use case." The author asking themselves, on the same day they wrote the reflection, is not the test the reflection was designed to apply.

### Evidence

The spec's Cross-references section explicitly invokes Driver 2 from yesterday's Conditions for Revisit list as satisfied by "the user is the user; this spec is the implementation."

### Why this matters

The reflection's "wait for a downstream consumer" condition exists precisely to protect against the failure mode the spec author is now exhibiting — building because they want to, not because anyone has asked. If the test for "we have a downstream consumer" can be satisfied by the author naming themselves, the test does no work. The honest reframe is "I want to build this for myself; here is the cheapest shape that meets that need" — and then alternatives like a personal repo or a CLI tool become available. Dressing personal curiosity in marketplace-contribution clothing is the failure mode the reflection log was warning against.

## O2 — premise — high

### Claim

The "separate plugin" pivot relocates the dilution risk that killed Options A-E yesterday rather than dissolving it. The audience-asymmetry argument shows the new plugin would be a poor fit for the *existing plugin's* users; it does not show the new plugin is a good fit for the *marketplace's* users.

### Evidence

The Marketplace integration section adds a second `plugins[]` entry and bumps the listing version 0.2.3 → 0.3.0. The spec does not articulate who the new plugin's users are beyond the author and a hypothetical "evaluator" cohort whose existence is not evidenced.

### Why this matters

A marketplace is a contract with consumers. Adding plugins to a shared marketplace listing imposes a "should I install this?" cognitive cost on every consumer. The audience-asymmetry argument is a one-sided ledger: it accounts for cost imposed on the existing plugin's users by the new content, but not for cost imposed on marketplace consumers by the new listing entry. Yesterday's O5 surfaced this concern.

## O3 — alternatives — high

### Claim

The Decisions table walks through six clarifying questions and reaches a sister-plugin shape — but the question "should this be a plugin at all?" is missing. Cheaper shapes were not weighed: a personal git repo, a CLI tool, a single skill in the existing plugin, a docs page with a templated card. Plugin-with-marketplace-listing is the most expensive shape on the menu.

### Evidence

The Decisions table goes from "what models?" (Q1) directly to "tiered sources" (Q2), then through "card format", "invocation", "storage", "seed", "plugin name". Q6a debates only the name suffix. The fork "is the right shape a plugin, a CLI, a skill, or a doc?" is absent.

### Why this matters

At spec time, alternative shapes are still cheap to consider. After implementation begins, "we should have just made it a CLI" becomes academic. The spec's reasoning chain assumes plugin-shape from Q1 onward — every subsequent decision inherits that assumption. If the right shape is a CLI tool or a personal repo, the entire downstream plan is wasted.

## O4 — risk — high

### Claim

Hallucination-and-staleness risk treated as documentation problem with the wrong primitives. A card that LOOKS authoritative — Mitchell-format frontmatter, [T1.1] per-claim citations, ten well-organised sections — is precisely what users trust without re-verifying. Citations are evidence the agent fetched something, not evidence the agent understood it correctly.

### Evidence

The Risks section says citations make verification cheap and `last_researched` date makes staleness visible. Honesty rules say tier-1 wins conflicts. There is no rule for what happens when a tier-4 claim has no tier-1 to conflict with.

### Why this matters

Cross-references explicitly link this plugin to MODEL_ROUTING.md. That elevates the cards from "personal evaluation notes" to "input to operational decisions." A subtly-hallucinated pricing field, context-window number, or rate-limit description, presented in an authoritative format with citations, is exactly the failure mode that erodes trust in the whole plugin. "Per-claim citations make verification cheap" is true; the implicit assumption is "and so users will verify" — which is the assumption that fails.

## O5 — risk — high

### Claim

Agent training cutoff bounds what it knows about model identity. Several seed-list entries may not exist or be misnamed. Spec does not describe agent behaviour for "model name resolves to nothing in any tier" — does it produce a card full of "Not publicly available" (which looks authoritative for a model that may not exist), abort, or warn the user?

### Evidence

Seed list includes gpt-5, o4, o4-mini, gemini-2.5-pro, llama-4, mistral-large-3, grok-4, qwen3-coder. Honesty rules apply per-claim, not per-card.

### Why this matters

This is the most likely real-world failure mode for the seed command. A user runs `/model-card seed`, gets 14 files in their library, opens one for `o4`, sees a Mitchell-formatted card full of "Not publicly available" with sparse tier-4 citations to news articles, and concludes either (a) the model is real but opaque, or (b) the agent did its best. Neither conclusion is "this model may not exist under this name." "Refuse to create a card when tier-1 + tier-2 are both unreachable for the model itself" is a reasonable rule the spec lacks.

## O6 — risk — medium

### Claim

Per-user library at `~/.claude/model-cards/` is global; agent has WebFetch access. WebFetch can return content from authenticated URLs (logged-in HuggingFace, paid API portals, internal corporate proxies). No spec-level prohibition on excerpting from authenticated URLs and pasting fragments into a global file.

### Evidence

Tools list includes WebFetch + Write. Default path is global per-user. Honesty rules cover fabrication and conflict resolution; not content-class safety.

### Why this matters

Library location is global and persistent. A card containing an excerpt from a logged-in page outlives the research session. If the user later shares a card, they share whatever leaked. Mitigation is small (one-line agent-charter rule); spec does not have it.

## O7 — risk — medium

### Claim

Seed flow describes a happy path with no semantics for partial state. 14 sequential web operations over 30-60 minutes will hit rate limits, network blips, 4xx/5xx in real conditions. Spec does not describe resumability, idempotency for partial cards, or rate-limit backoff.

### Evidence

Seed flow steps describe iteration and final summary; one-line "failed" counter; nothing on resume or partial-write semantics.

### Why this matters

Once seed has run partially and crashed, the user is in undefined state. Re-running seed will skip cards that exist (good) but will not repair half-researched cards. The first-run experience for the marquee feature is the most likely place a real user encounters failure. Resumability is a spec-level concern (affects command shape: --resume? --retry-failed? failure log?), not implementation detail.

## O8 — scope — medium

### Claim

Embedding 14 specific frontier-model names as shipped plugin payload creates a maintenance contract the spec does not commit to. Names age faster than release cadence.

### Evidence

frontier-models.json ships 14 entries. Risks section disposes the cadence concern with "worth a reflection if cadence becomes onerous" — not a maintenance plan.

### Why this matters

Either (a) plugin gets out of date and users see stale seed lists embedded in v0.1.x for months, or (b) plugin requires patch releases just to refresh the list, churning CHANGELOG and version state for content that was never load-bearing. Cheaper shape — empty seed shipped with `--add` semantics, or fetch-from-remote with offline fallback — not weighed.

## O9 — specification quality — medium

### Claim

Several configurability decisions specified at one level above where two reasonable implementers will diverge: (a) `--out path` (file or directory?), (b) provider-name resolution rules, (c) `re-run-section <N>` reference, (d) "Top 3 most-cited" metric.

### Evidence

`--out path` described once with no semantics; "Top 3 most-cited" with no metric; provider resolution says "agent infers from research" which is not a rule.

### Why this matters

Each ambiguity will be resolved during implementation by an implementer who picks an answer; the picks may not be consistent with each other or with author intent. Spec-time is the cheap moment to fix this.

## O10 — specification quality — medium

### Claim

Mitchell-extended Section 10 described as comma-separated wishlist, not schema. No required-vs-optional marking, no per-field schema, no agent rule for missing field-level claims.

### Evidence

Section 10 lists pricing, context window, knowledge cutoff, supported APIs/SDKs, latency tier, tool/structured-output support, function calling, fine-tuning availability, rate limit notes — all in one sentence.

### Why this matters

If a card omits "fine-tuning availability" silently, is that a research gap or a "not applicable" signal? Implementer cannot tell from the spec. Future `/model-card compare` will be unable to compare cards reliably because the field set isn't fixed.

## O11 — alternatives — medium

### Claim

Extending Mitchell from 9 to 10 sections produces a non-standard artefact. Simpler alternative — 9 sections + Operational Details in YAML frontmatter, or as a sibling document — preserves interoperability with downstream tooling.

### Evidence

Q3 rationale invokes "industry-recognised" as a benefit of Mitchell, then breaks the recognition by adding section 10. The trade-off is not weighed.

### Why this matters

Once extended, cards are no longer Mitchell — they are a derivative. Tooling that consumes Mitchell cards will either ignore section 10 or reject the card. Frontmatter is an existing extension point and would carry operational details without breaking canon.

## O12 — scope — medium

### Claim

v0.1.0 ships 'no harness, no hooks, no scripts' but existing version-consistency CI reads `ai-literacy-superpowers/.claude-plugin/plugin.json` singular — likely won't see the new plugin's version. Spec assumes existing harness covers it without verifying.

### Evidence

Architecture asserts no new scaffolding; testing strategy says existing harness covers it; CLAUDE.md describes version-consistency as a singular check.

### Why this matters

If the version-consistency check reads only the existing plugin's files, the new plugin's version and changelog ship unchecked. Either the check already handles N plugins (then say so), or the spec's scope quietly grows.

## Explicitly not objecting to

- **The hybrid review-before-commit design (Q4)**: AI-generated content needs a human checkpoint before persistent library entry — correct and well-reasoned.
- **The tiered source strategy (Q2) at the conceptual level**: cheap-then-expensive ordering is sound.
- **The decision to defer compare/refresh/list to tracking issues**: scoping discipline is correct.
- **The Option A choice on plugin_version**: correctly applies yesterday's lesson.
- **The agent's tool boundary (no Edit, no Bash)**: appropriate for a research-and-author agent.
- **The spec's structural rigour**: tables and cross-references are spec hygiene done right.
- **The CHANGELOG and semver discipline for the new plugin**: mirrors existing pattern correctly.
- **The explicit deferrals in Non-goals**: clearly marked, correctly excluded.
