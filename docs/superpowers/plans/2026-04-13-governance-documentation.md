# Governance Documentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add governance documentation to the plugin's Jekyll docs site — 1 explanation, 1 tutorial, 5 how-to guides, and updates to 4 reference pages.

**Architecture:** Follow the existing Diataxis structure. Each new page gets Jekyll frontmatter with title, layout, parent, and nav_order. All pages are pure markdown — no code, no build steps. Reference pages are extended inline. Markdownlint validates every file.

**Tech Stack:** Jekyll (Just the Docs theme), Markdown, markdownlint-cli2

**Spec:** `docs/superpowers/specs/2026-04-13-governance-documentation-design.md`

**All paths relative to:** `/Users/russellmiles/code/russmiles/ai-literacy-superpowers/`

---

## Task 1: Write the Explanation Page

**Files:**

- Create: `docs/explanation/governance-as-meaning-alignment.md`

- [ ] **Step 1: Write the explanation page** — Create the file with the full content covering: the core problem (governance language carries different meanings in different frames), semantic drift (five stages), governance debt (fourth debt, vicious cycle), the three-frame translation problem, falsifiable governance (the three questions), and how the plugin helps (commands overview with links to tutorial and how-to guides). Use Jekyll frontmatter: title "Governance as meaning-alignment", parent "Explanation", nav_order 16.

- [ ] **Step 2: Run markdownlint** — `npx markdownlint-cli2 "docs/explanation/governance-as-meaning-alignment.md"` — Expected: 0 errors.

- [ ] **Step 3: Commit** — `git add docs/explanation/governance-as-meaning-alignment.md && git commit -m "Add governance-as-meaning-alignment explanation page"`

---

## Task 2: Write the Tutorial

**Files:**

- Create: `docs/tutorials/governance-for-your-harness.md`

- [ ] **Step 1: Write the tutorial** — Create the file walking through: spot governance language in existing constraints, run `/governance-audit` and read the report, write a governance constraint with `/governance-constrain` (show before/after), check health with `/governance-health` (explain the metrics table and colour thresholds), generate the dashboard with `--dashboard` flag. Use Jekyll frontmatter: title "Governance for Your Harness", parent "Tutorials", nav_order 8. End with "What you have now" and "Next steps" sections.

- [ ] **Step 2: Run markdownlint** — `npx markdownlint-cli2 "docs/tutorials/governance-for-your-harness.md"` — Expected: 0 errors.

- [ ] **Step 3: Commit** — `git add docs/tutorials/governance-for-your-harness.md && git commit -m "Add governance tutorial — audit, constrain, monitor workflow"`

---

## Task 3: Write the Five How-To Guides

**Files:**

- Create: `docs/how-to/write-a-governance-constraint.md`
- Create: `docs/how-to/run-a-governance-audit.md`
- Create: `docs/how-to/check-governance-health.md`
- Create: `docs/how-to/detect-semantic-drift.md`
- Create: `docs/how-to/build-a-governance-dashboard.md`

All guides follow the template in `docs/how-to/_template.md`: one-line description, prerequisites, numbered H2 steps, "What you have now", "Next steps". 60-120 lines each. Jekyll frontmatter with parent "How-to Guides".

- [ ] **Step 1: Write `write-a-governance-constraint.md`** — nav_order 29. Steps: start `/governance-constrain`, identify the governance requirement, translate to operational meaning, define verification/evidence/failure, complete three-frame check, review the written constraint. Show one complete example.

- [ ] **Step 2: Write `run-a-governance-audit.md`** — nav_order 30. Steps: run `/governance-audit`, read falsifiability scores (table: falsifiable/partial/vague), check drift stages (table: stages 1-5 with signals), review debt inventory (scoring matrix), act on recommendations. Note report save location.

- [ ] **Step 3: Write `check-governance-health.md`** — nav_order 31. Steps: run `/governance-health`, read the metrics table (explain each metric), interpret colours (green/amber/red thresholds table), act on recommendations. Shorter guide.

- [ ] **Step 4: Write `detect-semantic-drift.md`** — nav_order 32. Steps: recognise drift signals (implementation changed, process changed, regulatory changed, term meaning shifted), confirm with `/governance-audit` (focus on Stage 3+), rewrite drifted constraints with `/governance-constrain`, verify fix with `/governance-health`.

- [ ] **Step 5: Write `build-a-governance-dashboard.md`** — nav_order 33. Steps: run `/governance-health --dashboard`, open HTML file, review six dashboard sections (table describing each), read the signals (what to watch for), regenerate after each quarterly audit. Mention portfolio integration.

- [ ] **Step 6: Run markdownlint on all five** — `npx markdownlint-cli2 "docs/how-to/write-a-governance-constraint.md" "docs/how-to/run-a-governance-audit.md" "docs/how-to/check-governance-health.md" "docs/how-to/detect-semantic-drift.md" "docs/how-to/build-a-governance-dashboard.md"` — Expected: 0 errors.

- [ ] **Step 7: Commit** — `git add docs/how-to/write-a-governance-constraint.md docs/how-to/run-a-governance-audit.md docs/how-to/check-governance-health.md docs/how-to/detect-semantic-drift.md docs/how-to/build-a-governance-dashboard.md && git commit -m "Add five governance how-to guides"`

---

## Task 4: Update Reference Pages

**Files:**

- Modify: `docs/reference/agents.md`
- Modify: `docs/reference/commands.md`
- Modify: `docs/reference/skills.md`
- Modify: `docs/reference/hooks.md`

- [ ] **Step 1: Update `agents.md`** — Change "ships 10 agents" to "ships 11 agents". Add "## Governance Agents" section with `governance-auditor` entry (Tools, Dispatched by, Trust boundary, description). Add row to Tool Summary table. Follow the existing entry format (see harness-auditor or assessor entries for pattern).

- [ ] **Step 2: Update `commands.md`** — Change "All 15 slash commands" to "All 18 slash commands". Add "## Governance" section with three entries: `/governance-constrain` (skills read, agents dispatched, description), `/governance-audit`, `/governance-health`. Follow existing entry format (see `/harness-audit` for pattern).

- [ ] **Step 3: Update `skills.md`** — Change "ships 24 skills" to "ships 27 skills". Add "## Governance" section with three entries: `governance-constraint-design`, `governance-audit-practice`, `governance-observability`. One paragraph each describing coverage. Follow existing entry format.

- [ ] **Step 4: Update `hooks.md`** — Add "### Governance drift check (command)" entry after the last Stop hook. Include Event, Matcher, Type, Script, Timeout, and description of what it detects and nudges. Follow existing entry format (see drift-check or curation-nudge).

- [ ] **Step 5: Run markdownlint** — `npx markdownlint-cli2 "docs/reference/agents.md" "docs/reference/commands.md" "docs/reference/skills.md" "docs/reference/hooks.md"` — Expected: 0 errors.

- [ ] **Step 6: Commit** — `git add docs/reference/agents.md docs/reference/commands.md docs/reference/skills.md docs/reference/hooks.md && git commit -m "Add governance entries to reference pages (agents, commands, skills, hooks)"`

---

## Task 5: Final Verification

- [ ] **Step 1: Run markdownlint on all 11 files** — `npx markdownlint-cli2 "docs/explanation/governance-as-meaning-alignment.md" "docs/tutorials/governance-for-your-harness.md" "docs/how-to/write-a-governance-constraint.md" "docs/how-to/run-a-governance-audit.md" "docs/how-to/check-governance-health.md" "docs/how-to/detect-semantic-drift.md" "docs/how-to/build-a-governance-dashboard.md" "docs/reference/agents.md" "docs/reference/commands.md" "docs/reference/skills.md" "docs/reference/hooks.md"` — Expected: 0 errors across all files.

- [ ] **Step 2: Verify cross-references** — Check that all internal links between governance doc pages point to existing files.

- [ ] **Step 3: Verify nav_order uniqueness** — `grep -r "nav_order" docs/explanation/ docs/tutorials/ docs/how-to/ docs/reference/` — Confirm no duplicate values within the same parent.

- [ ] **Step 4: Verify file count** — 7 new files (1 explanation + 1 tutorial + 5 how-to), 4 modified reference files.
