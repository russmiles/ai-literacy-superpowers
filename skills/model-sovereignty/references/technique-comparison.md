# Technique Comparison: Prompting vs RAG vs Fine-Tuning vs Distillation

## Quick Decision Table

| Factor | Prompting | RAG | Fine-Tuning | Distillation |
| --- | --- | --- | --- | --- |
| Best for | Flexible tasks, diverse problems | Volatile knowledge, large corpora | Stable behaviour, format compliance | Size/speed optimisation |
| Effort | Hours | Days-weeks | Weeks | Weeks-months |
| Data needed | None | Knowledge base | 5,000+ examples | Teacher model + dataset |
| Update speed | Instant | Instant (update knowledge base) | Retraining cycle required | Retraining cycle required |
| Consistency at scale | Variable | Variable (depends on retrieval) | High | High |
| Cost trajectory | Per-token (linear) | Per-token + infrastructure | Upfront + reduced per-token | Upfront + reduced per-token |
| Maintenance burden | Low | Medium (knowledge base curation) | High (retraining, evaluation) | High (retraining, evaluation) |

## When Each Technique Wins

**Prompting wins when:** Task diversity is high, requirements change
often, training data is limited, frontier model reasoning is needed,
or the team is still learning what works.

**RAG wins when:** The limitation is knowledge (missing facts, stale
information), knowledge changes frequently, the knowledge base is
too large for context windows, or errors come from missing information
rather than wrong behaviour.

**Fine-tuning wins when:** The limitation is behaviour (inconsistent
format, style drift, domain-specific decision logic), the behaviour
is stable and well-defined, you have 5,000+ quality training examples,
and the use case justifies the maintenance cost.

**Distillation wins when:** The limitation is size or speed, a smaller
model at 90% quality is acceptable, and you need deployment on edge
devices or in latency-sensitive scenarios.

## The Hybrid Pattern

The most effective production deployments layer these techniques:

1. Fine-tune a base model for domain behaviour (stable patterns)
2. Add RAG for current knowledge (volatile facts)
3. Use prompting to orchestrate the interaction (coordination)

This separates concerns: behaviour is learned (fine-tuning), knowledge
is retrieved (RAG), and orchestration is designed (prompting).
