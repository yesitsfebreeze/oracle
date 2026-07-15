# The oracle

An operating instruction for coding agents: how we work and why — expectations, decisions, results. Never how code solved something; code and git hold that.

One file plus a pinned list of behaviors. Names no tool, defines no product — process only.

## Install

Paste this at your agent, in the repository you want it:

```
Install this in this repo: https://raw.githubusercontent.com/yesitsfebreeze/oracle/v1/ORACLE.md
```

That is the whole install. Nothing to clone, package, or run — the link is a copy of the oracle, and any agent that read a URL and write a file can do it.

It land `ORACLE.md` at your repository root, wire your tool's auto-loaded instruction file to read it, install a pre-commit hook, prove all of it, then cut its own install section — that section ran once, and an installed repository carry no manual for a job already done.

Pin the ref (`v1`, or a commit SHA) rather than `main`. Both propagate; a pin propagate when you decide, `main` the moment someone push.

## What you get

`ORACLE.md`: machinery first, your content last, split by `---`.

Machinery is identical in every install — who the oracle is, how it operate, and the ruling: a commit that touch `ORACLE.md` must grow the changelog, or it is blocked. A decision not recorded is a decision not made.

Content is yours alone — vision, features, roadmap, changelog, specialists. This repository ship it empty.

## Behaviors

The philosophy live in [`behaviors/`](behaviors/), one per file: short, composable, decision-shaped. Installs point at them by pinned URL rather than copying them — a second copy drift, and the drifted one is always the one you read. Upstream fix reach every repository at next session; the pin decide when.

A menu, not a default. Pick with your agent when it install.
