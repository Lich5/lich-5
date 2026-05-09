# script.rb Review Context

Use this page to orient reviewers and seed AI-assisted review tools before
reviewing `script.rb` modernization work.

## Goal

Modernize `lib/common/script.rb` with near-zero regression for existing scripts,
while moving the implementation toward isolation boundaries that can support
future Ruby::Box-style hardening when Ruby provides that capability.

The target is not only operational parity. The long-term goal is to preserve
script-facing behavior while reducing the ability of scripts to depend on, or
reach into, private Lich core internals.

## Current Guardrail Position

Once merged, the first characterization spec set becomes a hard guardrail for
selected script-facing behavior during `script.rb` modernization. These checks
cover behavior we currently believe must not drift accidentally: IO and flow
helpers, hooks/watchfor behavior, and Settings/Vars/UserVars boundaries.

As the effort expands, not every observation should become a hard gate. Future
checks should be classified deliberately as invariant, drift signal, or
exploratory. Invariant checks fail CI; drift signals warn and produce review
context; exploratory checks support planning and corpus analysis.

That lets us protect known compatibility contracts while still collecting useful
modernization signals as PR volume increases.

## Active PRs

- Human planning docs: [Lich5/lich-5#2](https://github.com/Lich5/lich-5/pull/2)
- Characterization specs: [Lich5/lich-5#3](https://github.com/Lich5/lich-5/pull/3)
- Accidental upstream specs PR, intentionally left visible for now:
  [elanthia-online/lich-5#1349](https://github.com/elanthia-online/lich-5/pull/1349)

Only the characterization specs currently have an upstream EO PR. Planning docs
and artifacts are intended to stay in `Lich5/lich-5` until intentionally
promoted.

## Review Expectations

Classify feedback where practical:

- `Blocker`: breaks compatibility, invalidates phase order, or changes the
  planned contract unintentionally.
- `Question`: needs human decision before implementation.
- `Suggestion`: useful improvement, but not required for the current PR.
- `Future`: valuable, but belongs to a later phase.

Avoid drive-by refactors, broad rewrites, or changes to public script behavior
unless the change is explicitly part of the reviewed contract.

## Agent Prep

For Claude Code, Codex, or another review agent, seed the agent with:

- this file
- [README](README.md)
- [Current Status](current-status.md)
- [Project Checklist](project-checklist.md)
- [Phases](phases.md)
- [API Contract Summary](api-contract-summary.md)
- [Corpus Summary](corpus-summary.md)
- [Review Plan](review-plan.md)

Ask the agent to review within the documented phase, preserve compatibility by
default, and separate blockers from future modernization ideas.
