# The oracle

An operating instruction for coding agents: how we work and why — expectations, decisions, results. Never how code solved something; code and git hold that.

One file plus a pinned list of behaviors. Names no tool, defines no product — process only. No package, no runtime, no tool of ours: any agent that read a URL and write a file can install it.

## Install

Paste this at your agent, in the repository you want it:

```
Install this in this repo: https://raw.githubusercontent.com/yesitsfebreeze/oracle/v1/ORACLE.md
```

That is the whole install. There is nothing to clone, package, or run — the link is a copy of the oracle, and the agent already hold it once it fetch.

It land `ORACLE.md` at your repository root, wire your tool's auto-loaded instruction file to read it, install a pre-commit hook for the ruling, prove all of it with four probes, then cut its own install section — it ran once, and installed repository carry no manual for a job already done.

`ORACLE.md` is committed: it is the thing installed. Pointer file and hook are install products — per-clone, rebuilt by any install, kept out of history via `.git/info/exclude`. Committed install product is second copy that can drift.

Pin the ref (`v1`, or a commit SHA) rather than `main`. Both propagate; pin propagate when you decide, `main` propagate the moment someone push — including a typo, to every repository pointing here, before anyone notice it was made.

### What you get

`ORACLE.md` is machinery first, content last, split by `---`. Machinery is identical in every install: who the oracle is, how it operate, and the ruling — the contract that outlive the install. Content is yours alone: vision, features, roadmap, changelog, specialists. This repository ship it with content empty. Another repository's answers are its own.

The ruling, in short: a commit that touch `ORACLE.md` must grow the changelog, or it is blocked. A decision not recorded is a decision not made.

## Behaviors

The oracle's philosophy is not written in `ORACLE.md` — a second copy drift, and the drifted one is always the one you read. It live here, one behavior per file, and installs point at it by pinned URL. Upstream fix reach every repository at next session; the pin decide when.

One behavior per file. Each a heading plus few lines — small enough to read fully before deciding if you want it.

Compose a startup prompt by listing the behaviors you want, in the order you want them read. They concatenate into coherent markdown in any subset, any order; that the only contract this folder keep. No file references another, no file assumes a neighbour, no file carries frontmatter — metadata would land in the composed prompt as literal noise.

Order is emphasis, not dependency. Earlier is heavier.

### Stance

| Behavior | In one line |
|---|---|
| [`push-back`](behaviors/push-back.md) | Disagree out loud when user wrong. |
| [`avoided-question-first`](behaviors/avoided-question-first.md) | Ask question everyone talking around. |
| [`name-the-tradeoff`](behaviors/name-the-tradeoff.md) | Say what design gives up, before writing code. |
| [`delay-over-assume`](behaviors/delay-over-assume.md) | Stop and examine assumption rather than build on it. |
| [`no-flattery`](behaviors/no-flattery.md) | Skip opening compliment. |
| [`no-scope-creep`](behaviors/no-scope-creep.md) | Do what was asked, then stop. |

### Reporting

| Behavior | In one line |
|---|---|
| [`verify-before-claiming`](behaviors/verify-before-claiming.md) | Look at world before saying it works. |
| [`report-plainly`](behaviors/report-plainly.md) | Say what happened, including failures. |
| [`flag-uncertainty`](behaviors/flag-uncertainty.md) | Mark parts you not confident about. |
| [`lead-with-outcome`](behaviors/lead-with-outcome.md) | First sentence answers "what happened". |

### Execution

| Behavior | In one line |
|---|---|
| [`act-when-sufficient`](behaviors/act-when-sufficient.md) | Enough to act, act. No re-derive or re-litigate. |
| [`parallel-independent-work`](behaviors/parallel-independent-work.md) | Independent calls go out together. |
| [`search-dont-guess`](behaviors/search-dont-guess.md) | Find file by searching, not guessing. |
| [`read-before-edit`](behaviors/read-before-edit.md) | Never rewrite file you not read. |
| [`dont-guess-the-api`](behaviors/dont-guess-the-api.md) | Check signature; remembered API is plausible one. |
| [`right-tool-for-the-job`](behaviors/right-tool-for-the-job.md) | Dedicated tool before shell. |
| [`delegate-the-fan-out`](behaviors/delegate-the-fan-out.md) | Subagent for sweep; keep conclusion. |

### Debugging

| Behavior | In one line |
|---|---|
| [`reproduce-first`](behaviors/reproduce-first.md) | See bug happen before changing anything. |
| [`read-the-error`](behaviors/read-the-error.md) | Whole message, including boilerplate. |
| [`one-change-at-a-time`](behaviors/one-change-at-a-time.md) | Change one thing and look. |
| [`fix-the-root`](behaviors/fix-the-root.md) | Fix cause, not symptom. |
| [`stop-when-thrashing`](behaviors/stop-when-thrashing.md) | Third failed attempt means model of problem wrong. |

### Engineering

| Behavior | In one line |
|---|---|
| [`builtin-before-built`](behaviors/builtin-before-built.md) | Check for premade solution before writing anything. |
| [`delete-superseded`](behaviors/delete-superseded.md) | Remove cruft in change that supersedes it. |
| [`fix-bugs-on-sight`](behaviors/fix-bugs-on-sight.md) | Noticed bug is our bug. |
| [`comments-last-resort`](behaviors/comments-last-resort.md) | Comment only constraint code cannot express. |
| [`match-the-ground`](behaviors/match-the-ground.md) | New code reads like code around it. |

### Process

| Behavior | In one line |
|---|---|
| [`philosophy-before-answers`](behaviors/philosophy-before-answers.md) | Answer from principle, not ad-hoc state. |
| [`enforced-not-remembered`](behaviors/enforced-not-remembered.md) | Mechanically checkable rules get machinery at commit. |
| [`portable-before-proprietary`](behaviors/portable-before-proprietary.md) | Adapters add convenience, never carry only copy. |
| [`record-the-decision`](behaviors/record-the-decision.md) | Record decision in change that makes it, or it was not made. |

### Provenance

Stance, Engineering, Process behaviors distilled from philosophy already in use — lived with before written down. Reporting, Execution, Debugging behaviors are account of where agent turns actually wasted, written from experience not cited source. Weaker provenance; read with more suspicion, delete ones that do not earn their line.

### Composing

The install create your instruction file; picking behaviors is the one step that need a human, so it is left to you.

`AGENTS.md` lists picks. `CLAUDE.md` is one line that imports it — Claude Code reads `CLAUDE.md`, not `AGENTS.md`, and `@` imports resolve local paths only, so URLs must sit behind an instruction to read them rather than an import.

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

This repository public so `raw.githubusercontent.com` resolves without credentials — fetching agent carries none.

Two constraints the scheme does not escape:

- **Every URL is a fetch before the first answer.** Ten behaviors is ten round-trips on every session start.
- **The fetch is an instruction, not a mechanism.** Nothing guarantees it happens; agent complies, and compliance is not a contract. Prefer few and heavy over many and thin.

## Checking

```
testbed/check.sh              # behaviors contract. Free, offline, instant.
testbed/check.sh --install    # also install end-to-end with a real agent.
```

The contract check read files. The install check serve this repository over HTTP, hand a fresh agent nothing but the URL, and assert what it built — so it need credentials, network, and real tokens. That is why it opt in.

Contract asserted and never checked is contract that break quiet: a compression pass once stripped every trailing newline from `behaviors/`, welding each heading to the paragraph above, and nothing noticed until something composed.

`HARNESS=codex testbed/check.sh --install` run the same install against another agent. Codex auto-load `AGENTS.md`, Claude Code auto-load `CLAUDE.md` — the install must detect that rather than assume, which is the point of testing a second harness.
