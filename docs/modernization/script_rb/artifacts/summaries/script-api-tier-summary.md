# script.rb Modernization API Tier Summary

Status: draft, local-only.

This summary converts the first corpus API scan into implementation guidance for
`script.rb` modernization. It is not a final deprecation policy. It is a working
map for deciding what must be contract-locked before extraction and what should
be routed through future Ruby::Box capability seams.

## Tier Definitions

| Tier | Meaning |
| --- | --- |
| Preserve | Treat as public script API. Baseline behavior must remain compatible before and after modernization. |
| Compat | Keep working for legacy scripts, but wrap behind adapters or compatibility shims where possible. |
| Warn / Deprecate | Keep initially, but steer new code away after docs, instrumentation, and migration messaging exist. |
| Unsupported / Private | Do not promote as public contract. May remain available only through legacy runtime behavior. |

## First-Pass Category Tiers

| Surface | Initial tier | Ruby::Box direction | Why |
| --- | --- | --- | --- |
| Core IO globals: `echo`, `respond`, `put`, `fput`, `get`, `wait`, `waitfor`, `waitforre`, `match`, `matchwait`, `clear`, `pause` | Preserve | Console/game IO capability | These are the largest observed compatibility surface and are foundational script ergonomics. |
| Script lifecycle globals: `start_script`, `force_start_script`, `stop_script`, `pause_script`, `unpause_script`, `before_dying`, `undo_before_dying`, `start_exec_script` | Preserve | Script manager capability | High usage and directly tied to script orchestration. Lock behavior before registry extraction. |
| Common `Script.*`: `Script.current`, `Script.run`, `Script.start`, `Script.running?`, `Script.exists?`, `Script.kill`, `Script.pause`, `Script.unpause`, `Script.paused?`, `Script.at_exit`, `Script.exit!` | Preserve | Script manager / current-script capability | These are direct public script controls and should drive baseline compatibility fixtures. |
| Settings and vars: `Settings`, `CharSettings`, `GameSettings`, `Vars`, `UserVars` | Preserve | Settings capability scoped by script/character/game identity | Broad usage makes identity and persistence semantics a precursor contract. |
| Hooks and watchfor: `DownstreamHook.add/remove/list`, `UpstreamHook.add/remove/list`, `watchfor`, `Watchfor.new` | Preserve | Hook/event capability | Called by hundreds of scripts. Keep public API stable while separating runtime internals. |
| Spell API: `Spell.active`, `Spell.list`, `Spell.load`, message accessors, cast lock helpers | Preserve | Domain service capability | Smaller than global/script surfaces, but important and script-facing. Modernize after contracts are captured. |
| Movement helpers from `global_defs.rb` | Preserve | Command/game IO capability | Frequently used by scripts and should be stabilized with the broader global method contract work. |
| Less-common `Script.*`: `Script.self`, `Script.running`, `Script.hidden`, `Script.list`, `Script.index`, `Script.log`, `Script.db`, `Script.open_file`, trust-list helpers | Compat | Legacy facade over script manager / persistence capability | Used enough to keep working, but each needs review before being blessed as future API. |
| Upstream/unique/script-send helpers: `send_to_script`, `send_scripts`, `toggle_upstream`, `upstream_get`, `unique_get`, `unique_send_to_script`, `unique_waitfor` | Compat | IO broker capability | Existing scripts rely on them, but they should be brokered rather than exposing internal buffers directly. |
| Direct script state: `Script.current.vars`, `want_downstream`, `want_downstream_xml`, `want_upstream`, `want_script_output`, `silent`, `hidden`, `jump_label`, direct buffer access | Warn / Deprecate | Current-script state facade, then capability methods | Preserve legacy object shape at first. Avoid treating direct mutation as a long-term Box API. |
| Runtime plumbing methods: `Script.new_downstream`, `Script.new_downstream_xml`, `Script.new_upstream`, `Script.new_script_output`, `Script.namescript_incoming`, `Script.clear_exit_procs` | Warn / Deprecate | Internal runtime adapters | Low external usage and closely tied to script.rb internals. Keep compatibility until instrumentation proves safe. |
| Direct hook execution/introspection: `DownstreamHook.run`, `UpstreamHook.run`, `hook_sources` | Unsupported / Private | Internal event dispatcher | These look like implementation details. Do not document as public without a specific compatibility finding. |
| Reflection/eval against core internals: `eval`, `instance_eval`, `class_eval`, `module_eval`, `send`, `class_variable_get` on core classes | Unsupported / Private for Box strict mode | Permissioned or denied reflection capability | Legacy Ruby will still allow broad reflection. Ruby::Box strict mode should prevent private-core reach-through by default. |
| Direct storage: `File.open`, `File.read`, `File.write`, `SQLite3::Database.new`, `Sequel.sqlite`, `Zlib::GzipReader.open` | Compat in legacy; constrained in Box | Storage capability with explicit paths/permissions | Too common to break in legacy mode. Future isolated mode should replace ambient filesystem access with declared capability boundaries. |

## Compatibility Fixture Priorities

Build canary fixtures around observed high-use calls before changing
`script.rb`. The first fixture set should cover:

1. `Script.current`, script identity, `Script.run`, `Script.start`, `Script.kill`,
   `Script.running?`, `Script.exists?`.
2. Global IO and flow helpers: `echo`, `respond`, `put`, `fput`, `get`,
   `waitfor`, `match`, `matchwait`, `pause`.
3. Script lifecycle callbacks: `before_dying`, `undo_before_dying`, exit procs,
   pause/unpause behavior.
4. Settings and vars identity: `Settings`, `CharSettings`, `GameSettings`,
   `Vars`, `UserVars`.
5. Hook registration/removal/listing: downstream, upstream, and watchfor.
6. Direct current-script state as legacy behavior, especially
   `Script.current.vars` and downstream/upstream flags.

## Engineering Guidance

Phase 0 contract work should classify each preserved call by input, return,
side effect, error behavior, thread interaction, and persistence behavior. The
scanner output is enough to prioritize order, not enough to define contracts by
itself.

Compatibility shims should be boring and explicit. A future Ruby::Box runtime
should receive a curated capability object, while legacy scripts continue to see
the historical globals and class methods.

Instrumentation should be added before warning or changing behavior. For this
project, diagnostics should write to `Lich.log` and, when useful, display to
console/game screen with low-noise defaults.

Unknown or rare `Script.*`, `Spell.*`, hook, and direct-state calls should be
manually reviewed before being labeled unsupported. The matrix should prefer
temporary compatibility over accidental breakage.

## Next Matrix Artifacts

The next useful outputs are:

1. A raw token tier CSV derived from `script-corpus-api-usage.csv`.
2. A human summary of preserve/compat/warn/private counts by repo and support
   tier.
3. A fixture candidate list mapping high-value tokens to representative scripts.
4. A contract worksheet for preserve-tier APIs, starting with `Script.current`
   and lifecycle/IO helpers.
