# script.rb Modernization

Status: planning and review.

This directory tracks the modernization plan for `lib/common/script.rb` and the
script runtime APIs it exposes. The goal is zero-regression modernization:
preserve current script behavior first, then extract internals behind clearer
runtime boundaries.

## Current Review Status

| Area | Status |
| --- | --- |
| Corpus inventory | Drafted locally from public script repositories. |
| API tiering | Drafted locally and summarized here for review. |
| Contract worksheet | Drafted locally for Preserve-tier APIs. |
| Characterization specs | Open in [Lich5/lich-5#3](https://github.com/Lich5/lich-5/pull/3). |
| Compatibility fixtures | Planned; not implemented yet. |
| Production refactor | Not started. |

## Active PRs

- Planning docs: [Lich5/lich-5#2](https://github.com/Lich5/lich-5/pull/2)
- Characterization specs: [Lich5/lich-5#3](https://github.com/Lich5/lich-5/pull/3)
- Temporary upstream specs PR:
  [elanthia-online/lich-5#1349](https://github.com/elanthia-online/lich-5/pull/1349)

Planning docs and generated artifacts should remain in `Lich5/lich-5` until
intentionally promoted. The upstream specs PR exists because the same fork
branch was also opened against `elanthia-online/lich-5`.

## Scope

Primary target:

- `lib/common/script.rb`

Closely related surfaces:

- `lib/global_defs.rb`
- `lib/common/settings.rb`
- `lib/common/vars.rb`
- `lib/common/uservars.rb`
- `lib/common/downstreamhook.rb`
- `lib/common/upstreamhook.rb`
- `lib/common/watchfor.rb`
- `lib/common/spell.rb`

## Why This Exists

`script.rb` is both runtime implementation and public script API. Scripts depend
on class methods, globals, direct script state fields, settings behavior,
buffers, hooks, and Wizard compatibility behavior.

Once merged, the first characterization spec set becomes a hard guardrail for
selected script-facing behavior during modernization. As the effort expands,
future checks should be classified deliberately as invariant, drift signal, or
exploratory.

The modernization approach is therefore:

1. Document current behavior.
2. Add characterization specs.
3. Extract internals behind compatibility-preserving facades.
4. Add migration controls and diagnostics.
5. Prepare future runtime capability seams, including possible Ruby::Box-style
   script isolation in Ruby versions that support it.

## Important Boundary

`Settings` and `Vars` / `UserVars` are related persistence concepts, but they
are not the same storage system today.

- `Settings` uses `script_auto_settings`.
- `Vars` / `UserVars` use `uservars`.

Any future consolidation would be a separate migration project, not a simple
wrapper refactor.

## Documents

- [Review Context](review-context.md)
- [Current Status](current-status.md)
- [Project Checklist](project-checklist.md)
- [Phases](phases.md)
- [Corpus Summary](corpus-summary.md)
- [API Contract Summary](api-contract-summary.md)
- [Review Plan](review-plan.md)
