# Constraints That Bite

## From good intentions to automated enforcement

*This is Article 3 of "The Environment Hypothesis," a six-part series on building environments where AI actually produces great work. Article 1 established that AI output quality equals environment quality. Article 2 showed how to engineer context -- the knowledge layer. Now we add teeth.*

---

You've been in this meeting.

Someone says: "Going forward, all functions should have proper error handling." Everyone nods. Someone writes it in the team wiki. It gets a nice heading and maybe a bullet point. And then... nothing changes. Three weeks later, a production incident traces back to an unhandled exception in code that was written *after* the meeting.

What happened? The team had a **convention**. What they needed was a **constraint**.

A convention is something you *hope* people follow. A constraint *prevents them from not following it*. One lives in a document. The other lives in your workflow.

If you're working with AI coding assistants, this distinction is existential. Not important. Existential.

---

## The Enforcement Gap

Go look at your team's coding guidelines right now. I'll wait.

Got them? Now ask yourself: *how many of those rules are actually enforced by anything other than human memory and good intentions?*

If you're like most teams, the answer is: maybe a third. You've got a well-intentioned document full of statements like:

- "Use meaningful variable names"
- "All API endpoints must validate input"
- "Security-sensitive operations require logging"

These are **wishes**. Wishes don't ship.

> **The Sceptic:** "But our team is disciplined. We follow our guidelines."
>
> **The Veteran:** "Your team is disciplined *most of the time*. Then it's Friday at 4pm, the sprint ends Monday, and someone pushes a 200-line function with a comment that says 'TODO: refactor.' I've seen your git log."

The enforcement gap is the distance between what your team *says* should be true about your codebase and what *is* true. Every team has one. The question is whether you're managing it or pretending it doesn't exist.

Here's what makes this urgent: AI coding assistants are *prolific*. They generate more code in an hour than a human writes in a day. Your enforcement gap was a slow leak. Now it's a burst pipe. Prolific generation without enforcement doesn't give you prolific quality. It gives you **prolific mediocrity**.

---

## Three Levels of Constraint Maturity

You need constraints, not conventions. But most teams hear "enforcement" and immediately jump to the heaviest possible solution. Full CI pipelines. Strict linting rules. Mandatory type coverage. Day one.

That's like putting a toddler in a straitjacket because they might run into traffic. Technically effective. Wildly counterproductive.

**Level 1: Declared (Unverified)**

You write the rule down. No automation. No checking. Just a clear, specific statement:

*"All public API functions must return structured error types, not raw strings."*

This sounds weak. It isn't. Writing a rule precisely forces you to think about what you actually want. Most teams skip this and jump straight to tooling -- which is how you end up with linter rules that nobody understands the purpose of.

**Level 2: Agent-Backed (Verified by AI)**

You give the written rule to an AI reviewer. Every PR gets checked against it. The AI reads the rule, reads the code, flags violations.

Is this deterministic? No. Will it catch everything? No. But it catches *most* things *before they merge*. Think of it as a colleague who has actually read the style guide reviewing every single pull request.

The speed here matters. You go from "we decided this rule matters" to "something is checking for it" in minutes, not weeks. No custom linter rules. Just a clearly stated expectation and an AI that reads it.

**Level 3: Deterministic (Tool-Enforced)**

A linter. A type checker. A security scanner. Something that runs the same way every time, with no false negatives.

At this level, the constraint is a **law of physics** in your codebase. The CI pipeline won't let you violate it.

This is the strongest level. It's also the most expensive and the most dangerous. A bad deterministic rule doesn't just annoy people -- it blocks them. And a team that's been blocked by a bad rule stops trusting the constraint system entirely. You've seen this happen: one too-strict lint rule and suddenly everyone's adding `// nolint` comments without reading what they're suppressing.

---

## Progressive Hardening: The Promotion Ladder

Every constraint should start soft and earn its way up. This is **progressive hardening**: start flexible, observe what works, increase enforcement as confidence grows.

```
    +---------------------------+
    |  DETERMINISTIC            |  <-- Tool enforces it. No exceptions.
    |  (Linter / type checker)  |
    +---------------------------+
    |  AGENT-BACKED             |  <-- AI reviewer checks for it.
    |  (AI review on every PR)  |
    +---------------------------+
    |  DECLARED                 |  <-- Written down. Humans follow it (maybe).
    |  (Documented intention)   |
    +---------------------------+
```

A new rule starts at "Declared." You write it clearly. You notice where it's ambiguous, where the edge cases are, where people reasonably disagree.

Once you trust the wording, promote it to "Agent-Backed." Watch the results. Does it flag the right things? Does it miss obvious violations? Does it flag things that are fine?

Once the false positives and false negatives are resolved -- once the edge cases are *truly* handled -- promote it to "Deterministic." Write the linter rule, the type constraint, the automated check.

Here's what most articles about constraints won't tell you: **some rules should never be promoted.** "Functions should be small enough to understand in one pass" is a judgment call. It belongs at Level 2 permanently. Trying to make it deterministic (50-line hard limit) produces a worse codebase, not a better one. Not every constraint wants to grow up.

> **The Pragmatist:** "OK but what do I actually do on Monday?"
>
> **Start with three rules.** Just three. Write them precisely. Make them specific enough to be checkable. Run them past your team. That's your declared layer. Next week, pick the one you're most confident about and add it to your AI review step. That's your first promotion. The deterministic layer can wait.

---

> ### Watch it
>
> **The over-constraining trap.** It is very tempting to look at the promotion ladder and think "let's just make everything deterministic from day one." Do not do this. Rules you haven't battle-tested will have edge cases you haven't imagined. A deterministic rule with bad edge cases blocks your team, generates workarounds, and erodes trust in the entire constraint system. Start soft. Harden with evidence.

---

## Three Enforcement Loops

When a constraint fires matters as much as how strict it is.

**Edit time (advisory).** The constraint nudges you while you're working. Red squiggles under a function that's getting too long. It doesn't block you. It makes sure you *know*. Most constraints should start here.

**Merge time (strict).** The constraint blocks the pull request until satisfied. CI gates. Required reviews. Automated checks. This is where battle-tested constraints live. If something is important enough to block a merge, you'd better be sure about it.

**Scheduled (investigative).** Some constraints aren't about individual changes -- they're about drift. "Test coverage should not drop below 80%." "No file should go unmodified for more than six months without a staleness review." These run nightly or weekly and flag trends before they become crises.

A common mistake: putting a new, untested constraint directly into the merge loop. Your team hits it on a Friday afternoon deploy, can't figure out why it's failing, and overrides it. Now the override is the convention. You've made enforcement *weaker* by making it too strict too soon.

*Pause. Think about one rule your team has right now. What level is it? What loop is it in? Could it be in a different one?*

---

## Sharpen Your Pencil

Classify each of these rules by maturity level (Declared, Agent-Backed, or Deterministic) and enforcement loop (Edit, Merge, or Scheduled):

1. "The TypeScript compiler rejects any code with type errors."
2. "We wrote in our wiki that all React components should have PropTypes."
3. "An AI reviewer checks each PR for functions longer than 50 lines and leaves a comment."
4. "A weekly script scans for dependencies with known CVEs."
5. "Our ESLint config forbids `console.log` in production code."

*(Answers: 1 -- Deterministic/Merge. 2 -- Declared/None (no loop -- it's unenforced). 3 -- Agent-Backed/Merge. 4 -- Deterministic/Scheduled. 5 -- Deterministic/Edit and Merge.)*

---

## The Constraint Design Problem

A good constraint has two properties in tension: it must be **specific enough to enforce** and **general enough to be useful**.

"Code must be clean" is unenforceable. You can't write a linter rule for vibes.

"No function exceeds 50 lines of executable code" is perfectly enforceable. A script can count lines. But is it *right*? What about the function that legitimately needs 60 lines because splitting it would make it *less* readable?

The 50-line rule isn't about line count. It's about *"functions should be small enough to understand in one pass."* Can you enforce that deeper intent deterministically? No. But an AI reviewer can get surprisingly close -- and it won't get tired at 4pm on a Friday.

This is the real argument for Agent-Backed constraints: they can enforce *intent*, not just *metrics*. A linter counts lines. An AI reviewer can read a 60-line function and say "this is actually fine -- it's a single clear sequence" or "this 30-line function is doing four unrelated things." That's a category of enforcement that didn't exist two years ago.

> **There Are No Dumb Questions**
>
> **Q: If AI reviewers aren't deterministic, why use them at all?**
>
> A: Because "catches 90% of violations immediately" beats "catches 0% until a human notices during review." Perfect is the enemy of good, and good is the enemy of *nothing at all*.
>
> **Q: What if my team disagrees about a constraint?**
>
> A: Good. That's the conversation you should be having *before* you automate it. This is why the "Declared" level exists -- it's a space to argue about intent before anyone writes a linter rule.
>
> **Q: Can I have too many constraints?**
>
> A: Every constraint has a cost: cognitive load, CI time, false positive fatigue. If your developers spend more time satisfying constraints than writing features, you've over-constrained. Start with the constraints that encode your most important architectural decisions. Add more only when you feel the pain of not having them.

---

## A Fireside Chat

> **Convention:** I don't understand why everyone's so down on me. I was here first. I'm the reason the team has *any* standards at all.
>
> **Constraint:** Nobody's down on you. You're just... aspirational.
>
> **Convention:** Aspirational! I'm a *commitment*. The team *agreed* to follow me.
>
> **Constraint:** The team agreed to follow you on a Tuesday. By Thursday, someone was in a rush and I wasn't there to stop them. You were in the wiki. I was in the pipeline.
>
> **Convention:** But you're so *rigid*. You can't handle nuance. You can't understand *context*.
>
> **Constraint:** That's fair. That's why the smart teams use both of us. You articulate the intent. I enforce the boundary. You're the soul. I'm the skeleton.
>
> **Convention:** ...that's actually kind of nice.
>
> **Constraint:** Don't get sentimental. We have a codebase to protect.

---

## Why This Matters Now

A human developer writes maybe 50-100 lines of production code on a productive day. The enforcement gap grows slowly. You can almost keep up with manual review.

An AI assistant generates that much in *minutes*. The enforcement gap doesn't creep anymore. It sprints.

**Constraints are what turn AI speed into AI value.** Without them, you're generating technical debt faster. With them, you're generating quality code at a pace that was previously impossible.

But only if the constraints actually bite.

---

## What You've Learned

- **Conventions without enforcement are wishes.** AI makes the enforcement gap wider, faster.
- **Three levels of maturity:** Declared, Agent-Backed, Deterministic. Every constraint starts at the bottom and earns its way up. Some should never reach the top.
- **Progressive hardening** means starting flexible and increasing enforcement with evidence. Skipping steps breaks trust.
- **Three enforcement loops:** Edit (advisory), Merge (strict), Scheduled (investigative). A constraint in the wrong loop does more damage than no constraint at all.
- **Good constraints encode architectural intent**, not arbitrary metrics. AI reviewers can enforce intent in ways linters cannot.

---

*Next in the series: we move from individual constraints to the system that holds them together -- the feedback loops that keep your environment alive and adapting.*
