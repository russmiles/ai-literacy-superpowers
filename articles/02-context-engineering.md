# Context Engineering

## Teaching your AI what your team already knows

*The Environment Hypothesis -- Article 2 of 6*

---

Imagine you've just hired the best developer you've ever interviewed. Perfect scores on the system design round. Encyclopaedic knowledge of your entire tech stack. Writes code that compiles on the first try.

On their first day, you hand them a laptop and say: "The repo's on GitHub. Good luck."

No onboarding. No architecture overview. No "here's why we do it this way." No pairing with someone who knows the codebase.

You know what happens next. They write beautiful code that is completely wrong for your project. They use the patterns they learned at their last job. They name things differently from everyone else. They handle errors in a way that makes your on-call engineer twitch.

They are brilliant. And they are useless. Not because they lack skill, but because they lack *context*.

**This is what you are doing to your AI. Every single session.**

---

## The brilliant new joiner who never gets onboarded

In the [previous article](https://open.substack.com/pub/youraisuperpower/p/the-environment-hypothesis), we established the core thesis: every AI coding failure is an environment problem. The quality of AI output is determined by the environment you create, not the model you choose.

But that raises the obvious question: what actually goes *into* that environment?

The answer is context. And you have far less of it than you think.

Here's the thing about your team's senior developers. They carry an enormous amount of knowledge that exists nowhere in writing. They know that the payments service uses a particular error-handling pattern because of an incident two years ago. They know that function names follow a specific convention because the Python and Go codebases share types across a boundary. They know which abstractions are load-bearing and which are accidental.

When a new human joins, they absorb this through osmosis. Code reviews. Pairing sessions. Overheard arguments in standups. It takes months, and it is deeply inefficient -- but it works.

Your AI gets none of it.

Every session starts from absolute zero. No memory of yesterday's review comments. No awareness of the architectural decision records. It's not a new joiner who's slowly getting up to speed. It's a new joiner whose memory gets wiped every morning.

> **Brain Power:** Before you read any further, try this. Pick one convention from your current project -- something "everyone knows" but that isn't written down anywhere. Now try to write it down in a single sentence, precisely enough that someone who has never seen your codebase could follow it. Harder than you expected, isn't it?

**Context engineering** is the discipline of taking the tacit knowledge trapped in your team's heads and making it explicit, precise, and machine-readable. It's the difference between an AI that generates plausible code and an AI that generates *your team's* code.

---

## What context actually means

When people hear "context," they think "give the AI more information." That's too vague to be useful. Context has specific layers, and they are not equally important.

**Stack declaration** is the foundation. Languages, frameworks, build system, test runner. Pure facts, no judgement -- and yet most teams never make it explicit. They assume the AI will figure it out from the code. Sometimes it does. Sometimes it generates Jest tests for a project that uses Vitest, and you spend fifteen minutes wondering why the test suite exploded.

**Conventions** are where things get interesting. Naming patterns, file structure, error handling, import ordering. These are the things that make your codebase feel like *yours*. Richard Gabriel called this quality "habitability" -- the property that makes a codebase feel like a place you can live and work in, rather than a museum you're afraid to touch.

**Architectural decisions** are the load-bearing layer -- and the one most teams skip. Not just "we use event sourcing" but "we use event sourcing because we need a complete audit trail for regulatory compliance and we tried CRUD with audit tables first and it didn't scale past 10,000 events per second." The *why* matters because it tells the AI what it cannot change, even if it sees a "better" pattern. Skip this layer and the AI will cheerfully refactor away your most important constraints.

**Rationale** is what turns arbitrary-looking rules into defensible ones. Not just "use snake_case" but "we use snake_case because our Python and Go codebases share type definitions across a code generation boundary, and snake_case is the only casing that round-trips cleanly through our protobuf pipeline." Without rationale, the AI treats conventions as suggestions. With rationale, it treats them as constraints.

**Threat model** shapes everything else. What data is sensitive? Where are the trust boundaries? Your senior developers instinctively validate user input at the API boundary and never log authentication tokens -- not because someone told them to last week, but because they remember the incident that taught the team. Your AI doesn't remember that incident. You need to encode the lesson.

Of these five layers, most teams start with stack declaration because it's easy. That's fine as a starting point. But the leverage is in conventions and architectural decisions. Stack declarations prevent trivial mistakes. Conventions and decisions prevent the expensive ones -- the kind where the code compiles, the tests pass, and the production incident happens three weeks later.

> **There are no dumb questions:**
>
> *"Isn't this just documentation?"*
>
> No. Documentation is written for humans who will read it once and mostly remember it. Context documents are written for a reader that starts fresh every session, has no background knowledge, and will interpret ambiguity however it pleases. That changes what you write and how you write it.
>
> *"Can't the AI just read our code and figure out the conventions?"*
>
> It can infer some patterns. But it can't distinguish between a deliberate convention and an accident that nobody has gotten around to fixing. It can't tell whether a pattern appears everywhere because the team chose it or because it was copy-pasted from a Stack Overflow answer three years ago. Explicit context removes the guessing.

---

## The precision problem

Here's where most teams fail, and it's subtle enough that your brain is going to want to skip past it.

Vague conventions produce vague output. This is not a minor annoyance. It is the single biggest reason AI-generated code requires extensive rework.

Look at these two convention statements:

| Vague convention | Precise convention |
| --- | --- |
| "Write clean code" | Not enforceable -- decompose further |
| "Keep functions short" | "Functions must not exceed 40 lines excluding blank lines and comments" |
| "Use meaningful names" | "Variable names must be at least 3 characters except for loop indices (`i`, `j`, `k`) and error values (`err`)" |
| "Handle errors properly" | "Every returned error must be wrapped with `fmt.Errorf` adding context. Bare `return err` is not permitted" |
| "Use dependency injection" | "No function constructs its own dependencies. All external dependencies are received as parameters or struct fields" |

Your brain just read that table and filed it under "obvious." It is not obvious. Go back and read the left column again. Those are the conventions most teams actually have.

**The test for any convention: could two independent reviewers, looking at the same code, agree on whether it follows the convention -- without discussing it?**

"Write clean code" fails this test catastrophically. "Functions must not exceed 40 lines" passes it trivially. The distance between those two statements is the distance between useful context and noise.

> **The Sceptic:** "This feels like a lot of overhead. Can't we just tell the AI to follow best practices?"
>
> **The Veteran:** "We tried that. The AI's 'best practices' included patterns we explicitly abandoned two years ago after they caused a production outage. Best practices are not your practices."
>
> **The Pragmatist:** "OK, but I'm not writing a hundred rules on day one. Where do I start?"
>
> **The Veteran:** "Start with the things you correct most often. Every time you change something the AI generated, ask yourself: could I have prevented this with a one-sentence rule? Write that sentence down. You'll have ten conventions within a week without any special effort."

---

## The extraction problem (or: you don't know what you know)

Walk up to a senior developer on your team and ask: "What are our coding conventions?"

They'll give you five or six things off the top of their head. Naming. Test structure. Maybe error handling.

Now watch them do a code review. They'll flag twenty things that violate conventions they didn't mention -- because they didn't know they knew them. This is **tacit knowledge**: expertise so deeply absorbed that it feels like instinct rather than a rule.

You can't extract tacit knowledge by asking "what are the rules?" You extract it by triggering the knowledge indirectly:

- "What would you correct in a new teammate's first PR?"
- "What triggers an immediate rejection in code review?"
- "What's the thing that's obvious to everyone but nowhere in writing?"
- "Which conventions does the AI violate most often?"

That last question is particularly revealing. It turns every AI interaction into a convention-discovery tool. Every correction you make is a convention you haven't encoded yet.

Ask three senior developers "what separates a clean refactoring from an over-engineered one?" and you'll get three different answers. Those disagreements are conventions that haven't been resolved yet. Surfacing them is one of the most valuable side effects of context engineering: it forces your team to confront things they assumed they already agreed about.

> **Exercise:** Think of a project you work on. What triggers an immediate rejection in review? Write down your answer. Now imagine asking two other people on your team the same question. Would they give the same answer? If you're not sure, that's a convention that needs extracting and encoding.

---

## Living documents, not dead wikis

You might be thinking: "Great, I'll spend a day writing all this down and we're done."

No. Context rots.

Your conventions reference functions that get renamed. Your stack declaration lists framework versions that get upgraded. Your architectural decisions describe constraints that get relaxed. If your context documents don't evolve with the code, they become actively harmful -- the AI follows outdated rules that produce code that *used to be* correct.

**Context documents must be versioned alongside the code they describe.** They live in the repository, not in a wiki. They get reviewed in pull requests. When someone changes a convention, the context document changes in the same commit.

This is what separates context engineering from documentation. Documentation lives adjacent to the workflow. Context lives *inside* the workflow. It's checked in, reviewed, and maintained with the same rigour as the code itself.

The moment your context files live in a wiki, they're dead. They'll be accurate for about two sprints. After that, they'll be worse than having no context at all, because the AI will follow them confidently in the wrong direction.

> **The Pragmatist:** "What do I actually do on Monday?"
>
> Create a single file in the root of your repository. Give it three sections: stack (what you use), conventions (how you use it), and decisions (why you use it that way). Start with five conventions -- the five things you correct most often. Commit it. Review it as a team.
>
> That's it. That's the whole first step.

---

## The compound effect

A single well-written convention saves you maybe two minutes per AI session. You correct the output, sigh, and move on.

But you're running ten AI sessions a day. That's twenty minutes. Across a five-person team, that's over an hour and a half of daily rework -- and that's just one missing convention. Most teams have dozens.

The maths matters less than the dynamic it creates. Each convention you encode is a correction you never make again. Each architectural decision you document is a structural mistake the AI never attempts. That part is straightforward.

Here's what people miss: as the AI produces code that increasingly matches your team's style, *trust increases*. And trust changes behaviour. A developer who trusts the AI's output stops re-reading every generated function line by line. They delegate larger tasks. They use AI for work they previously wouldn't have attempted -- the boring migration, the tedious test scaffolding, the refactoring they never had time for. The team's capacity expands not because the AI got smarter, but because the environment got richer.

Bad context is a tax you pay forever. Same corrections, every session, no compounding.

---

## What you now know

- **Context is layered:** stack, conventions, architectural decisions, rationale, and threat model. The leverage is in the middle layers, not the easy ones.
- **Precision is everything:** A convention that two reviewers can't independently agree on is not a convention. It's a wish.
- **Tacit knowledge is the bottleneck:** Your team knows far more than they can articulate. Structured extraction questions surface what direct questions miss.
- **Context documents are living artefacts:** Versioned with the code, reviewed in PRs. The moment they live in a wiki, they start dying.
- **Compounding works in both directions:** Encoded conventions build trust that expands capability. Missing conventions create rework that erodes it.

The previous article told you that every AI coding failure is an environment problem. Now you know what the environment is made of. In the next article, we'll look at what makes conventions *enforceable* -- because writing them down is only half the battle.

---

*Next in the series: "Constraints That Bite" -- why conventions without enforcement are just suggestions, and how to build guardrails with teeth.*
