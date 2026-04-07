---
title: The Three Enforcement Loops
layout: default
parent: Explanation
nav_order: 2
---

# The Three Enforcement Loops

The plugin structures verification into three loops — inner, middle, and outer — that operate at different timescales and with different tolerances for friction. The inner loop runs at edit time and is advisory, surfacing issues as suggestions without blocking work. The middle loop runs at PR time and is strict, with the authority to block a merge until failures are addressed. The outer loop runs on a schedule and is investigative, producing reports that feed back into the harness rather than blocking any single piece of work.

{: .label .label-yellow } Coming Soon
