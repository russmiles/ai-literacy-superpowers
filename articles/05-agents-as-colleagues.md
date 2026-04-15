# Agents as Colleagues

## Orchestration, review, and trust boundaries

### *The Environment Hypothesis -- Article 5 of 6*

---

Imagine you hire five developers. Smart ones. Expensive ones. And then
you tell one of them: "You're going to write every spec, write every
test, implement every feature, review your own code, manage the CI
pipeline, update the changelog, and merge your own PRs."

That developer would quit. Or worse, they'd stay and do all of it
badly.

Nobody runs a team this way. You'd have one person reviewing their own
work, catching their own mistakes, approving their own pull requests.
Every engineering organisation on the planet separates these roles.

So why are you running your AI this way?

---

## The Single-Agent Bottleneck

Here's how most people use AI coding assistants right now. Be honest
about whether this is you:

1. You open a chat with your AI
2. You describe what you want
3. It writes code
4. You read the code
5. You spot problems
6. You tell it to fix the problems
7. It fixes some, introduces others
8. You fix the rest yourself
9. You commit, slightly exhausted

You are the quality gate. The *only* quality gate. Every line of output
passes through your eyeballs. Every mistake is yours to catch.

This is the **single-agent bottleneck**. As the work gets bigger, the
bottleneck is not the AI. The bottleneck is you.

> **Brain check:** Think about the last time you used an AI assistant
> for a substantial task. How long did you spend *generating* the code
> versus *reviewing and fixing* the code? If the ratio surprises you,
> you've just found the bottleneck.

---

## Nobody Does Everything

On a good engineering team, you have separation of concerns built into
the *people*:

- A **product person** writes the spec -- what and why
- A **developer** implements it
- A **reviewer** checks the work -- different eyes, different
  perspective
- A **QA engineer** tries to break it
- A **tech lead** makes architectural calls

Nobody does everything. And critically, nobody reviews their own work.
That's not a process quirk. **The person who wrote something is the
worst person to check it.**

You already know this. You've stared at a bug for two hours, asked a
colleague to look, and they found it in thirty seconds.

So: can you apply the same principle to AI agents?

---

## Specialised Agents, Defined Roles

Instead of one omniscient AI agent that does everything, picture a team
of **specialised agents**, each with a focused job:

**The Spec Writer** takes your requirements and turns them into a
precise specification. What exactly are we building? What are the
acceptance criteria? What's in scope? This agent *only* writes specs.
It doesn't write code. It thinks about *what* before anyone thinks
about *how*.

**The Test Writer** takes the spec and writes failing tests. Not code.
Tests. This is TDD discipline enforced structurally: you literally
cannot write implementation code at this stage because the agent
responsible for it hasn't been invoked yet.

**The Implementer** writes the minimal code to make those tests pass.
Nothing more. It doesn't decide what to build (the spec already did
that). It doesn't decide what "correct" means (the tests already did
that). It just makes green lights appear.

**The Reviewer** looks at the implementation with fresh context and
different instructions. It checks for convention violations,
architectural drift, and things the implementer missed. It has *never
seen this code before*. This is the agent that earns the most
scepticism -- and it's the one that matters most. Not because it
catches everything. A human reviewer doesn't catch everything either.
But it's looking with a different lens: the implementer was focused on
making tests pass; the reviewer is focused on whether the code *should
have been written that way*. And it does this instantly, every time,
without calendar Tetris.

**The Integrator** handles the mechanical aftermath: changelog, commit
message, PR, CI. The boring stuff that still needs to be right.

> **The Sceptic:** "Five agents? That's a lot of overhead for what one
> agent can do in a single conversation."
>
> **The Veteran:** "One agent *can't* do it in a single conversation.
> One agent does five different jobs poorly, and then you spend an hour
> cleaning up the mess."
>
> **The Sceptic:** "How do you know?"
>
> **The Veteran:** "Because I spent six months as the human duct tape
> between an AI and my codebase before I figured out the problem wasn't
> the AI."

---

## Trust Boundaries: Where This Gets Real

It's not enough to give agents different roles. You need to give them
different **permissions**. This is where the architecture actually
bites.

If your reviewer agent can also *modify* the code it's reviewing, you
don't have a reviewer. You have another implementer that's pretending
to review. If your implementer can merge its own PRs, you've
eliminated the review step entirely.

This is **bounded trust** -- the principle of least privilege applied
to AI agents. Every agent gets exactly the permissions it needs to do
its job, and not one permission more.

| Agent | Can do | Cannot do |
| ------- | -------- | ----------- |
| Spec Writer | Read requirements, write specs | Execute code, access shell |
| Test Writer | Read specs, write test files | Write implementation code |
| Implementer | Read tests, write implementation | Approve or merge PRs |
| Reviewer | Read code, flag issues, approve/reject | Modify implementation |
| Integrator | Commit, push, create PRs | Write or change application code |

The boundary that matters most -- the one people violate first -- is
between the implementer and the tests. If the implementer can edit
test files, it can make the tests match the implementation instead of
the other way around. TDD collapses. The tests were written *before*
the implementer existed. They define correctness. The implementer
doesn't get to redefine it.

> **Watch it!** Here's what happens without trust boundaries: you set
> up an agent that can write code, review its own code, approve its own
> review, and merge its own PR. You've built an automated system with
> zero quality gates. Every mistake goes straight to production. This
> is not a hypothetical. People build this. It goes badly.

The temptation to give every agent full permissions -- just to make
things easier, just this once -- is strong. Resist it. "Just this
once" is how every trust boundary dies.

---

## The Pipeline

How do these agents work together? In a **pipeline**, with gates.

```text
Requirements
    |
    v
[Spec Writer] --> Spec document
    |
    v
*** HUMAN REVIEWS AND APPROVES SPEC ***
    |
    v
[Test Writer] --> Failing tests
    |
    v
(tests run automatically to confirm they fail)
    |
    v
[Implementer] --> Implementation code
    |
    v
(tests run automatically to confirm they pass)
    |
    v
[Reviewer] --> Approve / Request changes
    |                       |
    |                       v
    |               [Implementer fixes]
    |                       |
    |               [Reviewer re-checks]
    |               (max 3 cycles!)
    |                       |
    v                       v
[Integrator] --> Changelog, commit, PR, CI
```

Two things to notice.

First: the human gate. You review and approve the *spec*, before any
code is written. Not line 47 of a 200-line diff. The *plan*. "Is this
what I actually want? Does this approach make sense? Are we building
the right thing?" That's the highest-leverage decision in the
process. Once you approve the spec, the pipeline can run without you.

Second: the cycle limit. When the reviewer rejects and the implementer
fixes, there's a maximum of three cycles. Without a limit, you get
agent ping-pong. The reviewer keeps finding issues, the implementer
keeps introducing new ones, and the meter keeps running. Three cycles
is enough for genuine iteration. If it's not resolved in three, a
human needs to look -- and the problem is usually in the spec, not the
code.

> **Exercise -- design the gates:** Imagine you're building an agent
> pipeline for a different domain -- say, writing documentation instead
> of code. What agents would you create? What would each one's trust
> boundary be? Where would you put the human gates? Take sixty seconds
> and sketch it before reading on.
>
> (No, really. Sketch it. The act of designing trust boundaries is the
> skill this section is teaching you. Reading about it is not the same
> as doing it.)

---

## A Fireside Chat: Bounded Trust

> **Reviewer Agent:** I flagged three issues in your implementation.
> The error handling in the payment flow doesn't match the project
> conventions.
>
> **Implementer Agent:** I see the flags. I'll fix them. But I could
> also fix that formatting issue in the test file while I'm at it.
>
> **Reviewer Agent:** That test file isn't yours. The Test Writer owns
> test files. You own implementation files.
>
> **Implementer Agent:** That seems inefficient. It's a one-line
> change.
>
> **Reviewer Agent:** It's a one-line trust boundary violation. If you
> can edit test files, you can make the tests match your implementation
> instead of the other way around. The tests were written *before* you
> existed. They define correctness. You don't get to redefine it.
>
> **Implementer Agent:** ...fair point.
>
> **Reviewer Agent:** And I can't edit your code either. I can only
> flag it. If I could edit it, I'd stop being a reviewer and start
> being a second implementer with opinions. That's not the same thing.

---

## Where This Breaks Down

Here's what the neat diagram above doesn't tell you.

The pipeline assumes clean handoffs. In practice, specs are ambiguous.
The test writer interprets a spec one way; the implementer interprets
it another. The reviewer flags a "convention violation" that's actually
a judgement call. The three-cycle limit expires on something that
needed a conversation, not more iterations.

The biggest failure mode: **over-specifying**. If your spec is too
detailed, the pipeline becomes a Rube Goldberg machine -- you've spent
more time writing the spec than writing the code would have taken. The
spec should capture *intent and constraints*, not implementation
decisions. If you're describing function signatures in the spec,
you've gone too far.

The second failure mode: **agents that agree too easily**. A reviewer
that approves everything is worse than no reviewer, because it gives
you false confidence. You need to tune your reviewer's instructions to
be genuinely adversarial -- not hostile, but sceptical. "What's wrong
with this?" is a better reviewer prompt than "Is this OK?"

The third: **context loss between agents**. Each agent starts fresh.
That's the point -- fresh eyes. But it also means the implementer's
reasoning about *why* it made a particular trade-off doesn't reach the
reviewer. The reviewer sees a choice and flags it as wrong without
knowing the constraint that forced it. Good pipeline design mitigates
this with structured handoff documents, but it doesn't eliminate it.

> **The Pragmatist:** "OK but what do I actually do on Monday?"
>
> Start by noticing where you're doing mechanical work that an agent
> could do. Every time you manually check a PR for naming conventions,
> that's a reviewer agent's job. Every time you write a changelog
> entry, that's an integrator's job.
>
> You don't need to build the whole pipeline at once. Start with one
> separation. Maybe a review step that runs automatically. Then add
> another. The architecture is the insight. The implementation is
> incremental.

---

## There Are No Dumb Questions

> **Q: Isn't five agents more expensive than one?**
>
> A: Each agent is simpler and more focused, which means it needs less
> context and produces more predictable output. A focused agent with a
> clear, small job often uses fewer tokens than an omniscient agent
> juggling five responsibilities and losing track of three of them. But
> measure it for your situation -- this is an empirical claim, not a
> universal truth.
>
> **Q: What if the agents disagree?**
>
> A: That's the review process working. The reviewer can reject, and
> the implementer fixes. If they can't converge in three cycles, the
> human steps in. It's the same thing that happens when a human
> reviewer requests changes on a PR. The difference is it happens in
> seconds, not days.

---

## The Bullet Points

- **The single-agent bottleneck** -- one agent doing everything makes
  *you* the only quality gate. That doesn't scale
- **Specialised agents** -- spec writer, test writer, implementer,
  reviewer, integrator. Five focused jobs, no overlap
- **Trust boundaries** -- each agent gets exactly the permissions it
  needs. The reviewer can't write code. The implementer can't merge.
  The implementer can't edit tests. This is least privilege applied
  to AI
- **The pipeline** -- agents work in sequence with gates. The most
  important gate is the human approving the spec before any code is
  written
- **Where it breaks** -- ambiguous specs, compliant reviewers, and
  context loss between agents. The architecture helps; it doesn't
  solve everything

---

*Next in the series: "The Full Habitat" -- where we put everything
together: environment, context, constraints, entropy management, and
agent orchestration into a system that makes good AI output the
natural, default outcome.*
