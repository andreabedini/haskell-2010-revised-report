# Language

Cases where GHC accepts different programs, or gives them a different meaning.
Part of the [GHC upgrade breakage catalog](README.md), which explains the
sources and the classification.

## L1

**Simplified subsumption rejects programs that need deep instantiation.**
Reported by Ellis.

With `f :: Int -> (forall a. a -> a)` and
`g :: (forall a. Int -> a -> a) -> ()`, the application `g f` type-checks
in GHC 8.10 and is rejected from GHC 9.0.

- **Root cause.** [GHC proposal #287](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0287-simplify-subsumption.rst),
  GHC 9.0.1. Deep subsumption eta-expands silently, which can change
  semantics (`seq` can tell `⊥` from `\x -> ⊥ x`). The simpler rule also
  prepares for Quick Look impredicativity.
- **Partial revert.** [Proposal #511](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0511-deep-subsumption.rst)
  added `DeepSubsumption` in GHC 9.2.4. The `Haskell98` and `Haskell2010`
  language sets turn it on, `GHC2021` does not. Ellis's example is accepted
  with `-XHaskell2010 -XRankNTypes` and rejected with `-XGHC2021` on GHC
  9.4.8 and 9.14.1. So the breakage reaches modules compiled as `GHC2021`
  (GHC's default since 9.2) and modules built with 9.0–9.2.3.
- **Mitigation.** FC: eta-expand, `g (\x -> f x)`.
- **Report.** Outside Haskell 2010, which has no rank-N types. See also the
  `NoDeepSubsumption` row in [GHC extensions](../ghc-extensions/reference.md).

## L2

**Type applications in constructor patterns need `TypeAbstractions`.**
Reported by Tilapia 9.8.

`Nothing @a <- pure Nothing` was accepted from GHC 9.2 under
`TypeApplications` and `ScopedTypeVariables`.

- **Root cause.** [Proposal #448](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0448-type-variable-scoping.rst),
  as amended by [#604](https://github.com/ghc-proposals/ghc-proposals/pull/604),
  moved the feature to the new `TypeAbstractions` extension. The stated
  reason is "extension flag hygiene".
  - GHC 9.8 emits a warning (GHC-69797) that no flag can suppress, not even
    `-w`.
  - GHC 9.10 renamed it `-Wdeprecated-type-abstractions` and moved it into
    `-Wcompat`, after [#24154](https://gitlab.haskell.org/ghc/ghc/-/issues/24154).
  - GHC 9.14 rejects the program (GHC-78249, "Illegal invisible type
    pattern").
- **Mitigation.** FC: a pattern signature, `(Nothing :: Maybe a) <- …`,
  works from 9.4 to 9.14. `TypeAbstractions` is an unknown extension before
  9.8, so enabling it needs CPP.
- **Report.** Outside Haskell 2010.

## L3

**A failable pattern in linear `do` no longer counts as consuming the
value.** Reported by Tilapia 9.10.

```haskell
g :: a %1 -> Linear.IO a
g x = Linear.do
  (y, True) <- pure (f x)
  return y
```

GHC 9.8 accepts this, and GHC 9.10 rejects it with "Couldn't match type
'Many' with 'One'".

- **Root cause.** [MR !10140](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/10140)
  expands `do` blocks before type-checking. A failable bind becomes
  `\case { pat -> …; _ -> fail … }`, and the wildcard alternative does not
  consume the scrutinee. No issue or release note discusses this effect. It
  appears unintended but sound: on match failure the old program dropped a
  linear value.
- **Mitigation.** FC: bind a variable and match with `case`.
- **Report.** Outside Haskell 2010. §3.14 gives the translation of `do` with
  `fail`. GHC now uses the same scheme before type-checking.

## L4

**`DuplicateRecordFields` loses type-directed disambiguation.** Reported by
Unpublished (8.10 → 9.2).

- **Root cause.** [Proposal #366](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0366-no-ambiguous-field-access.rst).
  - GHC 9.2.1 added `-Wambiguous-fields`, on by default.
  - GHC 9.4.1 removed type-directed disambiguation of selectors, so an
    ambiguous selector is now an error.
  - Type-directed disambiguation of record updates is still accepted with
    the warning. Its removal ([#19461](https://gitlab.haskell.org/ghc/ghc/-/issues/19461))
    is stalled because the alternatives are inadequate.
- **Mitigation.** FC: qualify field names, or use `OverloadedRecordDot` or
  `HasField`.
- **Report.** §3.15 requires field labels to be unique among the types in
  scope. `DuplicateRecordFields` relaxes that rule, and this case is the
  relaxation being taken back in part.

## L5

**`UndecidableInstances` no longer implies `FlexibleContexts`.** Reported by
Unpublished (8.10 → 9.2).

- **Root cause.** Commit 189efc39, closing
  [#19187](https://gitlab.haskell.org/ghc/ghc/-/issues/19187), GHC 9.2.1. The
  9.2.1 release notes call the implication accidental. It applied only to
  instance contexts. An instance such as
  `instance Eq (T1 a) => Eq (T2 a)` now needs `FlexibleContexts`.
- **Mitigation.** FC: enable `FlexibleContexts`. `GHC2021` includes it, so
  only modules in `Haskell2010` mode see the error.
- **Report.** §4.3.2 limits instance contexts to `C u` with `u` a type
  variable. GHC 9.2 enforces this in `Haskell2010` mode, as it should.

## L6

**A strictness flag followed by a space, `! T`, is rejected.** Reported by
Unpublished, which dates it to 9.2.4. That is the version the team moved
to from 8.10.7. The change landed in 9.0.1.

- **Root cause.** [Proposal #229](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0229-whitespace-bang-patterns.rst),
  commit 8168b42 ([#1087](https://gitlab.haskell.org/ghc/ghc/-/issues/1087),
  [#17162](https://gitlab.haskell.org/ghc/ghc/-/issues/17162)). It treats
  `!`, `~`, `@` and `$` according to the white space around them, so that
  they are unambiguous. A loose infix `!` is an operator, and a prefix `!` is
  a strictness or bang annotation.
  - `data T = MkT ! Int` is rejected with "Not a data constructor: '!'".
  - `data U = MkU { f :: ! Int }` is rejected with "Operator applied to too
    few arguments".
  - Confirmed on GHC 9.4.8 and 9.14.1 under `-XHaskell2010`. No flag
    restores the old behaviour. The 9.0 migration guide lists this exact
    example.
- **Mitigation.** FC: write `!Int`, which every GHC accepts.
- **Report.** **GHC departs from the report here.** §4.2.1 gives
  `constr → con [!] atype₁ … [!] atypeₖ` and
  `fielddecl → vars :: (type | ! atype)`. §2.4 makes `!` an ordinary
  `varsym`, with no rule about white space, so `MkT ! Int` is valid
  Haskell 2010. The witness
  [`StrictnessFlagSpace.hs`](../ghc-extensions/witnesses/StrictnessFlagSpace.hs)
  is listed with the other deviations in
  [GHC extensions](../ghc-extensions/reference.md#where-ghcs-haskell-2010-mode-departs-from-the-report).
  It is rejected by GHC 9.4.8, 9.10.3, 9.12.2 and 9.14.1. The same proposal
  causes three more deviations, each with its own witness there: an
  irrefutable pattern written `~ p`, an as-pattern written `x @ p`, and a
  right section `(!1)`.

## L7

**Contexts with type families are no longer inferred for derived instances.**
Reported by Unpublished (9.2 → 9.6). In Plutus, the inferred contexts of
derived `Show` and `NFData` instances stopped being found. The fix was
standalone deriving with explicit contexts
([plutus #5286](https://github.com/IntersectMBO/plutus/pull/5286)).
Unpublished attributes it to superclass expansion. The actual mechanism is a
change in the same commit.

- **Root cause.** Commit aed1974e, "Refactor the treatment of loopy
  superclass dicts", for [#20666](https://gitlab.haskell.org/ghc/ghc/-/issues/20666)
  and [#19690](https://gitlab.haskell.org/ghc/ghc/-/issues/19690), GHC 9.6.1.
  - It rewrote the check on inferred deriving contexts to use Paterson
    size. A constraint headed by a type family, such as Plutus's
    `Everywhere uni Show`, has infinite size, so it can no longer be inferred.
  - GHC 9.8.1 tightened this further
    ([#22696](https://gitlab.haskell.org/ghc/ghc/-/issues/22696)).
  - The stated motivation is soundness: dictionaries built through loopy
    superclasses can diverge at run time.
  - Reproduced: 9.4.8 infers the context, 9.8.4 and 9.14.1 reject.
- **Mitigation.** FC: standalone deriving with an explicit context.
- **Report.** §4.3.3 and Chapter 11 infer derived contexts from the
  constructors' field types. Haskell 2010 has no type families, so the
  report's rule is unaffected.

## L8

**Type-changing record updates involving type families.** Reported by
Unpublished (9.2 → 9.6).

- **Root cause.** Commit e74fc066, "Desugar RecordUpd in tcExpr"
  ([#18802](https://gitlab.haskell.org/ghc/ghc/-/issues/18802)), GHC 9.6.1.
  - Record update is now type-checked as the `case` expression it stands
    for.
  - The old rule tied the type variables of fields that were not updated
    to the result type. Under the new rule a variable that appears only
    under a non-injective type family becomes ambiguous.
  - Cardano's `def { field = … }` on higher-kinded data broke this way.
  - The 9.6 migration guide says such programs were "erroneously accepted".
- **Mitigation.** FC: annotate the record's type, or build with the
  constructor or a lens.
- **Report.** §3.15.3 defines update by translation to `case`, so GHC 9.6
  follows the report more closely than before.

## L9

**Constraints that older GHCs called redundant are now required.** Reported
by Unpublished (9.2 → 9.6).

- **Root cause.** The same change as L7. A constraint that older GHCs could
  solve through a loopy superclass, and so reported as redundant under
  `-Wredundant-constraints`, is now needed. The 9.6 migration guide says
  "the constraint might seem redundant. But it is actually *not*
  redundant".
  - Reproduced: 9.4.8 calls the constraint redundant. Without it, 9.8.4 warns
    under `-Wloopy-superclass-solve` and 9.10.3 rejects
    ([#23017](https://gitlab.haskell.org/ghc/ghc/-/issues/23017)).
  - The exact sites in the unpublished report are not known.
- **Mitigation.** FC: keep the constraint and silence the warning on older
  GHCs.
- **Report.** Outside Haskell 2010, which has no superclass-solving loops
  of this kind.

## L10

**Arity inference is removed for type synonyms and type families.** Reported
by Discourse 9.10.

- **Root cause.** [Proposal #425](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0425-decl-invis-binders.rst),
  implemented by [MR !10660](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/10660)
  for [#23514](https://gitlab.haskell.org/ghc/ghc/-/issues/23514). It broke
  the `singletons` family and went undocumented at release
  ([#24830](https://gitlab.haskell.org/ghc/ghc/-/issues/24830), fixed for
  9.10.2). A5 is the same change seen through Template Haskell.
- **Mitigation.** Partial: write the arity explicitly, with a standalone kind
  signature that puts the `forall` to the right.
- **Report.** §4.2.2: in Haskell 2010 a type synonym's arity is the number of
  variables on its left-hand side, and kinds cannot be written. Code without
  extensions is unaffected.
