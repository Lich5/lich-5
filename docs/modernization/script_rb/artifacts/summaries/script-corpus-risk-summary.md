# Script Corpus Risk Summary

Date: 2026-05-09
Scope: `stage/scripts`, `stage/dr-scripts`, `stage/lich_repo_mirror`

## Purpose

This is the first lean summary from the local corpus inventory and API usage scanners. It is intended to guide `script.rb` modernization planning, especially compatibility contracts and future Ruby::Box capability shims.

Raw inputs:

- `results_codex/architecture/script_rb/raw/script-corpus-file-inventory.csv`
- `results_codex/architecture/script_rb/raw/script-corpus-api-usage.csv`

## Corpus Scale

| Repository | Support tier | Script-like files | Date signal rows | Invalid UTF-8 |
| --- | --- | ---: | ---: | ---: |
| `stage/scripts` | primary | 359 | 167 (46.52%) | 0 |
| `stage/dr-scripts` | primary | 270 | 4 (1.48%) | 0 |
| `stage/lich_repo_mirror` | legacy-risk | 2,291 | 445 (19.42%) | 3 |
| Total | mixed | 2,920 | 616 (21.10%) | 3 |

## Date And Age Signals

File modification time is not useful for age triage. Every repository reports a single clone/mirror date in `mtime_utc`, so it reflects local checkout timing rather than script publication or maintenance age.

The `date_signals` and `latest_date_signal` fields are derived from date-looking strings in the first 80 lines of each script. These are useful hints, but not proof of publication date. They may come from headers, changelog comments, version notes, or early executable text.

For `lich_repo_mirror`, age filtering should use `latest_date_signal` only as a soft triage signal. If no credible date signal exists, mirror usage should be capped to representative legacy patterns that map to known script-runtime APIs.

## Encoding Risk

Three scripts contain invalid UTF-8 byte sequences. This is a runtime stability risk independent of modernization because such files may fail during Lich script loading or file reads.

| Repository | Script | Invalid byte samples |
| --- | --- | --- |
| `lich_repo_mirror` | `lib/defense_calc.lic` | `F7`, `D7` |
| `lich_repo_mirror` | `lib/inquisition.lic` | `92` |
| `lich_repo_mirror` | `lib/qrs.lic` | `92`, `96`, `93`, `94` |

This should become a standing scanner by-product and eventually a small stability report.

## API Usage Signals

The usage scanner is regex-based and intentionally broad because the corpus includes `.lic`, `.cmd`, `.wiz`, and legacy idioms. Counts should be treated as prioritization signals, not exact AST-level truth.

| Category | Files | Token rows | Call-like matches |
| --- | ---: | ---: | ---: |
| `global_io` | 2,449 | 5,457 | 75,307 |
| `global_flow` | 2,147 | 4,622 | 26,502 |
| `global_movement` | 1,468 | 2,881 | 14,318 |
| `vars` | 607 | 667 | 12,786 |
| `settings` | 428 | 609 | 10,299 |
| `script_class_other` | 796 | 1,517 | 7,217 |
| `script_class` | 761 | 1,347 | 6,865 |
| `global_lifecycle` | 1,123 | 1,676 | 4,606 |
| `reflection_eval` | 499 | 587 | 3,674 |
| `hooks_watchfor` | 482 | 1,111 | 1,970 |
| `script_buffers_state` | 204 | 264 | 1,250 |
| `storage_direct` | 225 | 299 | 834 |
| `spell` | 73 | 146 | 390 |
| `exec_script` | 7 | 9 | 21 |

## Highest-Risk Surfaces

`global_defs.rb` remains the largest compatibility surface. `global_io`, `global_flow`, `global_movement`, and `global_lifecycle` dominate usage, which supports treating global helper behavior as Phase 0 contract work before deeper `script.rb` movement.

`Script.current` and lifecycle methods are central. Top observed known `Script.*` tokens:

| Token | Files | Matches |
| --- | ---: | ---: |
| `Script.run` | 356 | 2,495 |
| `Script.current` | 246 | 2,092 |
| `Script.running` | 255 | 854 |
| `Script.self` | 77 | 350 |
| `Script.kill` | 83 | 231 |
| `Script.start` | 90 | 214 |
| `Script.pause` | 77 | 165 |
| `Script.log` | 12 | 147 |
| `Script.unpause` | 54 | 83 |
| `Script.hidden` | 29 | 67 |

`Settings` and `Vars` usage is broad enough that script identity and persistence scope must be contract-locked before Ruby::Box capability modeling.

Hooks and watchfor appear in hundreds of files. Their source attribution, callback behavior, and cleanup semantics should be treated as IO broker boundary contracts.

Direct script buffer/state usage appears in 204 files. This is a strong signal that compatibility wrappers must preserve legacy object shape while future boxed execution exposes a narrower capability surface.

`reflection_eval` appears widely enough to be tracked as a Ruby::Box policy concern. It should not block the first `script.rb` modernization work, but boxed execution cannot treat eval/reflection as an afterthought.

## First-Pass Interpretation

The corpus supports the current sequencing:

1. Contract-lock `global_defs.rb`, settings identity, hooks/watchfor, and baseline `script.rb` behavior.
2. Use the primary repos as direct compatibility signals.
3. Use `lich_repo_mirror` as legacy-risk input, especially for canary candidates and unsupported/private-internal patterns.
4. Keep Ruby::Box work behind explicit capability contracts and migration controls.

The next useful artifact is an API tier summary that maps observed categories and high-frequency tokens to `preserve`, `compat`, `warn/deprecate`, or `unsupported`.
