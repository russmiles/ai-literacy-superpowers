# Model Sovereignty Decision Framework

## Data Classification as Prerequisite

Before choosing a model or hosting option, classify the data that
flows through your AI interactions:

| Classification | Definition | Routing rule |
| --- | --- | --- |
| Public | No sensitivity constraints | Any model, any hosting |
| Internal | Company-internal, not regulated | Cloud APIs acceptable with appropriate ToS |
| Sensitive | PII, financial, health, trade secrets | Requires assessment — cloud private endpoints or self-hosted |
| Restricted | Regulatory residency requirements | Self-hosted only, non-negotiable |

## Decision Tree

```text
Does data require local processing?
├── YES → Self-hosted model required for those interactions
│         Does knowledge change frequently?
│         ├── YES → Self-hosted model + RAG layer
│         └── NO  → Does model need consistent domain behaviour?
│                   ├── YES → Self-hosted + fine-tuned (LoRA/QLoRA)
│                   └── NO  → Self-hosted with prompting
└── NO  → Does knowledge change frequently?
          ├── YES → Cloud API + RAG layer
          └── NO  → Does model need consistent domain behaviour?
                    ├── YES → Cloud API fine-tuning or cloud + local fine-tuned
                    └── NO  → Is baseline load > 30M tokens/day?
                              ├── YES → Self-hosted for cost
                              └── NO  → Cloud API with prompting (default)
```

## The Sovereignty Test Checklist

Rate each item 1-5 (1 = fully dependent, 5 = fully sovereign):

- Could you switch AI providers within one week?
- Do you know which data flows through which AI interactions?
- Do you have a tested fallback for your primary model?
- Are your specifications precise enough to work with any capable model?
- Do you control your evaluation criteria independently of any vendor?

Score 20+ = sovereign. Score 10-19 = partially dependent. Score below 10 = vendor-locked.
