# Governance Constraint Anti-Patterns

Each anti-pattern shows governance language that sounds precise but
is not falsifiable, paired with a rewrite that encodes operational
meaning.

## "Ensure fairness"

**Anti-pattern constraint:**

- Rule: The system must ensure fairness in all AI-generated outputs
- Enforcement: unverified
- Tool: none yet

**Why it fails:** "Fairness" means different things in different
frames. To the regulator: equal treatment across protected groups.
To the engineer: consistent outputs for consistent inputs. To the
user: "I got a good result." None of these are verified by the
constraint as written.

**Falsifiable rewrite:**

- Rule: AI-generated outputs must produce identical recommendations
  for identical inputs regardless of demographic attributes in the
  prompt. Verified by running a differential test suite with synthetic
  population data on each release.
- Governance requirement: EU AI Act Article 10 — non-discrimination
  in training data and outputs
- Operational meaning: automated differential testing on synthetic
  populations before release
- Verification method: deterministic — differential test suite
- Evidence: test report showing zero divergence across protected
  attributes
- Failure action: block release, file incident, review training data

## "Maintain transparency"

**Anti-pattern constraint:**

- Rule: All AI systems must maintain transparency
- Enforcement: agent
- Tool: harness-enforcer

**Why it fails:** The regulator's "transparency" (auditable decision
trail) is not the engineer's "transparency" (interpretable model
weights) is not the user's "transparency" (understanding why this
happened to me).

**Falsifiable rewrite:**

- Rule: Every AI-assisted code change must include a commit message
  that identifies which parts were AI-generated and what prompt
  produced them. Verified by commit message format check.
- Governance requirement: internal AI use policy — traceability of
  AI-assisted work
- Operational meaning: commit messages must tag AI-generated code
  with provenance
- Verification method: deterministic — commit message regex check
- Evidence: git log showing tagged commits
- Failure action: CI rejects commit, author must add provenance tag

## "Require human oversight"

**Anti-pattern constraint:**

- Rule: Human oversight is required for all AI-generated code
- Enforcement: unverified
- Tool: none yet

**Why it fails:** "Oversight" can mean: reading the diff (minimal),
running the tests and checking edge cases (moderate), or
understanding the design intent and verifying it matches requirements
(substantive). The constraint does not say which.

**Falsifiable rewrite:**

- Rule: Every PR containing AI-generated code must have at least one
  review that includes (a) a substantive comment on design intent,
  (b) confirmation that tests cover the changed behaviour, and (c)
  verification that the change matches the linked spec. Verified by
  PR review audit.
- Governance requirement: internal AI governance policy — meaningful
  human review
- Operational meaning: PR review must demonstrate engagement with
  design, tests, and spec alignment
- Verification method: agent — harness-enforcer reviews PR comments
  for substantive engagement
- Evidence: PR review record with design, test, and spec comments
- Failure action: PR cannot merge until substantive review is added

## "Comply with regulations"

**Anti-pattern constraint:**

- Rule: All systems must comply with applicable regulations
- Enforcement: unverified
- Tool: none yet

**Why it fails:** This is a tautology. Every system must comply with
applicable regulations — the constraint adds no information. It
does not name the regulation, the specific requirement, or how
compliance is verified.

**Falsifiable rewrite:**

- Rule: Personal data processed by AI features must be anonymised
  before being sent to external model providers. Verified by network
  traffic inspection in CI.
- Governance requirement: GDPR Article 5(1)(c) — data minimisation
- Operational meaning: outbound API calls to model providers must
  not contain PII
- Verification method: deterministic — network mock in integration
  tests that fails if PII patterns detected in request payloads
- Evidence: CI test report showing PII scan pass
- Failure action: block merge, file data protection incident
