# Spec-First Discipline Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enforce that feature/behaviour-change PRs have a spec committed as the first commit on the branch, via a deterministic CI check and an agent-quality review.

**Architecture:** Three changes — a new GitHub Actions workflow for the deterministic commit-ordering check, two new constraint entries in HARNESS.md, and an update to the harness-enforcer agent prompt to cover intent-quality review. No new skills, commands, or dependencies.

**Tech Stack:** Bash (CI workflow scripts), Markdown (HARNESS.md, agent prompt), YAML (GitHub Actions workflow)

---

## File Map

| Action | Path | Responsibility |
|--------|------|---------------|
| Create | `.github/workflows/spec-first-check.yml` | Deterministic CI gate — checks first commit contains only a spec file |
| Modify | `HARNESS.md:108-136` | Add two new constraints after "Spec-scoped changes" |
| Modify | `ai-literacy-superpowers/agents/harness-enforcer.agent.md:43-103` | Add intent-quality review responsibility |

---

### Task 1: Create the spec-first-check CI workflow

**Files:**
- Create: `.github/workflows/spec-first-check.yml`

- [ ] **Step 1: Create the workflow file**

Write `.github/workflows/spec-first-check.yml` with the following content:

```yaml
# Spec-first commit ordering check for pull requests.
#
# Verifies that the first commit on a feature branch contains only
# a spec file in docs/superpowers/specs/. Bug-fix and maintenance
# PRs are exempt.

name: Spec-First Check

on:
  pull_request:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  check:
    name: Check spec-first commit ordering
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd  # v6.0.2
        with:
          fetch-depth: 0

      - name: Check for exemption
        id: exempt
        run: |
          BRANCH="${{ github.head_ref }}"
          echo "Branch: $BRANCH"

          # Exempt by branch prefix
          if [[ "$BRANCH" == fix/* ]] || [[ "$BRANCH" == chore/* ]]; then
            echo "exempt=true" >> "$GITHUB_OUTPUT"
            echo "Exempt by branch prefix: $BRANCH"
            exit 0
          fi

          echo "exempt=false" >> "$GITHUB_OUTPUT"

      - name: Check for label exemption
        id: label_exempt
        if: steps.exempt.outputs.exempt == 'false'
        uses: actions/github-script@60a0d83039c74a4aee543508d2ffcb1c3799cdea  # v7.0.1
        with:
          script: |
            const labels = context.payload.pull_request?.labels || [];
            const exemptLabels = ['bug', 'fix', 'chore', 'maintenance'];
            const isExempt = labels.some(l => exemptLabels.includes(l.name));
            core.setOutput('exempt', isExempt.toString());
            if (isExempt) {
              console.log(`Exempt by label: ${labels.map(l => l.name).join(', ')}`);
            }

      - name: Verify first commit is spec-only
        if: steps.exempt.outputs.exempt == 'false' && steps.label_exempt.outputs.exempt == 'false'
        run: |
          BASE="origin/${{ github.base_ref }}"

          # Get the first commit on this branch (oldest commit not on base)
          FIRST_COMMIT=$(git rev-list --reverse "$BASE"..HEAD | head -1)

          if [ -z "$FIRST_COMMIT" ]; then
            echo "::error::No commits found on this branch"
            exit 1
          fi

          echo "First commit: $FIRST_COMMIT"
          echo "Message: $(git log --format=%s -1 "$FIRST_COMMIT")"

          # Get files changed in the first commit
          FILES=$(git diff-tree --no-commit-id --name-only -r "$FIRST_COMMIT")
          echo ""
          echo "Files in first commit:"
          echo "$FILES"

          if [ -z "$FILES" ]; then
            echo "::error::First commit has no files"
            exit 1
          fi

          # Check that at least one file is a spec
          SPEC_COUNT=0
          NON_SPEC_COUNT=0
          while IFS= read -r file; do
            if [[ "$file" == docs/superpowers/specs/*.md ]]; then
              SPEC_COUNT=$((SPEC_COUNT + 1))
            else
              NON_SPEC_COUNT=$((NON_SPEC_COUNT + 1))
              echo "::error::Non-spec file in first commit: $file"
            fi
          done <<< "$FILES"

          if [ "$SPEC_COUNT" -eq 0 ]; then
            echo ""
            echo "::error::First commit must contain a spec file in docs/superpowers/specs/"
            echo ""
            echo "Feature and behaviour-change PRs require a spec committed as the"
            echo "first commit on the branch. The spec should be in:"
            echo "  docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md"
            echo ""
            echo "If this is a bug fix or maintenance PR, add one of these labels:"
            echo "  bug, fix, chore, maintenance"
            echo "Or use a branch prefix: fix/, chore/"
            exit 1
          fi

          if [ "$NON_SPEC_COUNT" -gt 0 ]; then
            echo ""
            echo "::error::First commit must contain ONLY spec files"
            echo "Found $NON_SPEC_COUNT non-spec file(s) alongside the spec."
            echo "Commit your spec separately before adding implementation code."
            exit 1
          fi

          echo ""
          echo "Spec-first check passed: $SPEC_COUNT spec file(s), no other files"
```

- [ ] **Step 2: Verify the workflow YAML is valid**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/spec-first-check.yml'))"`
Expected: No output (valid YAML)

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/spec-first-check.yml
git commit -m "Add spec-first commit ordering CI workflow

Checks that the first commit on feature branches contains only
spec files. Bug-fix and maintenance PRs are exempt by label or
branch prefix."
```

---

### Task 2: Add constraints to HARNESS.md

**Files:**
- Modify: `HARNESS.md:117-136` (insert after "Spec-scoped changes", before "Version consistency")

- [ ] **Step 1: Add the two new constraints**

Insert the following after the "Spec-scoped changes" block (after line 117) and before the "Version consistency" block:

```markdown
### Spec-first commit ordering

- **Rule**: For feature and behaviour-change PRs, the first commit on
  the branch must contain only a spec file in `docs/superpowers/specs/`.
  No implementation code may appear in that commit. Bug-fix, dependency,
  and maintenance PRs (labelled `bug`, `fix`, `chore`, `maintenance` or
  branch-prefixed `fix/`, `chore/`) are exempt.
- **Enforcement**: deterministic
- **Tool**: .github/workflows/spec-first-check.yml
- **Scope**: pr

### Spec captures intent

- **Rule**: The spec file in a feature PR must describe the problem
  being solved, the chosen approach, and the expected outcome. The
  implementation in the PR should trace back to what the spec describes.
- **Enforcement**: agent
- **Tool**: harness-enforcer agent
- **Scope**: pr
```

- [ ] **Step 2: Update the Status section constraint count**

Change the constraint count from `9/9` to `11/11` (two new constraints added).

- [ ] **Step 3: Verify HARNESS.md passes markdownlint**

Run: `npx markdownlint-cli2 "HARNESS.md"`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add HARNESS.md
git commit -m "Add spec-first and spec-intent constraints to HARNESS.md

Two new constraints: deterministic check for spec commit ordering,
agent review for spec quality. Both exempt bug-fix and maintenance PRs."
```

---

### Task 3: Extend the harness-enforcer agent prompt

**Files:**
- Modify: `ai-literacy-superpowers/agents/harness-enforcer.agent.md:43-103`

- [ ] **Step 1: Add the intent-review responsibility**

In `ai-literacy-superpowers/agents/harness-enforcer.agent.md`, add the following section after the "Your Core Responsibilities" block (after line 48, before "Verification Process"):

```markdown
**Spec Intent Review (for "Spec captures intent" constraint):**

When reviewing a PR for the "Spec captures intent" constraint:

1. Find the spec file in the PR (should be in `docs/superpowers/specs/`)
2. Read the spec and check for three things:
   - **Problem**: Does the spec describe what problem is being solved
     and why it matters?
   - **Approach**: Does the spec describe the chosen design or approach?
   - **Outcome**: Does the spec describe the expected result or
     behaviour change?
3. Compare the spec to the implementation files in the PR — does the
   code deliver what the spec describes? Flag significant divergence.
4. Report findings per the standard format. A spec that covers all
   three areas and aligns with the implementation passes. A spec that
   is missing any area or diverges significantly from the code fails.
```

- [ ] **Step 2: Verify the agent file has valid frontmatter**

Run: `head -26 ai-literacy-superpowers/agents/harness-enforcer.agent.md`
Expected: Valid YAML frontmatter with `name`, `description`, `model`, `color`, `tools`

- [ ] **Step 3: Verify markdownlint passes**

Run: `npx markdownlint-cli2 "ai-literacy-superpowers/agents/harness-enforcer.agent.md"`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/agents/harness-enforcer.agent.md
git commit -m "Extend harness-enforcer with spec intent review

Adds guidance for the 'Spec captures intent' agent constraint:
check problem, approach, and outcome coverage, then compare
against PR implementation."
```

---

### Task 4: Final verification

- [ ] **Step 1: Run all markdownlint checks**

Run: `npx markdownlint-cli2 "**/*.md"`
Expected: No errors

- [ ] **Step 2: Verify all shell scripts still pass syntax check**

Run: `find . -name "*.sh" -not -path "./.git/*" -exec bash -n {} +`
Expected: No errors

- [ ] **Step 3: Verify YAML validity of new workflow**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/spec-first-check.yml'))"`
Expected: No output (valid YAML)

- [ ] **Step 4: Count constraints in HARNESS.md matches status**

Run: `grep -c '^### ' HARNESS.md`
Expected: count includes the new constraints, and Status section says the right number

- [ ] **Step 5: Push and create PR**

```bash
git push
```

Create a PR that references the spec and explains the two new constraints.
