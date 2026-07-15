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

`ORACLE.md`, and it is machinery whole — who the oracle is, how it operate, and the ruling: a commit that change what you are building must grow `CHANGELOG.md`, or it is blocked. A decision not recorded is a decision not made.

It carry none of your answers, so it stay identical in every install. Those live beside it, one kind per file — `VISION.md`, `FEATURES.md`, `ROADMAP.md`, `CHANGELOG.md`, `SPECIALISTS.md` — each written the moment it first hold something, not laid down empty at install.

## Behaviors

The philosophy live in [`behaviors/`](behaviors/), one per file: short, composable, decision-shaped. Installs point at them by pinned URL rather than copying them — a second copy drift, and the drifted one is always the one you read. Upstream fix reach every repository at next session; the pin decide when.

A menu, not a default. Pick with your agent when it install.
