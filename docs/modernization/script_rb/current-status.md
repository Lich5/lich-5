# script.rb Current Status

Last updated: 2026-05-09

## Summary

The project is in planning, corpus analysis, and initial characterization. No
production `script.rb` refactor has started.

## Completed Locally

- Created local corpus inventory and API usage matrices from public script
  corpora.
- Summarized API tiering and compatibility fixture candidates.
- Identified invalid UTF-8 scripts in the legacy corpus mirror.
- Drafted human and engineer modernization plans.
- Opened the first planning docs PR.
- Opened the first characterization specs PR.

## Active PRs

- [Lich5/lich-5#2](https://github.com/Lich5/lich-5/pull/2): planning docs.
- [Lich5/lich-5#3](https://github.com/Lich5/lich-5/pull/3): characterization
  specs.
- [elanthia-online/lich-5#1349](https://github.com/elanthia-online/lich-5/pull/1349):
  accidental upstream view of the characterization specs PR, retained
  temporarily for visibility.

## Current Decision Points

- Whether to merge the planning docs PR as the stable human reference.
- Whether to merge the characterization specs PR as the first hard guardrail.
- Which corpus-derived scripts should become canary fixtures.
- Which future checks should be invariant, drift signal, or exploratory.
- How and when to promote selected Lich5 work back to `elanthia-online/lich-5`.

## Not Started

- Production refactor of `lib/common/script.rb`.
- `global_defs.rb` modernization.
- `spell.rb` modernization.
- Ruby::Box implementation work.
- Corpus fixture execution in CI.
