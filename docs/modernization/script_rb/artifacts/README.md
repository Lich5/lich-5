# script.rb Analysis Artifacts

Generated: 2026-05-08

These files are supporting evidence for the `script.rb` modernization effort.
They are not runtime inputs and do not change Lich behavior.

## Source Corpora

The local scan used these freshly cloned repositories:

- `elanthia-online/scripts`
- `elanthia-online/dr-scripts`
- `FarFigNewGut/lich_repo_mirror`

The generated data is intended to help reviewers audit the summaries, API
tiering, and fixture recommendations used by the planning docs.

## Raw CSVs

- [script-corpus-file-inventory.csv](raw/script-corpus-file-inventory.csv):
  file inventory, age/date signals, and encoding observations.
- [script-corpus-api-usage.csv](raw/script-corpus-api-usage.csv):
  detected script API usage across scanned files.
- [script-api-token-tier-matrix.csv](raw/script-api-token-tier-matrix.csv):
  API token tiering used to guide Preserve/Warn/Review decisions.
- [script-fixture-candidates.csv](raw/script-fixture-candidates.csv):
  candidate scripts for future compatibility fixtures.

## Summaries

- [script-corpus-risk-summary.md](summaries/script-corpus-risk-summary.md)
- [script-api-tier-summary.md](summaries/script-api-tier-summary.md)
- [script-fixture-candidates.md](summaries/script-fixture-candidates.md)
- [script-preserve-contract-worksheet.md](summaries/script-preserve-contract-worksheet.md)
- [script-compatibility-fixture-plan.md](summaries/script-compatibility-fixture-plan.md)

## Tools

The scripts under [tools](tools/) generated the raw and summary artifacts from
local clones. They are included for auditability and repeatability, not as
installed project tooling.

## Known Notes

- File mtimes from fresh clones were not useful for script age analysis.
- Header/comment date signals were treated as soft hints only.
- The legacy mirror included invalid UTF-8 files; those findings are captured in
  the generated inventory and summaries.
