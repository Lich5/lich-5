# script.rb Fixture Candidate List

Status: draft, local-only.

This list identifies representative scripts for compatibility canaries. It
is generated from `raw/script-corpus-api-usage.csv` and prefers primary
repositories before legacy mirror examples.

## Focus Summary

| focus | tokens_with_candidates | primary_candidates | legacy_candidates |
| --- | --- | --- | --- |
| script_identity_lifecycle | 10 | 30 | 0 |
| global_io_flow | 12 | 36 | 0 |
| settings_vars_identity | 10 | 28 | 2 |
| hooks_watchfor | 6 | 15 | 2 |
| legacy_script_state | 9 | 23 | 1 |
| storage_capability | 7 | 19 | 2 |
| reflection_box_policy | 7 | 18 | 3 |

## Primary Candidate Examples

| focus | token | initial_tier | repo | path | count | first_line |
| --- | --- | --- | --- | --- | --- | --- |
| script_identity_lifecycle | Script.current | Preserve | scripts | stage/scripts/scripts/eherbs.lic | 120 | 1152 |
| script_identity_lifecycle | Script.current | Preserve | scripts | stage/scripts/scripts/eloot.lic | 61 | 134 |
| script_identity_lifecycle | Script.current | Preserve | scripts | stage/scripts/scripts/bigshot.lic | 56 | 371 |
| script_identity_lifecycle | Script.run | Preserve | scripts | stage/scripts/scripts/ebounty.lic | 19 | 382 |
| script_identity_lifecycle | Script.run | Preserve | scripts | stage/scripts/scripts/loot-be-gone.lic | 16 | 885 |
| script_identity_lifecycle | Script.run | Preserve | scripts | stage/scripts/scripts/mybounty.lic | 15 | 214 |
| global_io_flow | echo | Preserve | dr-scripts | stage/dr-scripts/combat-trainer.lic | 400 | 8 |
| global_io_flow | echo | Preserve | scripts | stage/scripts/scripts/repository.lic | 182 | 174 |
| global_io_flow | echo | Preserve | scripts | stage/scripts/scripts/uberfletch.lic | 137 | 332 |
| global_io_flow | respond | Preserve | scripts | stage/scripts/scripts/memory_profiler.lic | 804 | 322 |
| global_io_flow | respond | Preserve | scripts | stage/scripts/scripts/resource.lic | 288 | 453 |
| global_io_flow | respond | Preserve | scripts | stage/scripts/scripts/gemtracker.lic | 224 | 275 |
| settings_vars_identity | Settings[ | Preserve | scripts | stage/scripts/scripts/repository.lic | 73 | 1056 |
| settings_vars_identity | Settings[ | Preserve | scripts | stage/scripts/scripts/map.lic | 41 | 801 |
| settings_vars_identity | Settings[ | Preserve | scripts | stage/scripts/scripts/localchat.lic | 33 | 86 |
| settings_vars_identity | Settings. | Preserve | scripts | stage/scripts/scripts/ewander.lic | 26 | 197 |
| settings_vars_identity | Settings. | Preserve | scripts | stage/scripts/scripts/localchat.lic | 11 | 54 |
| settings_vars_identity | Settings. | Preserve | scripts | stage/scripts/scripts/sellunder.lic | 7 | 163 |
| hooks_watchfor | DownstreamHook.add | Preserve | scripts | stage/scripts/scripts/infomon.lic | 11 | 148 |
| hooks_watchfor | DownstreamHook.add | Preserve | scripts | stage/scripts/scripts/madwarrior.lic | 7 | 593 |
| hooks_watchfor | DownstreamHook.add | Preserve | scripts | stage/scripts/scripts/alchemy.lic | 5 | 221 |
| hooks_watchfor | DownstreamHook.remove | Preserve | scripts | stage/scripts/scripts/madwarrior.lic | 16 | 579 |
| hooks_watchfor | DownstreamHook.remove | Preserve | scripts | stage/scripts/scripts/infomon.lic | 11 | 137 |
| hooks_watchfor | DownstreamHook.remove | Preserve | scripts | stage/scripts/scripts/treim.lic | 7 | 491 |
| legacy_script_state | Script.current.vars | Warn / Deprecate | scripts | stage/scripts/scripts/eherbs.lic | 74 | 1301 |
| legacy_script_state | Script.current.vars | Warn / Deprecate | scripts | stage/scripts/scripts/egemhoarder.lic | 43 | 78 |
| legacy_script_state | Script.current.vars | Warn / Deprecate | scripts | stage/scripts/scripts/spa.lic | 40 | 82 |
| legacy_script_state | Script.current.want_downstream | Warn / Deprecate | scripts | stage/scripts/scripts/tags.lic | 6 | 258 |
| legacy_script_state | Script.current.want_downstream | Warn / Deprecate | scripts | stage/scripts/scripts/BlackArts.lic | 3 | 4351 |
| legacy_script_state | Script.current.want_downstream | Warn / Deprecate | scripts | stage/scripts/scripts/crits.lic | 3 | 39 |
| storage_capability | File.open | Compat in legacy; constrained in Box | scripts | stage/scripts/scripts/lich5-update.lic | 15 | 27 |
| storage_capability | File.open | Compat in legacy; constrained in Box | scripts | stage/scripts/scripts/repository.lic | 13 | 1052 |
| storage_capability | File.open | Compat in legacy; constrained in Box | dr-scripts | stage/dr-scripts/download-prime-map.lic | 11 | 112 |
| storage_capability | File.read | Compat in legacy; constrained in Box | scripts | stage/scripts/scripts/bodega.lic | 6 | 489 |
| storage_capability | File.read | Compat in legacy; constrained in Box | scripts | stage/scripts/scripts/cartograph.lic | 3 | 162 |
| storage_capability | File.read | Compat in legacy; constrained in Box | scripts | stage/scripts/scripts/jinx.lic | 3 | 304 |
| reflection_box_policy | eval | Unsupported / Private for Box strict mode | scripts | stage/scripts/scripts/burstcalc.lic | 24 | 90 |
| reflection_box_policy | eval | Unsupported / Private for Box strict mode | dr-scripts | stage/dr-scripts/trigger-watcher.lic | 17 | 39 |
| reflection_box_policy | eval | Unsupported / Private for Box strict mode | scripts | stage/scripts/scripts/bigshot.lic | 5 | 48 |
| reflection_box_policy | instance_eval | Unsupported / Private for Box strict mode | scripts | stage/scripts/scripts/slop-lib.lic | 2 | 163 |
| reflection_box_policy | instance_eval | Unsupported / Private for Box strict mode | scripts | stage/scripts/lib/migration/change-set.rb | 1 | 21 |
| reflection_box_policy | instance_eval | Unsupported / Private for Box strict mode | scripts | stage/scripts/lib/migration/migrator.rb | 1 | 22 |

## Use

Start with synthetic minimized fixtures for exact contracts, then use these
corpus candidates as canaries. Mirror-only candidates should inform legacy
risk, not define new architecture by themselves.

Full candidate data is available in
`raw/script-fixture-candidates.csv`.
