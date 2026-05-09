# script.rb Modernization Checklist

Last updated: 2026-05-09

## Project Setup

- [x] Establish alpha work area in `stage/lich-5`.
  - Completed: 2026-05-08
- [x] Keep local artifacts under `results_codex/architecture/script_rb`.
  - Completed: 2026-05-08
- [x] Confirm shared branch behavior for fork-local and upstream PRs.
  - Completed: 2026-05-09
  - PRs: [Lich5/lich-5#3](https://github.com/Lich5/lich-5/pull/3), [elanthia-online/lich-5#1349](https://github.com/elanthia-online/lich-5/pull/1349)
- [ ] Close or retire accidental upstream PR when appropriate.
  - PR: [elanthia-online/lich-5#1349](https://github.com/elanthia-online/lich-5/pull/1349)

## Planning

- [x] Draft modernization plan for `script.rb`.
  - Completed: 2026-05-08
- [x] Draft engineer phase plan for implementation.
  - Completed: 2026-05-08
- [x] Publish docs/review package to fork.
  - Completed: 2026-05-08
  - PR: [Lich5/lich-5#2](https://github.com/Lich5/lich-5/pull/2)
- [ ] Review and merge/preserve planning docs.
  - PR: [Lich5/lich-5#2](https://github.com/Lich5/lich-5/pull/2)

## Corpus And Contracts

- [x] Inventory script corpora.
  - Completed: 2026-05-08
- [x] Generate raw API usage matrix.
  - Completed: 2026-05-08
- [x] Generate API tier summary.
  - Completed: 2026-05-08
- [x] Generate fixture candidate summary.
  - Completed: 2026-05-08
- [x] Note invalid UTF-8 script findings.
  - Completed: 2026-05-08
- [ ] Decide fixture promotion set.
- [ ] Decide public contract boundaries for first modernization pass.

## Characterization Specs

- [x] Add `script.rb` IO and flow characterization specs.
  - Completed: 2026-05-08
  - PRs: [Lich5/lich-5#3](https://github.com/Lich5/lich-5/pull/3), [elanthia-online/lich-5#1349](https://github.com/elanthia-online/lich-5/pull/1349)
- [x] Add hook/watchfor characterization specs.
  - Completed: 2026-05-08
  - PRs: [Lich5/lich-5#3](https://github.com/Lich5/lich-5/pull/3), [elanthia-online/lich-5#1349](https://github.com/elanthia-online/lich-5/pull/1349)
- [x] Add Settings/Vars/UserVars characterization specs.
  - Completed: 2026-05-08
  - PRs: [Lich5/lich-5#3](https://github.com/Lich5/lich-5/pull/3), [elanthia-online/lich-5#1349](https://github.com/elanthia-online/lich-5/pull/1349)
- [x] Address reviewer test-isolation findings.
  - Completed: 2026-05-09
  - PRs: [Lich5/lich-5#3](https://github.com/Lich5/lich-5/pull/3), [elanthia-online/lich-5#1349](https://github.com/elanthia-online/lich-5/pull/1349)
- [ ] Review and merge specs PR.
  - PRs: [Lich5/lich-5#3](https://github.com/Lich5/lich-5/pull/3), [elanthia-online/lich-5#1349](https://github.com/elanthia-online/lich-5/pull/1349)

## Precursor Modernization

- [ ] Decide `global_defs.rb` modernization scope.
- [ ] Decide `spell.rb` modernization scope.
- [ ] Decide whether `main.rb` remains out of scope.
- [ ] Decide first compatibility fixture set from corpora.

## Runtime Modernization

- [ ] Define script runtime facade boundaries.
- [ ] Add instrumentation plan and logging path.
- [ ] Add rollback / feature-flag plan.
- [ ] Extract low-risk IO/runtime seams.
- [ ] Extract storage/settings/vars seams.
- [ ] Prepare Ruby::Box architecture shims.
- [ ] Prototype Ruby::Box isolation behavior when Ruby support exists.

## Validation And Promotion

- [ ] Run corpus compatibility fixtures.
- [ ] Validate canary scripts.
- [ ] Validate invalid UTF-8 detection path.
- [ ] Prepare team-facing promotion summary.
- [ ] Bundle accepted PRs for broader review.
- [ ] Promote approved work to `elanthia-online/lich-5`.
