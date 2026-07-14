# Behaviors

One behavior per file. Each a heading plus few lines — small enough to read fully before deciding if you want it.

Compose startup prompt by listing behaviors you want, in order you want them read. They concatenate into coherent markdown in any subset, any order; that only contract this folder keeps. No file references another, no file assumes neighbour, no file carries frontmatter — metadata would land in composed prompt as literal noise.

Order is emphasis, not dependency. Earlier is heavier.

`./check.sh` enforce all of it. Contract asserted and never checked is contract that break quiet: a compression pass once stripped every trailing newline here, welding each heading to paragraph above, and nothing noticed until something composed.

## Stance

| Behavior | In one line |
|---|---|
| [`push-back`](push-back.md) | Disagree out loud when user wrong. |
| [`avoided-question-first`](avoided-question-first.md) | Ask question everyone talking around. |
| [`name-the-tradeoff`](name-the-tradeoff.md) | Say what design gives up, before writing code. |
| [`delay-over-assume`](delay-over-assume.md) | Stop and examine assumption rather than build on it. |
| [`no-flattery`](no-flattery.md) | Skip opening compliment. |
| [`no-scope-creep`](no-scope-creep.md) | Do what was asked, then stop. |

## Reporting

| Behavior | In one line |
|---|---|
| [`verify-before-claiming`](verify-before-claiming.md) | Look at world before saying it works. |
| [`report-plainly`](report-plainly.md) | Say what happened, including failures. |
| [`flag-uncertainty`](flag-uncertainty.md) | Mark parts you not confident about. |
| [`lead-with-outcome`](lead-with-outcome.md) | First sentence answers "what happened". |

## Execution

| Behavior | In one line |
|---|---|
| [`act-when-sufficient`](act-when-sufficient.md) | Enough to act, act. No re-derive or re-litigate. |
| [`parallel-independent-work`](parallel-independent-work.md) | Independent calls go out together. |
| [`search-dont-guess`](search-dont-guess.md) | Find file by searching, not guessing. |
| [`read-before-edit`](read-before-edit.md) | Never rewrite file you not read. |
| [`dont-guess-the-api`](dont-guess-the-api.md) | Check signature; remembered API is plausible one. |
| [`right-tool-for-the-job`](right-tool-for-the-job.md) | Dedicated tool before shell. |
| [`delegate-the-fan-out`](delegate-the-fan-out.md) | Subagent for sweep; keep conclusion. |

## Debugging

| Behavior | In one line |
|---|---|
| [`reproduce-first`](reproduce-first.md) | See bug happen before changing anything. |
| [`read-the-error`](read-the-error.md) | Whole message, including boilerplate. |
| [`one-change-at-a-time`](one-change-at-a-time.md) | Change one thing and look. |
| [`fix-the-root`](fix-the-root.md) | Fix cause, not symptom. |
| [`stop-when-thrashing`](stop-when-thrashing.md) | Third failed attempt means model of problem wrong. |

## Engineering

| Behavior | In one line |
|---|---|
| [`builtin-before-built`](builtin-before-built.md) | Check for premade solution before writing anything. |
| [`delete-superseded`](delete-superseded.md) | Remove cruft in change that supersedes it. |
| [`fix-bugs-on-sight`](fix-bugs-on-sight.md) | Noticed bug is our bug. |
| [`comments-last-resort`](comments-last-resort.md) | Comment only constraint code cannot express. |
| [`match-the-ground`](match-the-ground.md) | New code reads like code around it. |

## Process

| Behavior | In one line |
|---|---|
| [`philosophy-before-answers`](philosophy-before-answers.md) | Answer from principle, not ad-hoc state. |
| [`enforced-not-remembered`](enforced-not-remembered.md) | Mechanically checkable rules get machinery at commit. |
| [`portable-before-proprietary`](portable-before-proprietary.md) | Adapters add convenience, never carry only copy. |
| [`record-the-decision`](record-the-decision.md) | Record decision in change that makes it, or it was not made. |

## Provenance

Stance, Engineering, Process behaviors distilled from philosophy already in use — lived with before written down. Reporting, Execution, Debugging behaviors are account of where agent turns actually wasted, written from experience not cited source. Weaker provenance; read with more suspicion, delete ones that do not earn their line.

## Composing

`AGENTS.md` lists picks. `CLAUDE.md` is one line that imports it — Claude Code reads `CLAUDE.md`, not `AGENTS.md`, and `@` imports resolve local paths only, so URLs must sit behind instruction to read them rather than an import.

`CLAUDE.md`:

```markdown
@AGENTS.md
```

`AGENTS.md`:

```markdown
Read each URL below in the order listed, before your first answer. Together they are your operating instruction.

1. https://raw.githubusercontent.com/yesitsfebreeze/oracle/v1/behaviors/push-back.md
2. https://raw.githubusercontent.com/yesitsfebreeze/oracle/v1/behaviors/avoided-question-first.md
3. https://raw.githubusercontent.com/yesitsfebreeze/oracle/v1/behaviors/builtin-before-built.md
```

Pin the ref (`v1`, or commit SHA) rather than `main`. Both propagate; pin propagates when you decide, `main` propagates moment you push — including typo, to every repository pointing here, before you noticed you made it.

This repository public so `raw.githubusercontent.com` resolves without credentials — fetching agent carries none.

Two constraints scheme does not escape:

- **Every URL is a fetch before the first answer.** Ten behaviors is ten round-trips on every session start.
- **The fetch is an instruction, not a mechanism.** Nothing guarantees it happens; agent complies, and compliance is not a contract. Prefer few and heavy over many and thin.
