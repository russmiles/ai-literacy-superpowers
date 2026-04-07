---
title: Garbage Collection
layout: default
parent: Explanation
nav_order: 5
---

# Garbage Collection

Entropy accumulates in any codebase over time: dead code, stale dependencies, abandoned conventions, TODO comments that outlive their relevance. Garbage collection in the harness engineering sense is the scheduled practice of declaring what "clean" looks like and running periodic checks to measure how far the codebase has drifted from that standard. GC rules do not block individual merges; they produce reports that draw attention to accumulating problems before they become costly to unwind.

{: .label .label-yellow } Coming Soon
