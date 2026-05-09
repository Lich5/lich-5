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
| Compatibility fixtures | Planned; not implemented in this PR. |
| Production refactor | Not started. |

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

- [Phases](phases.md)
- [Corpus Summary](corpus-summary.md)
- [API Contract Summary](api-contract-summary.md)
- [Review Plan](review-plan.md)
