# Corpus Summary

Status: summarized from local analysis.

The planning work used three local script corpora:

| Repository | Role |
| --- | --- |
| `elanthia-online/scripts` | Primary compatibility source. |
| `elanthia-online/dr-scripts` | Primary compatibility source. |
| `FarFigNewGut/lich_repo_mirror` | Legacy-risk source, not automatic design authority. |

## Inventory

| Repo | Files scanned | Date-signal files | Invalid UTF-8 files |
| --- | ---: | ---: | ---: |
| scripts | 359 | 167 | 0 |
| dr-scripts | 270 | 4 | 0 |
| lich_repo_mirror | 2291 | 445 | 3 |
| Total | 2920 | 616 | 3 |

Date signals are soft hints parsed from file headers and early comments. File
mtime was not useful because the repositories were freshly cloned.

Invalid UTF-8 was found only in the legacy mirror:

- `lib/defense_calc.lic`
- `lib/inquisition.lic`
- `lib/qrs.lic`

This matters because non-UTF-8 scripts can break the Lich application before
script runtime behavior is reached.

## API Usage Signals

Highest-use categories from the first scanner pass:

| Category | Files | Calls |
| --- | ---: | ---: |
| global IO | 2449 | 75307 |
| global flow | 2147 | 26502 |
| global movement | 1468 | 14318 |
| vars | 607 | 12786 |
| settings | 428 | 10299 |
| Script class methods | 761+ | 6865+ |
| lifecycle globals | 1123 | 4606 |
| reflection/eval | 499 | 3674 |
| hooks/watchfor | 482 | 1970 |
| script buffers/state | 204 | 1250 |
| storage direct | 225 | 834 |
| spell | 73 | 390 |

The corpus confirms that `script.rb` modernization is not isolated to
`script.rb`. It must preserve the surrounding public scripting environment.

## Raw Artifacts

Raw generated artifacts remain local during planning. Durable summaries can be
promoted here as reviewers request them.
