# The Assessment Practice

## Why knowing where you are matters more than knowing where you want to be

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

Here's the thesis of this article, and it's simpler than you expect:

**Assessment is not an audit. It is a practice.** A recurring
discipline -- quarterly, deliberate, evidence-based -- that tells you
where you are, what's working, and what to do next. Not where you wish
you were. Not where your conference talk claims you are. Where you
*actually* are.

And knowing where you actually are? That's worth more than any
aspirational roadmap you'll ever write. Because roadmaps tell you
where to go. Assessment tells you where to go *from*. Without that
starting point, every plan is fiction.

---

## Which of These Sounds Like You?

Before we talk about how assessment works, you need to know what it's
assessing. There are six levels of AI literacy. Not six levels you
climb like a career ladder -- six diagnostic positions that describe
how your team currently operates.

Read these. Not as a checklist of things to aspire to. As a mirror.
Be honest with yourself about which one you recognise.

**Level 0 -- Awareness.** You know AI coding tools exist. You've maybe
tried one in a side project. But you haven't used one on real work with
real stakes. You're curious, not practising.

**Level 1 -- Prompting.** You use AI tools daily. You've got your
favourite model. You copy-paste output into your codebase and fix it up
manually. Sometimes it's great. Sometimes it's terrible. You don't have
a systematic way of telling which is which until you find the bug in
production.

**Level 2 -- Verification.** You've learned not to trust. You have CI
workflows that run tests. You've got linters. Maybe vulnerability
scanning. When the AI produces code, it goes through the same gauntlet
as human code. You verify systematically -- but the AI still doesn't
know your conventions, your architecture, your hard-won decisions. It
produces *correct* code that doesn't feel like *your* code.

**Level 3 -- Habitat Engineering.** Now we're getting somewhere. You
have a `CLAUDE.md` or equivalent that gives the AI your conventions at
session start. You have a `HARNESS.md` declaring your constraints.
Reflections are captured. Sessions improve over time because the
*environment* accumulates knowledge, not just the people.

**Level 4 -- Specification Architecture.** Specs before code. You write
what you want before the AI writes how to build it. You have an agent
pipeline with safety gates -- multiple AI agents reviewing,
verifying, enforcing. The AI is a colleague with defined
responsibilities, not a typewriter you occasionally shout at.

**Level 5 -- Sovereign Engineering.** Reusable plugins. Cross-team
templates. Cost tracking. Model routing. Organisational governance.
You're not just using AI well -- you're building the infrastructure
for your entire organisation to use AI well.

---

Here's the key insight, and it's easy to miss: these are *diagnostic*
positions, not aspirational destinations. You're already at one of
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
Level 3 but verification stuck at Level 1. Your assessed level? Level
1. The chain breaks at the weakest link, because that weakest link is
where the AI will hurt you.

> **Brain check:** Open your repo right now. Is there a file in there
> that declares a practice you've stopped doing? A reflection log with
> no recent entries? A constraints file that hasn't been touched since
> you created it? That gap between declaration and practice -- that's
> exactly what assessment measures.

---

## The Practice: Assessment as Quarterly Discipline

You wouldn't check your bank balance once and then never look again.
You wouldn't step on the scales in January and assume the number
holds through December. So why would you assess your AI literacy once
and call it done?

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

**4. Document.** A timestamped assessment file lands in your repo.
Evidence, rationale, strengths, gaps, recommendations. Not a slide
deck. A file. In the codebase. Where it belongs.

**5. Adjust.** Immediate habitat hygiene -- stale counts updated,
missing entries added, drift between declared and actual practice
corrected. These happen *in the same session*. Not as action items
for next sprint. Now.

**6. Recommend.** Workflow changes based on gaps. Not "build something
new" but "use what you already have differently." Unverified
constraints promoted. Dormant files activated. Cadences established.
Each recommendation is presented, accepted or rejected, and applied
immediately if accepted.

**7. Reflect.** The assessment captures a reflection on itself. What
surprised you? Where did evidence diverge from perception? What should
future assessments pay attention to? This reflection feeds your
`REFLECTION_LOG.md`, feeds curation, feeds the learning loop.

> **The Veteran:** "First assessment, we thought we were Level 3. We
> were Level 2 -- verification was solid but our habitat was stale.
> Second assessment, three months later: Level 3. Not because we built
> anything new. Because we started *operating* what we already had. The
> CLAUDE.md got updated fortnightly. The constraints got enforced. The
> reflections got curated. Same infrastructure, different discipline."

Here's the mechanism that makes this powerful: **each assessment raises
the floor for the next one.** Recommendations from Q1 become evidence
in Q2. The adjustments you make in April are the signals the scan
finds in July. It compounds. Not dramatically -- incrementally, the
way everything valuable compounds.

You just read that and your brain filed it under "sure, compound
improvement, I get it." You don't get it yet. Let me say it
differently: the team that runs four assessments a year doesn't
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

## What Happens After

Three things follow an assessment. Not three things you plan to do.
Three things that happen *in the session*.

**Immediate adjustments.** Habitat hygiene, fixed on the spot. Your
`HARNESS.md` status section says you have twelve constraints but you
actually have fifteen? Updated. Your README badge shows Level 2 but
the assessment just confirmed Level 3? Updated. Your `AGENTS.md`
gotchas section is empty despite three months of hard-won lessons?
Populated. These aren't improvements. They're corrections -- bringing
your declared state in line with your actual state.

**Workflow recommendations.** This is not a backlog of feature work.
It's changes to how you *operate* what you already have. A constraint
that's been sitting unverified for two months gets promoted to
agent-backed enforcement. An `AGENTS.md` file that exists but nobody
reads at session start gets wired into the workflow. A reflection
cadence that was "whenever we remember" becomes "every Friday before
standup."

**The reflection.** The assessment captures a reflection on itself --
what it found, what was surprising, what future assessments should
watch for. This reflection feeds `REFLECTION_LOG.md`. Which feeds
curation. Which feeds the harness. The assessment is *part of* the
learning loop, not outside it.

> **Brain check:** Think about retrospective action items. The ones
> your team writes on sticky notes and then never does. Assessment is
> different because it applies changes in the same session. The gap
> between "we should" and "we did" collapses to zero. That's not a
> minor detail. That's the entire reason it works.

And then there's the badge. A small thing, but it matters. Your README
gets a badge showing your assessed level, linking to the full
assessment document with all its evidence and rationale. Not vanity.
Accountability. Anyone can click it and see exactly why you're at the
level you're at -- and what you'd need to do to reach the next one.

> **The Sceptic:** "So the badge is just for show?"
>
> **The Pragmatist:** "Click it. It links to the full assessment --
> every piece of evidence, every gap, every recommendation. It's a
> claim with receipts. Try putting *that* on your sprint retro slides."

---

The first series in this collection argued that **the environment is
the product.** This article adds one thing: you have to know the state
of the product. Not guess. Not assume. Not hope. *Know.*

Assessment is how you know. Not once. Quarterly. As a discipline, not
a chore.

Run `/assess`. Fifteen minutes. You'll learn more from one assessment
than from six months of vague intention. And three months from now,
when you run it again, you'll see the distance you've covered -- not
because you felt it, but because the evidence says so.

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
