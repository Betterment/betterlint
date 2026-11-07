# Ruby formatting

Betterlint owns the shared policy. `config/default.yml` inherits the reviewed
`config/formatting.yml` snapshot before applying Betterlint's explicit preferences.
Runtime and repository configuration continue to override Betterlint through the
existing RuboCop inheritance chain. Repository overrides are supported.

The precedence is RuboCop defaults, this snapshot, explicit Betterlint options,
then the consuming repository's existing inheritance chain. RuboCop recursively
merges mappings. Higher-precedence arrays replace lower-precedence arrays unless
`inherit_mode` requests merging (such as Retail's `Exclude` arrays). Explicit
`false` and nested options remain authoritative. Snapshot `Enabled` entries are
omitted for explicitly configured Betterlint cops that rely on RuboCop's default
activation. This keeps `Layout/LineLength` active with `Max: 140`.

## Commands

Run these from a directory with the project's `.rubocop.yml` and bundle:

```sh
bundle exec betterlint-format
bundle exec betterlint-format app/models/example.rb
bundle exec betterlint-format --check
bundle exec betterlint-format --check --format json --out formatting.json
bundle exec rubocop
```

The formatter selects the Layout and Style departments, excluding every cop not
in the reviewed snapshot. It never selects individual cops with `--only`, which
would reactivate disabled rules. It honors per-file configuration and exclusions,
including when files are named explicitly. It uses only safe autocorrection.
Cops marked unsafe do not run. Offenses without a safe autocorrection remain
for review and produce a nonzero status.
The check command makes no edits. Full lint checks remain a separate command.

The formatter accepts paths, `--check`, `--format`, and `--out`. It rejects general
RuboCop flags that could widen its scope or enable unsafe correction. Nonempty
`.rubocop` argument files and `RUBOCOP_OPTS` are rejected; `.rubocop.yml`
configuration remains supported. The formatter resolves all target configurations
before selecting cops and explicitly filters global exclusions, including when
the worktree path contains hidden directories. Caching is
disabled so configuration changes do not produce stale formatting results.

## Snapshot provenance and review

Source: Standard Ruby 1.56.0, `config/base.yml`.
Source SHA256: `6450ee7b50eb4c7b1207773f28f348b31da7ea8dfa23ff8a4ae9f1dc3150aa5d`.
Upstream: https://github.com/standardrb/standard/tree/v1.56.0.
The snapshot retains upstream licensing in `LICENSE.standard`.

The review includes 100 Layout rules and 34 Style rules. The Style selection
covers literal notation, delimiters, parentheses, semicolons, empty methods,
hash syntax, and trailing commas. The complete allowlist is the set of keys in
`config/formatting.yml`. Safe autocorrection remains a separate runtime filter.
Disabled snapshot entries preserve Standard's choice for otherwise unspecified
formatting rules; repository overrides can enable them.

The snapshot excludes Standard's Lint, Metrics, Naming, Performance, custom cops,
and Style rules that rewrite algorithms, control flow, API calls, or application
behavior. It does not import Standard's AllCops settings, target Ruby version,
plugin dependencies, or CLI. The selected settings are compatible with RuboCop
1.84.1 and Ruby 3.4.10, the Retail migration versions. The selected rules do not
vary in Standard's Ruby 3.0 through 3.4 configuration layers.

Betterlint's disabled ordinary string quote rule remains disabled. Its trailing
commas, percent delimiters, block delimiters, and explicit disabled rules remain
intact. Current Betterlint explicitly enables ClosingParenthesisIndentation;
HeredocArgumentClosingParenthesis remains disabled in the imported snapshot.
Local disabled settings for either rule retain precedence.

Future snapshot changes require an explicit review of supported RuboCop options,
activation, exclusions, and safe correction. Update the pinned provenance and
run the precedence and command integration specs. Do not load Standard's internal
files at runtime or add Standard as a production dependency.
