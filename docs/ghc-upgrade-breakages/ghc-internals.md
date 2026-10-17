# GHC internals

Cases caused by a change to the `ghc` package, `template-haskell` or
`ghc-lib-parser`. They reach only programs that use GHC as a library or use
Template Haskell. Part of the [GHC upgrade breakage catalog](README.md), which
explains the sources and the classification.

## A1

**`GreName` is removed from the GHC API.** Reported by Tilapia 9.8.

- **Root cause.** [MR !8686](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/8686)
  moved record disambiguation to the renamer to fix many
  `DuplicateRecordFields` bugs. Record fields now have their own namespace,
  which also added a constructor to Template Haskell's `NameSpace`.

## A2

**`formatBulleted` loses its `SDocContext` argument.** Reported by Tilapia
9.8.

- **Root cause.** [MR !10135](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/10135),
  part of the move to structured diagnostics
  ([#20114](https://gitlab.haskell.org/ghc/ghc/-/issues/20114)).

## A3

**`getKey` returns `Word64` in a minor release.** Reported by Tilapia 9.8.4.

- **Root cause.** [#22010](https://gitlab.haskell.org/ghc/ghc/-/issues/22010),
  first shipped in GHC 9.10 and backported to 9.8.4 and 9.6.7, widened
  `Unique` to 64 bits to avoid miscompilation on 32-bit platforms.
  `ghc-lib-parser` inherits the change. It is a correctness fix that breaks
  the PVP in a minor release. It broke `clash-lib`, `calligraphy` and
  `ghc-typelits-presburger`.

## A4

**Template Haskell's `TyVarBndr ()` becomes `TyVarBndr BndrVis`.** Reported
by Tilapia 9.8.

- **Root cause.** [Proposal #425](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0425-decl-invis-binders.rst),
  [MR !9480](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/9480),
  template-haskell 2.21. Type declarations can now have invisible binders.
- **Mitigation.** Partial: the smart constructors `plainTV` and `kindedTV`,
  or th-abstraction 0.6.

## A5

**Template Haskell: the kind of `Code` changes.** Reported by Tilapia 9.10.

- **Root cause.** The `forall r` moved to the right, so that
  `type CodeQ = Code Q` still has arity 0 after arity inference was removed
  (L10, [#23592](https://gitlab.haskell.org/ghc/ghc/-/issues/23592)). Only
  code with explicit kind annotations breaks, such as
  [th-compat](https://github.com/haskell-compat/th-compat/issues/18).

## A6

**Template Haskell's `InfixD` gains a namespace specifier.** Reported by
Tilapia 9.10.

- **Root cause.** [MR !12012](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/12012),
  for [#14032](https://gitlab.haskell.org/ghc/ghc/-/issues/14032) and part of
  [proposal #65](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0065-type-infix.rst).
  Fixity declarations can now say `type` or `data`.
- **Mitigation.** Partial: `infixLD`, `infixRD` and `infixND` keep their
  types.
- **Report.** §4.4.2: a fixity declaration names an operator and covers both
  namespaces (§1.4).

## A7

**Typed Template Haskell moves from `Q (TExp a)` to `Code Q a`.** Reported
by Unpublished (8.10 → 9.2).

- **Root cause.** [Proposal #195](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0195-code-texp.rst)
  introduced `Code`, and [proposal #246](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0246-overloaded-bracket.rst)
  overloaded quotes over the `Quote` class. Both shipped in template-haskell
  2.17, GHC 9.0.1.
- **Mitigation.** Partial: [th-compat](https://hackage.haskell.org/package/th-compat)
  provides `Splice`, `examineSplice` and `liftSplice` across versions.

## A8

**Exact-print annotations and AST churn in the GHC API.** Reported by
Discourse 9.10.

- **Root cause.** `SrcAnn` became `EpAnn`, and `HsToken` arguments moved into
  extension fields. This broke `tasty-autocollect` and `proto3-suite`. It is
  part of the ongoing exact-print work.
