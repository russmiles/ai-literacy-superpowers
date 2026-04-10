# The Loops That Learn

## Four practices, four timescales, one compounding system

*The Loops That Learn -- Companion to The Environment Hypothesis series*

---

It's July. Your team set up their AI development environment back in
January. They wrote a `CLAUDE.md`. They defined constraints in
`HARNESS.md`. They configured agents. They even ran a reflection or two
in the first week.

And then... nothing.

The `CLAUDE.md` they wrote in January is the same `CLAUDE.md` they have
today. The constraints they declared have never been audited. The
reflection log has three entries, all from the same Tuesday afternoon in
January when someone was excited about the new workflow. The harness they
built -- the one that was going to make their AI output consistently
excellent -- is a museum piece. Static. Frozen in amber.

They did the hard work of setting up. Then they stopped *operating*.

This is the most common failure mode in AI-assisted development. Not the
team that never starts. The team that starts brilliantly and then goes
quiet. They have all the infrastructure. They have none of the
discipline. And infrastructure without discipline is just documentation
that nobody reads.

Here it is, the claim this article is built on:

**The infrastructure is not the product. The loops are the product.**

You just read that and filed it under "obvious." It is not obvious. If
it were obvious, your reflection log wouldn't have three entries from
six months ago. So let me say it differently: in every team we've
watched, the ones that run the loops with mediocre infrastructure
outperform the ones with brilliant infrastructure that never operate
it. The loops are the thing. The infrastructure is just the surface
they run on.

---

## The Four Loops

Here's the map.

| Loop | Command | Cadence | What it captures | What it feeds |
| --- | --- | --- | --- | --- |
| Reflection | `/reflect` | Every session | Surprises, signals, constraints | AGENTS.md, HARNESS.md |
| Health | `/harness-health` | Monthly | Enforcement ratio, GC status, learning velocity, session quality | Snapshots, trends, badges |
| Assessment | `/assess` + improvements | Quarterly | Level, discipline scores, gaps, executable actions | Assessment docs, improvement plans |
| Cost | `/cost-capture` | Quarterly | Spend, tokens, model mix, budget status | MODEL_ROUTING.md, cost trends |

Four loops. Four timescales. From "end of every session" to "once a
quarter."

---

### The Reflection Loop -- every session

This is the fastest loop. Two minutes at the end of a coding session.
What was surprising? What should future sessions know? What kind of
signal is this -- a context gap, an instruction insight, a workflow
pattern, or a preventable failure?

The reflection gets classified, logged, and -- if it describes a
failure -- optionally turned into a constraint proposal on the spot.
That last part matters. A reflection that says "the AI ignored the
repository pattern again" can become a new `HARNESS.md` constraint
before you close your terminal.

**What happens if you skip it:** every session starts from scratch. The
Groundhog Day problem from Article 6 -- the AI forgets what you taught
it yesterday. Without reflections, you are the only memory in the
system, and your memory is not version-controlled.

---

### The Health Loop -- monthly

Once a month, you take a snapshot. `/harness-health` reads your
`HARNESS.md`, your reflection log, your agents, your cost data, and
your previous snapshots. It computes an enforcement ratio (how many
declared constraints are actually enforced), a learning velocity (how
many reflections carry a signal), and five meta-observability checks
that tell you whether the harness itself is healthy.

Then it compares to last month. Are things improving, stable, or
declining? It writes the snapshot, updates a badge, and nudges you if
anything is overdue.

> **The Sceptic:** "Monthly health checks on my development environment.
> This sounds like bureaucracy with extra steps."
>
> **The Pragmatist:** "How many of your constraints are actually
> enforced right now? Not how many you declared. How many are running
> in CI?"
>
> **The Sceptic:** "I'd have to check."
>
> **The Pragmatist:** "That's the point. You haven't checked since you
> set them up. The health snapshot checks for you. Five minutes, once a
> month."

**What happens if you skip it:** drift goes unnoticed. You declared
fifteen constraints in January. Three of them broke when you upgraded
your CI pipeline in March. Nobody noticed. Your harness has been running
at 80% for four months and you think it's at 100%. The health loop
catches this. Without it, you're flying on instruments that stopped
working and you don't know.

---

### The Assessment Loop -- quarterly

Article 7 covers this in depth. The short version: `/assess` scans your
repo for evidence, scores you across three disciplines, and then *acts*
-- fixing stale counts, proposing workflow changes, and mapping every
gap to the specific command that closes it. Fifteen minutes that changes
how you operate for the next three months.

**What happens if you skip it:** you lose your position. You think
you're Level 3 because you were Level 3 last quarter. But your
`CLAUDE.md` hasn't been updated in two months and your reflection log
went quiet in February. You're Level 1 wearing a Level 3 costume.
Without assessment, you'll never know.

---

### The Cost Loop -- quarterly

The quietest loop, and the one most teams ignore longest.
`/cost-capture` walks you through your provider dashboards, records
spend, token volumes, and model mix. It compares to the previous
quarter. It checks against a budget if you have one. And -- this is the
part that connects it to everything else -- it proposes routing changes.

If you're burning frontier-model tokens on boilerplate tasks, the cost
snapshot will show it. If your spend doubled but your output quality
didn't noticeably improve, the data makes that visible. Changes flow
into `MODEL_ROUTING.md`, which the AI reads at session start.

**What happens if you skip it:** you either overspend without knowing,
or -- more commonly -- you under-invest because nobody has evidence that
the spend is worth it. The first VP who asks "what are we paying for AI
tools?" gets a shrug instead of a number. That shrug leads to budget
cuts. Budget cuts lead to model downgrades. And you lose capability
you'd built your environment around. The cost loop is your defence
against uninformed austerity.

---

## How They Interlock

Here's the part that makes the four loops more than four separate
practices. They feed each other -- the output of one becomes the input
of another.

**Reflections surface gaps. Assessment confirms them.** You write three
reflections noting that the AI keeps ignoring your error handling
conventions. Quarterly assessment scans the reflection log, sees the
pattern, identifies the gap formally, and generates an improvement plan
that includes promoting the convention to an agent-backed constraint.
The reflection spotted it. The assessment processed it.

**Health snapshots track whether improvements stuck.** Assessment in
April recommends promoting three constraints from declared to
deterministic. You do it. The May health snapshot shows enforcement
ratio jumped from 60% to 85%. The June snapshot confirms it held. The
July assessment sees three months of stable evidence and scores you
higher. The health loop provided the evidence the assessment needed.

**Cost data informs model routing. Routing affects quality. Quality
affects reflections.** Your cost snapshot reveals you're spending 70% of
your budget on a frontier model for everything, including test
generation. You route test generation to a standard model via
`MODEL_ROUTING.md`. Reflections in the following weeks show whether
the quality held or dropped. If test quality suffers, the next
reflection captures it. If it holds, you've found savings without
sacrifice -- and the next cost snapshot proves it.

The interlock only works if the upstream loop is honest. If your
reflections are vague summaries instead of signal-classified entries,
assessment has nothing to process. If your health snapshots aren't
running, assessment can't see whether improvements stuck. Garbage in,
garbage out. The system compounds quality -- but it also compounds
neglect.

> **The Sceptic:** "So if I skip reflections for a month, the whole
> thing breaks?"
>
> **The Pragmatist:** "It doesn't break. It just stops learning.
> Assessment still runs, but it's working from stale data. Health still
> snapshots, but there's nothing new to measure. The loops don't crash
> -- they go quiet. And quiet is worse than broken, because broken you
> notice."

---

## The Literacy Level Connection

Remember the six levels from Article 7? Each level doesn't just require
different *infrastructure*. It requires different *loops* to sustain it.

**Level 2 -- Verification.** You need CI, tests, and linting. But you
don't need operational loops to *maintain* verification. CI either runs
or it doesn't. This level sustains itself through automation. No
recurring practice required beyond keeping your pipeline green.

**Level 3 -- Habitat Engineering.** This is where the loops become
essential. A habitat is a living thing. Your `CLAUDE.md` decays if
nobody updates it. Your constraints drift if nobody audits them. Your
reflection log goes silent if nobody writes in it. Level 3 *requires*
`/reflect` and `/harness-health` as ongoing practices. Without them,
you built a habitat and let it die. You're wearing Level 3's clothes
but living at Level 1.

**Level 4 -- Specification Architecture.** Specs before code, agent
pipelines with safety gates. This is sophisticated machinery that needs
periodic calibration. `/assess` becomes critical here -- are your specs
actually driving implementation, or have you drifted back to
code-first with specs written after the fact? The quarterly assessment
catches the drift before it becomes habit.

**Level 5 -- Sovereign Engineering.** All four loops, plus the
portfolio view. You're governing AI practices across multiple repos.
The concrete difference: a Level 5 team can answer "what is our AI
literacy across all twelve repos?" with a dashboard backed by evidence.
They can answer "what are we spending and is it worth it?" with cost
snapshots. They can answer "which teams need help?" with portfolio-level
shared gap analysis. Without the loops running, none of those questions
have answers. Sovereign engineering is governance, and governance
requires data.

> **Brain check:** Which loops are you actually running? Not which ones
> you set up -- which ones you *ran last month*? If the answer is
> "none," you know what your real level is, regardless of what
> infrastructure sits in your repo.

---

## The Portfolio View

Everything so far operates per-repo. One reflection log. One health
snapshot. One assessment. One cost capture. That's the right grain for
a team working in a single codebase.

But organisations don't have one repo. They have twelve. Or fifty. Or
three hundred. And the question changes from "how is this repo doing?"
to "how is our AI practice doing?"

The **portfolio view** aggregates across repos. `/portfolio-assess`
discovers repos -- from a local directory, a GitHub organisation, or a
topic tag -- and gathers their individual assessments into one picture.
Level distribution. Shared gaps. Outliers. Stale assessments.

Three things become visible at portfolio scale that you cannot see from
inside a single repo.

**Shared gaps.** When five out of eight repos have no reflection
practice, that's not eight repo problems. That's one organisational
problem. Roll out a reflection cadence template once and five repos
move toward Level 3.

**Outliers.** One repo at Level 4 while the rest sit at Level 2. What
are they doing differently? The portfolio surfaces the question. The
answer becomes a template for everyone else.

**Stale assessments.** A repo assessed six months ago is a repo where
you're guessing. The portfolio flags it.

**What happens without portfolio visibility:** organisations make AI
tooling decisions based on anecdote. The loudest team gets the budget.
The quietest team loses access. Nobody knows which repos have working
harnesses and which have museum pieces. The portfolio replaces
anecdote with evidence.

The **portfolio dashboard** turns this into a self-contained HTML file
-- no dependencies, opens in any browser, printable -- that makes the
loops visible to leadership. The numbers link to evidence. The levels
link to assessment documents. Not a vanity metric. A claim with
receipts.

---

Here's your action: pick one loop you're not running. Just one.

If you've never reflected, run `/reflect` after your next session.
Two minutes.

If you've never checked your harness health, run `/harness-health`
this week. Five minutes.

If you've never assessed, run `/assess` this month. Fifteen minutes.

One loop. One cycle. That's enough to start the compounding.

---

## The Bullet Points

- **Infrastructure without operations is a museum** -- the environment
  you built in January is only as good as the loops that keep it current
- **Four loops, four timescales** -- reflection (every session), health
  (monthly), assessment (quarterly), cost (quarterly)
- **Each loop captures what the others can't** -- reflections catch
  session-level signals, health tracks trends, assessment calibrates
  level, cost governs spend
- **The loops interlock** -- reflections surface gaps that assessment
  confirms; health snapshots prove improvements stuck; cost data drives
  routing that affects quality
- **Literacy levels require loops to sustain them** -- Level 2
  self-sustains through CI; Level 3 needs reflection and health;
  Level 4 needs assessment; Level 5 needs all four plus portfolio
- **The portfolio view is the organisational lens** -- shared gaps,
  outliers, and stale assessments become visible only at portfolio scale
- **Pick one loop you're not running** -- one cycle is enough to start
  the compounding
