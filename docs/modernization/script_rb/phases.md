# Phases

Status: planning and review.

## Phase 0: Contracts And Safety Rails

Lock down current behavior before touching production runtime code.

Expected PRs:

1. Documentation and review structure.
2. Characterization specs and fixtures.
3. Contract adjustments discovered during spec work.

Precursor areas:

- `global_defs.rb` because global helpers are the largest public compatibility
  surface.
- `settings.rb`, `vars.rb`, and `uservars.rb` because persistence identity and
  storage boundaries affect script isolation.
- hooks/watchfor because scripts register runtime event behavior directly.
- `spell.rb` because scripts call it heavily and it should be contract-inventoried
  before deep runtime isolation work.

## Phase 1: Pure Extraction

Extract low-risk helpers from `script.rb` without changing behavior.

Candidate extraction targets:

- launch option parsing,
- script file resolution,
- error reporting,
- script startup result handling.

No runtime behavior changes should be introduced in this phase.

## Phase 2: Registry And Lifecycle

Move running/hidden script state and lifecycle operations behind explicit
runtime services while preserving existing public calls.

Public APIs such as `Script.current`, `Script.start`, `Script.run`,
`Script.kill`, `Script.pause`, and `Script.running?` should continue to work.

## Phase 3: IO, Buffers, And Storage Boundaries

Route downstream, upstream, script-output, and file/database access through
runtime services.

This phase should preserve legacy direct field syntax, including
`Script.current.want_downstream_xml = true`, while making the implementation
route through controlled facades where feasible.

## Phase 3B: Migration Controls

Add explicit controls before behavior becomes conditional.

Expected controls:

- forced legacy mode,
- diagnostics for runtime mode and compatibility paths,
- low-noise logging through `Lich.log`,
- user-visible console/game-screen messages only where useful,
- rollback notes for each behavior-changing PR.

## Phase 4: Runtime Capability Adapter

Introduce a runtime adapter boundary for future isolation.

Potential capability groups:

- script lifecycle,
- current-script identity and state,
- game/client IO,
- settings and storage,
- hooks and events,
- spell/domain services.

## Phase 5: Related API Modernization

Modernize related surfaces after their contracts are protected.

Likely order:

1. `global_defs.rb`
2. `settings.rb` / `vars.rb` / `uservars.rb`
3. hooks/watchfor
4. `spell.rb`

## Phase 6: Future Ruby::Box Work

If Ruby::Box or similar isolation primitives become available, expose curated
capabilities to isolated scripts instead of giving direct access to core runtime
objects.

Legacy scripts should continue through compatibility facades.
