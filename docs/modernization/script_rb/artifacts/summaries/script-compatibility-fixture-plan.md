# script.rb Compatibility Fixture Plan

Status: draft, local-only.

This plan turns the Preserve-tier contract worksheet into the first behavior
specification PR. It is intentionally narrow: characterize current behavior
before `script.rb` extraction, do not improve behavior yet.

## Fixture Strategy

Use two fixture types:

| Type | Purpose |
| --- | --- |
| Minimized fixtures | Small synthetic scripts/spec helpers that prove exact behavior. |
| Corpus canaries | Real script examples from `stage/scripts`, `stage/dr-scripts`, and legacy-risk mirror scripts used for compatibility sampling. |

The first spec PR should prefer minimized fixtures. Corpus canaries should be
added where they expose behavior that is hard to synthesize cleanly.

## Fixture Groups

### 1. Script Identity And Lifecycle

Target APIs:

`Script.current`, `Script.start`, `Script.run`, `Script.running?`,
`Script.kill`, `Script.pause`, `Script.unpause`, `Script.at_exit`,
`before_dying`, `undo_before_dying`, `Script.exit!`.

Expected behavior to lock:

- `Script.current` resolves by thread group and returns nil outside script
  threads.
- `Script.current` waits while the script is paused unless `ignore_pause` is
  true.
- `Script.start` returns a script object or nil and emits existing active/error
  messages.
- `Script.run` starts then blocks until the target script leaves the running
  list.
- name matching remains exact-first, then legacy case-insensitive/regex-like
  matching.
- exit callbacks run through the current script lifecycle.

Corpus canaries:

- `stage/scripts/scripts/eherbs.lic`
- `stage/scripts/scripts/tdusk.lic`
- `stage/scripts/scripts/treim.lic`
- `stage/dr-scripts/trade.lic`

Must not change:

- nil/false/exception behavior for calls outside script context until explicitly
  reviewed.
- partial/regex target matching.
- active/error response wording without a deliberate migration note.

### 2. IO, Buffer, And Flow Helpers

Target APIs:

`echo`, `respond`, `put`, `fput`, `get`, `get?`, `clear`, `wait`, `waitfor`,
`waitforre`, `match`, `matchwait`.

Expected behavior to lock:

- `echo` prefixes messages with current script identity and respects `no_echo`.
- `respond` updates script output buffers and frontend output paths.
- `put` delegates to `Game.puts`.
- `clear` returns a duplicate of the downstream buffer before clearing it.
- `wait` clears then consumes one downstream line.
- `waitfor` builds case-insensitive matching from supplied strings.
- `waitforre` returns the Regexp match object, not the line.
- `match` populates the match stack; `matchwait` consumes lines and jumps via
  `goto` when no strings are passed.
- `fput` clears, sends, waits, retries selected wait/stun/web/typeahead states,
  unshifts lines back, and returns either a line, matched wait token, or false.

Corpus canaries:

- `stage/dr-scripts/combat-trainer.lic`
- `stage/scripts/scripts/repository.lic`
- `stage/scripts/scripts/memory_profiler.lic`
- `stage/scripts/scripts/resource.lic`

Must not change:

- buffer ordering and unshift behavior.
- unescaped legacy regex matching semantics.
- `fput` timeout behavior without an explicit review note.

### 3. Settings, Vars, And UserVars

Target APIs:

`Settings[]`, `Settings[]=`, `CharSettings[]`, `CharSettings[]=`,
`GameSettings[]`, `GameSettings[]=`, `Vars[]`, `Vars[]=`, `Vars.list`,
`Vars.save`, `UserVars[]`, `UserVars[]=`, `UserVars.change`, `UserVars.add`,
`UserVars.delete`, `UserVars.list_global`, `UserVars.list_char`.

Expected behavior to lock:

- `Settings` default access is script-name scoped and uses `script_auto_settings`.
- `CharSettings` uses character scope, `GameSettings` uses game scope, and both
  delegate to `Settings`.
- `Settings` also supports fixed/non-current namespaces through `script_name:`;
  `InstanceSettings` demonstrates this with `script_name: "core"`.
- `Vars` and `UserVars` are separate from `Settings` today: `Vars` reads/writes
  the `uservars` table directly through `Lich.db`, while `UserVars` delegates
  to `Vars`.
- `Vars` keys normalize with `to_s`; nil assignment deletes.
- `Vars.list` and `UserVars.list_char` return duplicate hashes.
- `UserVars.list_global` returns an empty array.
- `UserVars.change`, `add`, and `delete` preserve ignored legacy parameters.

Corpus canaries:

- `stage/scripts/scripts/spa.lic`
- `stage/scripts/scripts/loot-be-gone.lic`
- `stage/scripts/scripts/vars.lic`
- `stage/scripts/scripts/ForgeMaster.lic`
- `stage/scripts/scripts/tfish.lic`

Must not change:

- the separate `script_auto_settings` and `uservars` persistence paths.
- string/symbol key equivalence.
- nil-delete behavior.
- comma-space behavior in `UserVars.add`.

### 4. Hooks And Watchfor

Target APIs:

`DownstreamHook.add`, `DownstreamHook.remove`, `DownstreamHook.list`,
`UpstreamHook.add`, `UpstreamHook.remove`, `UpstreamHook.list`,
`Watchfor.new`, `watchfor`.

Expected behavior to lock:

- hook add requires a Proc and returns false after echoing when invalid.
- hook add records the source script name.
- hook remove deletes both hook and source entries and returns Hash delete
  semantics.
- hook list returns a duplicate array of names.
- watchfor accepts String or Regexp triggers and Proc/block actions.
- watchfor stores triggers on the current script.

Corpus canaries:

- `stage/scripts/scripts/infomon.lic`
- `stage/scripts/scripts/madwarrior.lic`
- `stage/scripts/scripts/alchemy.lic`
- `stage/dr-scripts/automap.lic`

Must not change:

- invalid Proc behavior.
- hook removal return semantics.
- watchfor registration on the script object.

### 5. Wizard Label And Legacy State

Target APIs:

`match`, `matchwait`, `goto`, `Script.current.jump_label`,
`Script.current.want_downstream`, `Script.current.want_downstream_xml`,
`Script.current.want_upstream`, `Script.current.want_script_output`,
`Script.current.vars`, `Script.current.silent`, `Script.current.hidden`.

Expected behavior to lock:

- `goto` sets `Script.current.jump_label` and raises the script jump sentinel.
- `matchwait` with an empty argument list uses the match stack and label jump
  flow.
- missing labels follow the existing label-error path.
- direct state-field access remains valid legacy behavior.
- downstream XML and downstream text flags control which stream reaches a script.

Corpus canaries:

- `stage/scripts/scripts/tags.lic`
- `stage/scripts/scripts/looploot.lic`
- `stage/scripts/scripts/spa.lic`
- `stage/scripts/scripts/log.lic`
- `stage/scripts/scripts/logxml.lic`

Must not change:

- Wizard label compatibility.
- direct field read/write syntax.
- `_xml = true` and `want_downstream = false` stream selection behavior.

## First Spec PR Shape

Recommended initial files:

- `stage/lich-5/spec/lib/common/script_identity_spec.rb`
- `stage/lich-5/spec/lib/common/script_io_flow_spec.rb`
- `stage/lich-5/spec/lib/common/script_settings_vars_spec.rb`
- `stage/lich-5/spec/lib/common/script_hooks_watchfor_spec.rb`
- `stage/lich-5/spec/lib/common/script_wizard_compat_spec.rb`
- `stage/lich-5/spec/support/script_runtime_harness.rb`
- `stage/lich-5/spec/fixtures/scripts/`

The harness should isolate global state, fake frontend/game IO, and avoid
starting real game sessions.

## Review Gate

Before production refactors begin, reviewers should agree that the specs cover:

- current-thread script identity,
- script lifecycle start/run/kill/pause,
- downstream/upstream/script-output buffers,
- Settings versus Vars/UserVars storage boundaries,
- hook/watchfor registration,
- Wizard jump labels,
- legacy direct script state fields.
