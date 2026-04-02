---
name: assess
description: Run an AI literacy assessment — scan the repo for evidence, score three disciplines, produce a timestamped report
---

Run a full AI literacy assessment on this repository.

1. Read #file:skills/ai-literacy-assessment/SKILL.md for the assessment
   methodology, scoring heuristic, and template

2. Scan the repo for evidence across three disciplines:
   - Context engineering (CLAUDE.md, MODEL_ROUTING.md, skills, hooks)
   - Architectural constraints (HARNESS.md, CI, coverage, mutation testing)
   - Guardrail design (agents, specs, compound learning, observability)

3. Score each discipline 0-5. The weakest determines the ceiling.

4. Write the assessment to `assessments/YYYY-MM-DD-assessment.md`

5. Update the README AI Literacy badge with the assessed level

6. Check whether README needs broader updates (stale counts, mechanism map)

7. Capture a reflection via the reflect workflow
