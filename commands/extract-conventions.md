---
name: extract-conventions
description: Run a guided convention extraction session — surfaces tacit team knowledge through structured questions and maps answers to CLAUDE.md conventions and HARNESS.md constraints
---

# /extract-conventions

Guided, conversational convention extraction. Walks the developer
through five structured questions that surface tacit team knowledge,
then maps answers to enforceable artefacts.

Read the full skill before starting:
  `${CLAUDE_PLUGIN_ROOT}/skills/convention-extraction/SKILL.md`

## Process

### 1. Check Prerequisites

Verify CLAUDE.md exists at the project root. If not:
"No CLAUDE.md found. Run `/superpowers-init` to set up the habitat
first, then come back to extract conventions."

Verify HARNESS.md exists. If not:
"No HARNESS.md found. Run `/harness-init` to set up the harness first."

### 2. Introduce the Session

Print:

```text
## Convention Extraction

I'll ask five questions to surface your team's tacit conventions.
For each answer, I'll categorise it as:

- **Constraint** (must-follow) → goes in HARNESS.md
- **Convention** (should-follow) → goes in CLAUDE.md
- **Style preference** (nice-to-have) → goes in CLAUDE.md
- **Not encodable yet** → needs decomposition before encoding

Take your time — the conversation matters as much as the output.
```

### 3. Ask the Five Questions

Ask each question one at a time using `AskUserQuestion`. Wait for the
answer before proceeding. After each answer:

1. Restate the answer to confirm understanding
2. Ask one follow-up to sharpen the answer
3. Propose a categorisation (constraint/convention/preference/not
   encodable)
4. Confirm the categorisation with the developer

**Question 1:**
"What architectural decisions in this project should never be left to
individual judgment? These are the patterns where deviation is always
wrong, not a matter of taste."

**Question 2:**
"Which conventions are corrected most often when AI generates code for
this project? What does the AI get wrong that you keep having to fix?"

**Question 3:**
"Which security checks do you apply instinctively when reviewing code
in this project? Things you'd flag immediately without needing to
think about it."

**Question 4:**
"What triggers an immediate rejection in code review? The things that
are never acceptable regardless of context."

**Question 5:**
"What separates a clean refactoring from an over-engineered one in
this project? Where is the line between helpful abstraction and
unnecessary complexity?"

### 4. Compile and Present

After all five questions, compile the proposed additions:

```text
## Proposed Additions

### HARNESS.md Constraints (must-follow)

1. [Constraint name] — [rule]
2. [Constraint name] — [rule]

### CLAUDE.md Conventions (should-follow)

1. [Convention description]
2. [Convention description]

### CLAUDE.md Style Preferences (nice-to-have)

1. [Preference description]

### Not Encodable Yet (needs decomposition)

1. [Topic] — why it needs more work
```

Ask: "Does this look right? Want to add, remove, or recategorise
anything?"

### 5. Apply with Confirmation

After the developer approves:

1. **Append conventions to CLAUDE.md** — add a dated section:

   ```markdown
   ## Conventions (extracted YYYY-MM-DD)

   [conventions here]
   ```

2. **Add constraints to HARNESS.md** — add each as a new constraint
   entry in the Constraints section, following the existing format:

   ```markdown
   ### [Constraint name]

   - **Rule**: [rule text]
   - **Enforcement**: unverified
   - **Tool**: none yet
   - **Scope**: pr
   ```

   New constraints start as `unverified` — the team promotes them to
   `agent` or `deterministic` when enforcement tooling is ready.

3. **Do not overwrite existing content.** Always append. If a
   convention conflicts with an existing one, flag it and ask the
   developer to resolve.

### 6. Suggest Next Steps

Print:

```text
## Next Steps

- Run `/harness-audit` to verify which new constraints can be
  automatically enforced
- Use `/harness-constrain` to promote constraints from unverified
  to agent or deterministic
- Schedule a re-extraction in your quarterly operating cadence
- Share the updated CLAUDE.md and HARNESS.md with the team for review
```
