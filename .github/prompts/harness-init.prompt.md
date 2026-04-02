---
name: harness-init
description: Initialize a harness for the current project — discover stack, ask about conventions, generate HARNESS.md
---

Set up a harness for this project.

1. Check if HARNESS.md already exists. If so, ask whether to re-initialize.

2. Dispatch discovery: scan the project for languages, build systems,
   test frameworks, CI configuration, linters, and formatters.

3. Ask the user about conventions: naming, file structure, error
   handling, documentation style.

4. Generate HARNESS.md from #file:templates/HARNESS.md with discovered
   stack and user-provided conventions.

5. For each discovered tool (linter, formatter, test runner), create a
   deterministic constraint entry.

6. Present the generated HARNESS.md for review before committing.
