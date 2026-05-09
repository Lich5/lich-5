# script.rb Preserve-Tier Contract Worksheet

Status: draft, local-only.

Purpose: turn high-use Preserve-tier API names into implementation contracts
before `script.rb` extraction begins. This worksheet is grounded in the current
`stage/lich-5` implementation and the corpus fixture candidates.

## Source Files

| Surface | Source |
| --- | --- |
| Script lifecycle and identity | `stage/lich-5/lib/common/script.rb` |
| Global IO, flow, lifecycle helpers | `stage/lich-5/lib/global_defs.rb` |
| Settings | `stage/lich-5/lib/common/settings.rb` |
| Character/game settings | `stage/lich-5/lib/common/settings/charsettings.rb`, `stage/lich-5/lib/common/settings/gamesettings.rb` |
| User variables | `stage/lich-5/lib/common/uservars.rb`, `stage/lich-5/lib/common/vars.rb` |
| Hooks/watchfor | `stage/lich-5/lib/common/downstreamhook.rb`, `stage/lich-5/lib/common/upstreamhook.rb`, `stage/lich-5/lib/common/watchfor.rb` |

## Contract Fields

Each Preserve API should be locked with:

| Field | Meaning |
| --- | --- |
| Inputs | Accepted argument shapes and common legacy coercions. |
| Return | Value scripts can observe and may depend on. |
| Side effects | Buffers, client output, script state, thread state, persistence, logging. |
| Identity | How the call resolves `Script.current`, target script, character, game, or scope. |
| Error behavior | False/nil return, response text, exception, thread kill, or swallowed error. |
| Fixture source | Corpus scripts that can become canaries after minimized fixtures exist. |
| Open questions | Items to verify before modernization changes behavior. |

## Script Identity And Lifecycle

| API | Inputs | Return | Side effects | Identity | Error behavior | Fixture source | Open questions |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Script.current` | None | Current script object or `nil` | Sleeps while current script is paused unless `ignore_pause` | Finds a running script whose thread group contains `Thread.current` | None; returns `nil` outside script thread | `stage/scripts/scripts/eherbs.lic`, `eloot.lic`, `bigshot.lic` | Confirm pause wait behavior must remain inside `Script.current` rather than caller-level. |
| `Script.start` | `name`, optional args string/hash, options hash; or options hash with `:name` | Script object or `nil` | Resolves file, creates script object, starts thread, prints active/error messages | Script name resolved from `SCRIPT_DIR`, `custom`, extension variants, running list | Bad args/file/errors respond and return `nil` | `stage/scripts/scripts/tdusk.lic`, `bigshot.lic`, `autostart.lic` | Contract exact file resolution order and custom subdirectory semantics before extraction. |
| `Script.run` | Same as `Script.start` | Blocks until started script leaves running list; returns current sleep loop result/nil | Starts script, then waits | Same as `Script.start` | Same as `Script.start` | `stage/scripts/scripts/ebounty.lic`, `loot-be-gone.lic`, `mybounty.lic` | Confirm callers depend on blocking only, not return value. |
| `Script.running?` | Name/string | Boolean | None | Case-insensitive full-name match against running scripts | None observed | `stage/dr-scripts/trade.lic`, `stage/scripts/scripts/treim.lic`, `tdusk.lic` | Confirm regex interpolation behavior is legacy contract or should be escaped. |
| `Script.kill` | Name/string | `true` if target found, else `false` | Marks `killed_externally`, stores caller source, kills target script | Exact-name match first, then case-insensitive regex match | No user-facing error on miss | `stage/scripts/scripts/treim.lic`, `tdusk.lic`, `calibrate_creaturebar.lic` | Confirm partial/regex matching is intentional compatibility. |
| `Script.pause` | Optional name | Current script when self-pausing, `true`/`false` for named target | Sets target paused state | No arg targets `Script.current`; named target exact then case-insensitive regex | No current script can raise via nil `.pause` | Corpus uses `Script.pause`; minimized fixture needed | Decide whether nil-current behavior is preserved as exception or guarded later. |
| `Script.unpause` | Name/string | `true`/`false` | Clears target paused state | Exact paused target first, then case-insensitive regex | False on miss | Corpus uses `Script.unpause`; minimized fixture needed | Same partial/regex target question. |
| `Script.at_exit` / `before_dying` | Block | Script method result or `false` | Registers exit proc on current script | Requires `Script.current` | Responds error and returns `false` when no current script | Lifecycle fixture from synthetic script plus corpus | Confirm proc execution order and exception behavior during script kill. |
| `Script.exit!` / `abort!` | None | Usually exits current script; `false` if no current script | Invokes current script exit path | Requires `Script.current` | Responds error and returns `false` when no current script | Synthetic fixture | Confirm interaction with ensure/at_exit procs. |

## Global IO And Flow

| API | Inputs | Return | Side effects | Identity | Error behavior | Fixture source | Open questions |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `echo` | Any messages | `nil` | Prefixes script name and sends through `respond`; respects `no_echo` | Uses `Script.current`; labels unknown threads | No exception expected | `stage/dr-scripts/combat-trainer.lic`, `stage/scripts/scripts/repository.lic`, `uberfletch.lic` | Confirm empty `echo` behavior via `respond` is intentional. |
| `respond` | First message plus variadic messages; arrays flattened | No explicit return | Updates script-output buffer, `Buffer::SCRIPT_OUTPUT`, client/detachable client; mono/profanity escaping | Does not require current script | Rescues and prints exception/backtrace first line to stdout | `stage/scripts/scripts/memory_profiler.lic`, `resource.lic`, `gemtracker.lic` | Contract frontend escaping and `XMLData.safe_to_respond?` wait loop before IO broker extraction. |
| `put` | Variadic messages | Array from `each` or nil-ish script-observed value | Sends each message to `Game.puts` | No current script required | No local rescue | Corpus broad; minimized fixture needed | Determine if return from `messages.each` is relied on. |
| `fput` | Command plus optional wait patterns and `timeout:` | Matched line/string, matched wait token, or `false` | Clears buffer, sends command, waits/retries on wait/stun/web/typeahead patterns, may unshift line back | Requires `Script.current` | Responds false if no script; timeout echoes and returns false | Corpus broad; minimized fixture needed | Timeout default `60` is modern behavior; verify legacy expectations before touching. |
| `get` / `get?` | None | `script.gets` / `script.gets?` result | Consumes or peeks script downstream buffer depending script methods | Requires `Script.current` but currently calls directly | Nil current raises | Corpus broad; minimized fixture needed | Decide whether nil-current exception is contract. |
| `clear` | Optional ignored arg | Duplicate of previous downstream buffer, or `false` | Clears current script downstream buffer | Requires `Script.current` | Responds and returns `false` when no current script | Corpus broad; minimized fixture needed | Preserve duplicate-before-clear behavior. |
| `wait` | None | Next line or `false` | Clears current script buffer, then consumes one line | Requires `Script.current` | Responds and returns `false` when no current script | Corpus broad; minimized fixture needed | Confirm `wait` belongs with IO broker capability. |
| `waitfor` | Strings/arrays | Matching line, `false` for no strings/no current | Consumes lines until case-insensitive match; Wizard prompt special case | Requires `Script.current` | Responds false no current; echoes false no strings | Corpus broad; minimized fixture needed | Preserve regex construction from strings, including unescaped regex semantics. |
| `waitforre` | Regexp | Regexp match object or `false`/`nil` | Consumes lines until regexp matches | Requires `Script.current` | Responds false no current; echo/sleep/nil for non-Regexp | Corpus broad; minimized fixture needed | Document returned match object, not line. |
| `match` | Label/string pair; legacy multi-string branch | Usually nil when stacking; matched string for legacy branch | Adds label/string to current script match stack | Requires `Script.current` | Echo, kill thread, or false for no current/bad args | Corpus broad; minimized fixture needed | Clarify multi-string branch compatibility and match stack adapter shape. |
| `matchwait` | Optional strings | Matching line, jumps to label, or `false` | Consumes lines; with empty args uses match stack, clears stack, raises jump via `goto` | Requires `Script.current` | Responds and returns false when no current script | Corpus broad; minimized fixture needed | Critical Wizard compatibility path; fixture must include `goto`/`jump_label`. |

## Settings And Vars

| API | Inputs | Return | Side effects | Identity | Error behavior | Fixture source | Open questions |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `Settings[]` | Key | Value or `SettingsProxy` for containers | Reads cached or DB-backed script settings; safe-navigation state may change | Scope defaults to `XMLData.game:XMLData.name`; script defaults to `Script.current.name` | Nil key/missing value returns nil/proxy behavior, not exception | `stage/scripts/scripts/repository.lic`, `map.lic`, `localchat.lic` | Verify no-current-script behavior because default argument calls `Script.current.name`. |
| `Settings[]=` | Key, value | Original value via reset helper | Saves unwrapped value to DB/cache, may create nested containers | Same script/scope default | Logs and returns nil for invalid nested target | Same as above | Contract proxy mutation persistence before script identity refactor. |
| `CharSettings[]` / `[]=` | Key, optional value | Delegates to `Settings` | Character-scoped persistence | Scope is `"#{XMLData.game}:#{XMLData.name}"` | Delegated | Corpus broad; primary candidates in matrix | Confirm active scope is evaluated dynamically on each call. |
| `GameSettings[]` / `[]=` | Key, optional value | Delegates to `Settings` | Game-scoped persistence | Scope is `XMLData.game` | Delegated | Corpus lower but present | Same dynamic scope question. |
| `Vars[]` / `Vars[]=` | String, Symbol, or object key; value for setter | Getter returns stored object or nil; setter returns assigned value or deleted value semantics from Hash | Lazy-loads DB state on first access; nil assignment deletes key; keys normalized with `to_s` | Scope is `"#{XMLData.game}:#{XMLData.name}"`; not script-name scoped | Load errors respond with message/backtrace; SQLite busy retries | `stage/scripts/scripts/spa.lic`, `loot-be-gone.lic`, `vars.lic` | Preserve string/symbol equivalence and nil-delete behavior. |
| `Vars.method_missing` | Dynamic getter/setter method names; bracket operators | Getter value, setter assigned value, or nil | Same backing store as bracket access; setter ending `=` writes/deletes | Same character/game scope as `Vars[]` | No unknown-method failure for valid-looking names; invalid names governed by Ruby dispatch/respond checks | `stage/scripts/scripts/loot-be-gone.lic`, `eloot.lic`, `tdig.lic` | Confirm scripts rely on `respond_to?` behavior for arbitrary variable names. |
| `Vars.list` | None | Duplicate Hash of all variables with string keys | Lazy-loads DB state | Same character/game scope | Load errors handled by loader | `stage/scripts/scripts/vars.lic` plus synthetic fixture | Preserve duplicate return so callers cannot replace backing hash accidentally. |
| `Vars.save` | None | `nil` | Saves to DB only when MD5 of `@@vars.to_s` changes; background thread also saves every 300 seconds | Same character/game scope | SQLite busy retries; background save logs/responds StandardError | Synthetic fixture | Contract immediate save and autosave thread separately. |
| `UserVars[]` / `UserVars[]=` | Same as `Vars` | Delegates to `Vars` | Same as `Vars` | Same as `Vars` | Same as `Vars` | `stage/scripts/scripts/isquelch.lic`, `tdusk.lic` | Treat as legacy public alias over `Vars`, not a separate store. |
| `UserVars.method_missing` | Dynamic getter/setter method names | Delegates to `Vars.method_missing` | Same as `Vars` | Same as `Vars` | Same as `Vars` | `stage/scripts/scripts/ForgeMaster.lic`, `tfish.lic`, `tdusk.lic` | Very high corpus usage; keep syntax stable even if storage capability changes underneath. |
| `UserVars.change` | Name, value, ignored legacy third arg | Assigned value | Writes through `Vars[name] = value` | Same as `Vars` | Same as `Vars` | Corpus and synthetic fixture | Preserve ignored third parameter. |
| `UserVars.add` | Name, value, ignored legacy third arg | Updated comma-separated string | Reads current value; writes `value.to_s` if empty/nil; otherwise appends using `', '` separator | Same as `Vars` | Non-string current values can behave via `empty?`/`to_s`; do not smooth without fixture | Corpus and synthetic fixture | Preserve comma-space list behavior and odd current-value handling. |
| `UserVars.delete` | Name, ignored legacy second arg | Nil/delete result through `Vars[name] = nil` | Deletes normalized key | Same as `Vars` | Same as `Vars` | Corpus and synthetic fixture | Preserve ignored second parameter. |
| `UserVars.list_global` / `list_char` | None | Empty array for global; duplicate Hash for char | `list_char` delegates to `Vars.list`; globals unsupported | Same as `Vars` for char | Same as `Vars` for char | Synthetic fixture | Keep `list_global` empty-array compatibility. |

## Hooks And Watchfor

| API | Inputs | Return | Side effects | Identity | Error behavior | Fixture source | Open questions |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `DownstreamHook.add` | Name, Proc | Proc/action assignment result or `false` | Stores hook and source script name | Source is `Script.current.name || "Unknown"` | Echo and return false if action is not Proc | `stage/scripts/scripts/infomon.lic`, `madwarrior.lic`, `alchemy.lic` | If no current script, current implementation may raise before `|| "Unknown"`; verify fixture. |
| `DownstreamHook.remove` | Name | Removed proc or nil | Removes hook and source entry | Name key only | No error | `stage/scripts/scripts/madwarrior.lic`, `infomon.lic`, `treim.lic` | Preserve return value from `Hash#delete`. |
| `DownstreamHook.list` | None | Duplicate array of hook names | None | Global hook registry | None | Corpus examples above | Confirm ordering expectations, if any. |
| `UpstreamHook.add` | Name, Proc | Proc/action assignment result or `false` | Stores hook and source script name | Source is `Script.current.name || "Unknown"` | Echo and return false if action is not Proc | `stage/dr-scripts/automap.lic`, `stage/scripts/scripts/0net.lic`, `BlackArts.lic` | Same no-current-script question. |
| `UpstreamHook.remove` | Name | Removed proc or nil | Removes hook and source entry | Name key only | No error | Corpus lower but present | Preserve return value from `Hash#delete`. |
| `UpstreamHook.list` | None | Duplicate array of hook names | None | Global hook registry | None | Corpus lower but present | Confirm ordering expectations. |
| `Watchfor.new` / `watchfor` | String or Regexp, Proc or block | Constructor result; effectively registers trigger or returns nil early | Adds trigger/block to current script `watchfor` hash | Requires `Script.current` | Echo and return nil for bad trigger/action; nil outside script | Corpus lower; synthetic fixture needed | `Watchfor.clear` references `script` without defining it; review before relying on clear. |

## Immediate Fixture Set

Build minimized fixtures first, then attach corpus canaries:

1. Script identity/lifecycle: current script detection, start/run blocking,
   kill/pause/unpause, at_exit callback.
2. IO/flow: downstream buffer clear/get/waitfor/match/matchwait, script output
   through `respond`, and game command through `put`/`fput`.
3. Settings identity: Settings, CharSettings, GameSettings, Vars, UserVars under
   current script and character/game scope, including Vars/UserVars key
   normalization and nil-delete behavior.
4. Hooks: add/remove/list for upstream/downstream plus watchfor trigger
   execution in a script thread.
5. Wizard compatibility: `match`, `matchwait`, `goto`, `jump_label`, and label
   error path.

## Highest-Risk Open Questions

1. Several APIs rely on `Script.current` and either return false or raise when
   called outside a script thread. Preserve exact behavior until fixtures say
   otherwise.
2. Script-name matching often uses regex interpolation and partial matching.
   This may be compatibility-significant even where it is unsafe-looking.
3. Settings default arguments call `Script.current.name`; no-current behavior
   needs explicit fixtures before changing settings identity paths.
4. Hook source recording appears intended to tolerate unknown scripts, but the
   current expression may not actually do so if `Script.current` is nil.
5. Wizard label flow is central to `jump_label`; do not refactor match stack or
   label execution without a dedicated compatibility fixture.
6. `Vars`/`UserVars` are character/game scoped rather than script scoped. A
   future storage capability should preserve that legacy scope while making the
   boundary explicit.
