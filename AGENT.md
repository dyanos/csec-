# Repository contribution rules

## Language grammar changes

When changing Tessera/CSEC syntax or grammar, keep all language implementations and
documentation in sync as part of the same change.

- Record the accepted syntax, semantics, and examples in `LANGUAGE_SPEC.md`. Create
  that file if it does not yet exist.
- Update the self-hosted compiler implementation under `selfhost/` so it accepts and
  implements the same grammar and semantics as the native compiler.
- Add or update tests for the native compiler and the self-hosted compiler where the
  changed syntax is executable.
- Do not mark a grammar change complete while either `LANGUAGE_SPEC.md` or the
  relevant `selfhost/` compiler code is stale.
