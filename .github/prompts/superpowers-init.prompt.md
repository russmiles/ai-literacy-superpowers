---
name: superpowers-init
description: Full habitat setup — generates CLAUDE.md, HARNESS.md, AGENTS.md, MODEL_ROUTING.md, REFLECTION_LOG.md, agents, CI templates
---

# Superpowers Init

Set up the full AI Literacy habitat for this project.

1. Run /harness-init to discover stack and generate HARNESS.md

2. Generate project files from templates:
   - CLAUDE.md from `#file:templates/CLAUDE.md`
   - AGENTS.md from `#file:templates/AGENTS.md`
   - MODEL_ROUTING.md from `#file:templates/MODEL_ROUTING.md`
   - REFLECTION_LOG.md from `#file:templates/REFLECTION_LOG.md`

3. Set up CI from templates:
   - GitHub Actions: `#file:templates/ci-github-actions.yml`
   - Mutation testing: `#file:templates/ci-mutation-testing.yml`

4. Copy the health icon: `#file:templates/harness-health-icon.svg`

5. Create observability/snapshots/ directory

6. Present all generated files for review before committing

7. Suggest next steps: /harness-status, /harness-health, /assess
