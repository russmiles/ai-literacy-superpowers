# The Assessment Practice

## Why knowing where you are beats knowing where you want to be

*The Assessment Practice -- Companion to The Environment Hypothesis series*

---

It's been six months. Your team adopted AI coding tools back in
October. You wrote a `CLAUDE.md`. You set up some constraints. You
even have a `REFLECTION_LOG.md` with a few entries in it. Things feel
good. The AI is producing better code than it was at the start. PRs
are moving faster. Everyone agrees: you're getting good at this.

Then someone -- maybe a new tech lead, maybe a curious VP, maybe that
one developer who asks uncomfortable questions -- says:

"Are we actually good at this, or are we just busy?"

Silence.

Not the comfortable kind. The kind where everyone looks at each other
and realises they have no idea. You *feel* like you've improved. But
feelings are not evidence. You couldn't point to a metric, a level, a
concrete description of where you are versus where you were three
months ago.

This is the **Dunning-Kruger problem of AI literacy**. Teams at Level
1 think they're at Level 3. They're using the tools daily -- surely
that counts for something? It does count. It counts for Level 1. Daily
use without systematic verification, without environment engineering,
without feedback loops is just... daily use.

Here it is, the claim this article is built on:

**Assessment is not an audit. It is a practice.** A recurring
discipline -- quarterly, deliberate, evidence-based -- that tells you
where you are, what's working, and what to do next. Where you
*actually* are, not where your conference talk claims you are.

Roadmaps tell you where to go. Assessment tells you where to go
*from*. Without that, every plan is fiction.

---

## Which of These Sounds Like You?

There are six levels of AI literacy. Not six levels you
climb like a career ladder -- six diagnostic positions that describe
how your team currently operates.

Read these. Not as a checklist of things to aspire to. As a mirror.
Be honest with yourself about which one you recognise.

**Level 0 -- Awareness.** You know AI coding tools exist. You haven't
used one on real work with real stakes.

**Level 1 -- Prompting.** You use AI tools daily. You've got your
favourite model. You copy-paste output into your codebase and fix it up
manually. Sometimes it's great. Sometimes you spend an hour debugging
code that looked right. You don't have a systematic way of telling
which is which -- the feedback loop is "find the bug in production."
Most teams who think they're past this stage are still here.

**Level 2 -- Verification.** You've been burned enough to stop trusting.
You have CI workflows that run tests. Linters. Maybe vulnerability
scanning. When the AI produces code, it goes through the same gauntlet
as human code. But the AI still doesn't know your conventions, your
architecture, your hard-won decisions. You verify systematically, and
the code works -- it just doesn't feel like *your* code. You correct
the same things every session. The AI never learns from yesterday.

**Level 3 -- Habitat Engineering.** You have a `CLAUDE.md` or equivalent
that gives the AI your conventions at session start. A `HARNESS.md`
declaring your constraints -- and at least some of them are actually
enforced in CI, not just written down. Reflections are captured.
Sessions improve over time because the *environment* accumulates
knowledge, not just the people. This is where the flywheel starts
turning. Most teams that reach Level 3 can feel the difference but
struggle to articulate it.

**Level 4 -- Specification Architecture.** Specs before code, agent
pipelines with safety gates, the AI as a colleague with defined
responsibilities -- not a typewriter you occasionally shout at.

**Level 5 -- Sovereign Engineering.** Reusable plugins, cross-team
templates, cost tracking, model routing, organisational governance.

---

These are *diagnostic* positions, not aspirational destinations. You're already at one of
them. Right now. The question isn't "which one do I want to be?" It's
"which one am I?"

> **Brain check:** Which level did you recognise yourself in? Did you
> hesitate between two? That hesitation is the whole point. Assessment
> exists to resolve it.

---

## Files, Not Feelings

You probably think you know your level. Let's test that.

> **The Sceptic:** "We're Level 3. We've got a CLAUDE.md, we've got
> constraints, we've got the whole setup."
>
> **The Pragmatist:** "When did you last update the CLAUDE.md?"
>
> **The Sceptic:** "I mean... it's there."
>
> **The Pragmatist:** "How many of your constraints are enforced in
> CI versus just written down?"
>
> **The Sceptic:** "..."
>
> **The Pragmatist:** "And your REFLECTION_LOG.md -- when's the last
> entry?"
>
> **The Sceptic:** "February, probably."
>
> **The Pragmatist:** "It's April. That's not Level 3. That's Level 1
> wearing a Level 3 costume."

This is why assessment uses **observable evidence**, not self-report.
An assessment scans your repository for concrete signals -- files that
exist or don't, configurations that are active or stale, workflows that
run or sit disabled.

At Level 2, it looks for CI workflows, test coverage thresholds,
vulnerability scanning. At Level 3, it checks whether your `CLAUDE.md`
is current, whether `HARNESS.md` constraints are actually enforced,
whether `AGENTS.md` has entries, whether `REFLECTION_LOG.md` has
recent dates. At Level 4, it looks for specification files, plans,
orchestrators with safety gates. At Level 5, plugin structures,
cross-team templates, observability configuration.

The uncomfortable truth -- and you're going to feel this one -- is that
most teams are one level lower than they think. A `CLAUDE.md` that
hasn't been updated in two months isn't evidence of habitat
engineering. It's evidence that you *tried* habitat engineering and
then stopped.

The scoring heuristic makes this explicit: **your weakest discipline
is your ceiling.** You might have brilliant context engineering at
Level 3 but verification stuck at Level 1. Your assessed level?
Level 1. The chain breaks at the weakest link, because that weakest link is
where the AI will hurt you.

> **Brain check:** Open your repo right now. Is there a file in there
> that declares a practice you've stopped doing? A reflection log with
> no recent entries? A constraints file that hasn't been touched since
> you created it? That gap between declaration and practice -- that's
> exactly what assessment measures.

---

## The Practice: Assessment as Quarterly Discipline

You wouldn't step on the scales in January and assume the number holds
through December. So why would you assess your AI literacy once and
call it done?

Assessment is a **recurring practice**. Quarterly. Here's the rhythm:

**1. Scan.** Read the repository for evidence. Every signal found, every
signal absent. Not opinions -- files, configurations, dates, commit
history.

**2. Question.** Three to five clarifying questions that fill the gaps
observable evidence can't answer. "Do you write specs before code, or
after?" "Do you verify AI output systematically, or trust it if it
looks right?" "Does your team share AI conventions, or does each
developer work differently?"

**3. Assess.** Evidence maps to levels. The weakest discipline sets
the ceiling. No negotiation, no grading on a curve.

Then the assessment acts on what it found. A timestamped document lands
in your repo -- evidence, rationale, strengths, gaps, recommendations.
Habitat hygiene gets fixed on the spot: stale counts, missing entries,
drift between declared and actual state. Workflow changes get proposed
one at a time, accepted or rejected, applied immediately.

Then the bridge: the assessment asks how far you want to improve --
next level, or higher? It maps each gap to the specific command or
skill that closes it, ordered by priority. You walk through them one
at a time: accept, skip, or defer. The ones you accept execute
immediately. The ones you defer show up in the next assessment as
unfinished business. No prose recommendations that rot in a markdown
file. Executable actions, connected to the tools that do the work.

And the assessment captures a reflection on itself, feeding the
learning loop.

> **The Veteran:** "First assessment, we thought we were Level 3. We
> were Level 2 -- verification was solid but our habitat was stale.
> Second assessment, three months later: Level 3. Not because we built
> anything new. Because we started *operating* what we already had. The
> CLAUDE.md got updated fortnightly. The constraints got enforced. The
> reflections got curated. Same infrastructure, different discipline."

**Each assessment raises
the floor for the next one.** Recommendations from Q1 become evidence
in Q2. The adjustments you make in April are the signals the scan
finds in July. It compounds. Not dramatically -- incrementally, the
way everything valuable compounds.

Let me say it differently: the team that runs four assessments a year doesn't
improve four times. They improve *continuously*, because each
assessment changes the daily operating habits that produce the
evidence the next assessment measures. The assessment isn't the
improvement. It's the thing that *triggers* improvement.

If you've read the earlier series on the Environment Hypothesis, you'll
recognise something: the three feedback loops -- edit time, merge time,
periodic. Assessment is the deepest cycle of that periodic loop. It's
the moment you step back and ask not "is this session going well?" but
"is our *practice* going well?"

> **Exercise:** Before you read the next section, write down -- on
> paper, in a note, wherever -- what level you think your team is at.
> Be specific. Then write down the last time you updated your AI
> environment files. If there's a gap between the level you claimed
> and the freshness of your evidence, you've just done a mini
> assessment. That discomfort? That's the useful part.

---

## Why This Isn't a Retrospective

You've done retrospectives. You've written action items on sticky notes
and then not done them. Assessment is different in one critical way:
**it applies changes in the same session.**

A constraint sitting at "unverified" for two months gets promoted to
agent-backed enforcement before the session ends. An `AGENTS.md` that
exists but nobody reads gets wired into the workflow before the session
ends. A `HARNESS.md` status section showing twelve constraints when
there are actually fifteen gets corrected before the session ends.

The gap between "we should" and "we did" collapses to zero. That's not
a minor detail. That's the entire reason it works.

After the fixes, a badge lands in your README -- your assessed level,
linking to the full assessment document with every piece of evidence
and every recommendation.

> **The Sceptic:** "So the badge is just for show?"
>
> **The Pragmatist:** "Click it. Every piece of evidence, every gap,
> every recommendation. It's a claim with receipts."

---

The first series in this collection argued that **the environment is
the product.** This article adds one thing: you have to know the state
of the product.

Assessment is how you know. Not once. Quarterly. As a discipline, not
a chore.

Run `/assess`. Fifteen minutes. That's enough to start.

---

## The Bullet Points

- **The Dunning-Kruger of AI literacy** -- teams at Level 1 think
  they're at Level 3 because daily use feels like mastery
- **Files, not feelings** -- assessment uses observable evidence from
  the repository, not self-reported confidence
- **Six levels (L0-L5)** -- diagnostic positions from awareness through
  sovereign engineering, each with concrete indicators
- **Assessment is a practice, not an audit** -- quarterly, deliberate,
  evidence-based, recurring
- **Weakest discipline is the ceiling** -- brilliant context
  engineering means nothing if verification is absent
- **Immediate adjustments in the same session** -- no action items for
  next sprint; fixes happen now
- **Assessment feeds the learning loop** -- each assessment's
  reflection becomes raw material for the next cycle of improvement
