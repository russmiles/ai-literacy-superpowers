---
title: Progressive Hardening
layout: default
parent: Explanation
nav_order: 3
---

# Progressive Hardening

Progressive hardening is the constraint promotion ladder: constraints begin as unverified declarations in `HARNESS.md`, are promoted to agent-based review once you have a prompt that catches violations reliably, and are promoted again to deterministic enforcement once the constraint is understood precisely enough to express as a script or linter rule. Movement is always toward deterministic. Patterns of repeated agent catches are the signal that a constraint is ready to be promoted.

{: .label .label-yellow } Coming Soon
