# API Contract Summary

Status: planning and review.

This is a human summary of the first API tiering pass. It is not a final
deprecation policy.

## Tiers

| Tier | Meaning |
| --- | --- |
| Preserve | Public script API. Behavior should be characterized and preserved. |
| Compat | Keep working for legacy scripts, but review before treating as future API. |
| Warn / Deprecate | Keep initially; avoid building new architecture around this shape. |
| Unsupported / Private | Do not document as public contract unless compatibility findings require it. |

## Preserve First

Preserve-tier APIs include:

- core IO and flow helpers: `echo`, `respond`, `put`, `fput`, `get`, `wait`,
  `waitfor`, `waitforre`, `match`, `matchwait`, `clear`, `pause`;
- lifecycle helpers: `start_script`, `force_start_script`, `stop_script`,
  `pause_script`, `unpause_script`, `before_dying`, `undo_before_dying`;
- common `Script.*` calls: `Script.current`, `Script.run`, `Script.start`,
  `Script.running?`, `Script.exists?`, `Script.kill`, `Script.pause`,
  `Script.unpause`, `Script.paused?`, `Script.at_exit`, `Script.exit!`;
- settings and variables: `Settings`, `CharSettings`, `GameSettings`, `Vars`,
  `UserVars`;
- hooks and watchfor registration;
- heavily used `global_defs.rb` movement helpers;
- common `Spell` accessors.

## Legacy Field API

Direct script state fields are compatibility-sensitive:

- `Script.current.vars`
- `Script.current.want_downstream`
- `Script.current.want_downstream_xml`
- `Script.current.want_upstream`
- `Script.current.want_script_output`
- `Script.current.silent`
- `Script.current.hidden`
- `Script.current.jump_label`

These are classified as Warn / Deprecate for architecture posture, not removal.
Existing scripts must keep working. The desired future implementation is:

1. keep the legacy syntax,
2. route setters/getters through a runtime facade,
3. expose cleaner capabilities to any future isolated runtime.

For example, `Script.current.want_downstream_xml = true` should remain valid,
but its setter can eventually update runtime subscription state instead of being
only raw instance-variable mutation.

## Settings Versus Vars/UserVars

Current state:

- `Settings` persists through `script_auto_settings`, keyed by `script` and
  `scope`.
- `Vars` persists through `uservars`, keyed by `scope`.
- `UserVars` delegates to `Vars`.

`Settings` now supports fixed/non-current namespaces through `script_name:`.
`InstanceSettings` uses that pattern with `script_name: "core"`.

That does not make `Vars` and `UserVars` wrappers over `Settings` today. Their
separate table means any consolidation would be a migration project.

## Future Runtime Capabilities

The modernization should prepare these capability boundaries:

- script lifecycle,
- current-script identity and state,
- game/client IO,
- settings and storage,
- hooks and events,
- spell/domain services.

This is the path toward possible Ruby::Box-style isolation: boxed scripts should
receive explicit capabilities, while legacy scripts continue through existing
public API shapes.
