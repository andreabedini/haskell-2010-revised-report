# Diagnostics

Cases where a warning is new, changed or newly enabled. They break only builds
that use `-Werror`. Part of the [GHC upgrade breakage catalog](README.md),
which explains the sources and the classification.

## W1

**The pattern-match checker flags more clauses as redundant.** Reported by
Ellis.

- **Root cause.** "Lower Your Guards"
  ([paper](https://www.microsoft.com/en-us/research/uploads/prod/2020/03/lyg.pdf),
  [9.0.1 notes](https://downloads.haskell.org/ghc/9.0.1/docs/html/users_guide/9.0.1-notes.html)),
  completed in GHC 9.0.1. It adds long-distance information and handles
  strict fields and `⊥` ([#18341](https://gitlab.haskell.org/ghc/ghc/-/issues/18341)).
  `-Woverlapping-patterns` is on by default. GHC 9.2 added
  `GHC.Exts.considerAccessible` to silence a single clause.
- **Mitigation.** FC: `-Wwarn=overlapping-patterns`. Ellis judged its
  downside too large and deleted the clauses instead.
- **Report.** §3.17 defines the semantics of pattern matching. The report
  says nothing about redundancy warnings.

## W2

**`*` as a kind warns.** Reported by Ellis.

- **Root cause.** [Proposal #143](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0143-remove-star-kind.rst).
  - GHC 8.6 added `-Wstar-is-type`, and GHC 8.8 put it in `-Wcompat`.
  - GHC 9.0.1 added it to `-Wall` ([04eb0d6c](https://github.com/ghc/ghc/commit/04eb0d6c4de23a4cfe3953e7496f5bc4b5b1d53c)).
  - GHC 9.6.1 turned it on by default ([#22759](https://gitlab.haskell.org/ghc/ghc/-/issues/22759)).
  - The proposal's schedule turns `StarIsType` off about seven years in.
    It is still on in 9.14.1.
- **Mitigation.** FC: `Data.Kind.Type`, available since GHC 8.0.
- **Report.** §4.1.1 writes kinds with `*`, but Haskell 2010 programs cannot
  write kinds. When `StarIsType` goes off by default, the report's notation
  and GHC's syntax will differ.

## W3

**Matching on a GADT without `MonoLocalBinds` warns.** Reported by Ellis.

- **Root cause.** [#20485](https://gitlab.haskell.org/ghc/ghc/-/issues/20485),
  [MR !7042](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/7042), GHC
  9.4.1.
  - Before, a GADT match was an error unless `GADTs` or `TypeFamilies` was on.
  - After, the check depends on `MonoLocalBinds`, failing it gives a warning
    that is on by default, and pattern synonyms are checked too.
  - The reason given is that let-generalisation is unpredictable in the
    presence of local equalities.
  - A plain `Haskell2010` module that matches on an imported GADT now gets a
    warning instead of an error. The suggested fix in the message is
    misleading.
- **Mitigation.** FC: enable `MonoLocalBinds`.
- **Report.** §4.5.2 specifies let-generalisation, which `MonoLocalBinds`
  restricts. See the `MonoLocalBinds` row in
  [GHC extensions](../ghc-extensions/reference.md).

## W4

**`-Weverything` gains new warnings each release.** Reported by Unpublished
(8.10 → 9.2).

- **Root cause.** `-Weverything` is every warning flag GHC knows, so every
  new flag can break `-Werror -Weverything`.
  - GHC 9.0 added `-Winvalid-haddock` and
    `-Wunicode-bidirectional-format-characters`.
  - GHC 9.2 added `-Wmissing-kind-signatures` (the worst offender),
    `-Wimplicit-lift`, `-Wredundant-bang-patterns`, `-Woperator-whitespace`,
    `-Woperator-whitespace-ext-conflict` and `-Wambiguous-fields`.
  - GHC's documentation does not warn against using `-Weverything`.
- **Mitigation.** FC: `-Wall` plus chosen flags.
- **Report.** Outside the report.

## W5

**`-Wall` includes `-Wincomplete-record-updates`.** Reported by
Unpublished (8.10 → 9.2).

- **Root cause.** [Proposal #71](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0071-Wall-uni-patterns.rst)
  ([#15656](https://gitlab.haskell.org/ghc/ghc/-/issues/15656)) added
  `-Wincomplete-uni-patterns` and `-Wincomplete-record-updates` to `-Wall`
  in GHC 9.2.1. The 9.2.1 release notes do not mention it.
  - The warning silently stopped firing in 9.6
    ([#23520](https://gitlab.haskell.org/ghc/ghc/-/issues/23520)) and came
    back in 9.8.1, so a 9.6 → 9.8 upgrade can trip it again.
  - `-Wpartial-fields` warns where a partial field is defined. It is not in
    `-Wall`.
- **Mitigation.** FC: fix the code, or `-Wno-incomplete-record-updates`.
- **Report.** §3.15.3: an update whose fields belong to no constructor of the
  value is a run-time error.

## W6

**`-Wincomplete-record-selectors` fires spuriously.** Reported by Tilapia
9.10.

- **Root cause.** [Proposal #516](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0516-incomplete-record-selectors.rst)
  added the warning in GHC 9.10.1, and GHC 9.14.1 added it to `-Wall`.
  - In the reported case,
    [#24824](https://gitlab.haskell.org/ghc/ghc/-/issues/24824), `sel $ x`
    warned where `sel x` did not. The fix was milestoned for 9.10.2, but the
    reproduction still warns on 9.10.3 and 9.12.2 and is clean on 9.14.1.
  - Other false positives followed in #25592, #25749 and #26686 (9.14.1). In
    #26686 contributors suggest taking the warning out of `-Wall` again.
- **Mitigation.** FC: `-Wno-incomplete-record-selectors`.
- **Report.** §3.15.1: a selector applied to a constructor without the
  field is `⊥`.

## W7

**`Type.Reflection.Fun` is left out of the `COMPLETE` set.** Reported by
Unpublished (9.2 → 9.6) as "`Fun` disappears".

- **Root cause.** The pattern did not disappear.
  [#20230](https://gitlab.haskell.org/ghc/ghc/-/issues/20230) (base-4.17,
  GHC 9.4.1) removed it from the `COMPLETE` pragmas, which became
  `{App, Con}` and `{App, Con'}`. A `Fun` clause after an `App` clause is
  now redundant. Removing it makes GHC ≤ 9.2 report a non-exhaustive match.
- **Mitigation.** BF: CPP. The `binary` package uses
  `#if __GLASGOW_HASKELL__ < 903`.
- **Report.** Outside the report.

## W8

**The coverage checker accounts for `⊥` in lazy fields.** Reported by
Unpublished (8.10 → 9.2) as "`a == b` no longer implies `b == a`" in the
`Eq` instances for `TxBody` and `Tx` in `cardano-api`.

- **Root cause.** In the `Eq` instance, a clause matched `ByronTx{}` against
  `ShelleyTx era _` with an absurd `case era of {}`, but the swapped clause
  was missing. The `era` field is lazy, so `ShelleyTx ⊥ _` exists and the
  swapped case is real.
  - GHC 9.0 ignored `⊥` when checking inhabitation, and stayed silent.
  - GHC 9.2 handles `⊥` and strict fields correctly (#18341, and a rewritten
    inhabitation test) and reports the missing clause under
    `-Wincomplete-patterns`.
  - The fix was cardano-node commit 64031f5, which adds the swapped clause.
  - The 9.2 migration guide describes the same case.
- **Mitigation.** FC: add the swapped clause, or make the field strict.
- **Report.** §3.17.2: a lazy field can hold `⊥`, so the new warning is
  correct by the report's semantics.

## W9

**`~` without `TypeOperators` warns.** Reported by Unpublished (9.2 → 9.6).

- **Root cause.** [Proposal #371](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0371-non-magical-eq.md),
  commit ab618309 ([#18862](https://gitlab.haskell.org/ghc/ghc/-/issues/18862)),
  GHC 9.4.1. `~` became an ordinary type operator exported from `Prelude` and
  `Data.Type.Equality`.
  - Using it without `TypeOperators` triggers
    `-Wtype-equality-requires-operators`, on by default. It is still only a
    warning in 9.14.1.
  - Before 9.4, `~` needed `GADTs` or `TypeFamilies`. Now a module with no
    extensions can write `(a ~ Int) =>` and get only the warning.
- **Mitigation.** FC: enable `TypeOperators`.
- **Report.** Outside Haskell 2010. Because the `Prelude` now exports `~`,
  GHC's `Prelude` exports a name the report's `Prelude` does not.

## W10

**`TypeInType` is deprecated.** Reported by Unpublished (9.2 → 9.6), which
says `DataKinds` (and possibly `PolyKinds`) is not a direct replacement.

- **Root cause.** [Proposal #83](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0083-no-type-in-type.rst)
  and commit 9ce9ea50 ([#20312](https://gitlab.haskell.org/ghc/ghc/-/issues/20312)),
  GHC 9.6.1 (`-Wdeprecated-flags`).
  - `TypeInType` implies `DataKinds`, `PolyKinds` and `KindSignatures`, so
    `DataKinds` plus `PolyKinds` is an exact replacement.
  - `DataKinds` alone is not: under `Haskell2010`, explicit kind variables
    are then rejected. `GHC2021` already includes `PolyKinds`, which hides
    the difference.
- **Mitigation.** FC: `DataKinds` and `PolyKinds`, available since GHC 8.6.
- **Report.** Outside Haskell 2010.
