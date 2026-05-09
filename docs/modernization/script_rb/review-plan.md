# Review Plan

Status: documentation-only PR.

## PR 1: Documentation And Review Structure

Purpose:

- give reviewers the plan and vocabulary,
- make phase status visible,
- summarize corpus findings,
- document early API tiering,
- avoid production or spec changes.

This PR should include only files under `docs/modernization/script_rb/`.

## PR 2: Characterization Specs

Purpose:

- lock current behavior before extraction,
- create minimized fixtures for script runtime behavior,
- expose ambiguous behavior as review questions.

Likely locations:

- `spec/lib/common/script_identity_spec.rb`
- `spec/lib/common/script_io_flow_spec.rb`
- `spec/lib/common/script_settings_vars_spec.rb`
- `spec/lib/common/script_hooks_watchfor_spec.rb`
- `spec/lib/common/script_wizard_compat_spec.rb`
- `spec/support/script_runtime_harness.rb`
- `spec/fixtures/scripts/`

## PR 3+: Extraction Work

After specs exist, extract implementation details in small PRs:

1. launch option parsing,
2. script file resolution,
3. error reporting,
4. registry/lifecycle services,
5. IO and buffer services,
6. compatibility facades for direct script state,
7. migration controls and diagnostics,
8. runtime capability adapter.

## Review Questions

Reviewers should focus on:

- whether the Preserve/Compat/Warn/Private tiers match community expectations,
- whether direct script state fields are framed clearly enough,
- whether the Settings versus Vars/UserVars boundary is accurate,
- whether `global_defs.rb` and `spell.rb` sequencing feels right,
- whether the first spec PR covers the risky behavior before refactor work.

## Non-Goals For PR 1

- no behavior changes,
- no spec harness,
- no generated raw CSVs,
- no Ruby::Box implementation,
- no deprecation warnings.
