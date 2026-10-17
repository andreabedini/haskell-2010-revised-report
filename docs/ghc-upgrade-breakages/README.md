# GHC upgrade breakages

A catalog of breaking changes that industrial users hit when upgrading GHC.
Each case is traced to its root cause: a change to the language, to GHC's
diagnostics, a compiler bug, a change to `base` or another boot library, a
change to GHC's own API, a change in a third-party library, or a change in
tooling. Where a case touches something the report specifies, the entry
points at the section. The cases are then assessed against GHC's own
[stability principles](#against-ghcs-stability-principles).

The catalog is input to future revisions of the report, alongside
[GHC extensions](../ghc-extensions/README.md). It records what broke in
practice, so it is not a complete list of what changed.

## Sources

| Key | Source | Upgrades covered |
|---|---|---|
| **Ellis** | Tom Ellis, [Upgrading from GHC 8.10 to GHC 9.6: an experience report](https://h2.jaguarpaw.co.uk/posts/ghc-8.10-9.6-experience-report/), August 2024. Written at Groq. | 8.10 → 9.6 |
| **Tilapia** | Tom Ellis et al., [breakage inventories](https://github.com/tomjaguarpaw/tilapia) in the Tilapia repository, one file per release. Each lists breakage that happened in practice, as opposed to the anticipated breakage in GHC's migration guides. | 9.6 → 9.8, 9.8.x → 9.8.4, 9.8 → 9.10, 9.10 → 9.12, 9.10 → 9.14 |
| **Unpublished** | Experience report on GHC upgrades, unpublished. Entries are paraphrased here. | 8.10 → 9.2 → 9.6 → 9.8 |
| **Discourse** | The Discourse threads that collected the Tilapia inventories, for [9.8](https://discourse.haskell.org/t/please-contribute-to-the-ghc-9-8-breakage-inventory/7970), [9.10](https://discourse.haskell.org/t/please-contribute-to-the-ghc-9-10-breakage-inventory/9533), [9.12](https://discourse.haskell.org/t/please-contribute-to-the-ghc-9-12-breakage-inventory/11241) and [9.14](https://discourse.haskell.org/t/was-any-breakage-caused-by-9-14/13902). Only cases missing from the inventories themselves are cited from here. | 9.6 → 9.14 |

One item in the unpublished report is a policy recommendation (keep a list of
allowed `LANGUAGE` pragmas) and not a breakage, so it is not catalogued.

Two further documents give the frame for
[assessing the cases](#against-ghcs-stability-principles):

| Key | Source |
|---|---|
| **Principles** | [GHC stability principles](https://github.com/ghc-proposals/ghc-proposals/blob/master/principles.rst#ghc-stability-principles), section 3 of the GHC proposals' principles, with the extension categories of [proposal #669](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0669-extension-categorization.md) (merged August 2025). |
| **State of Play** | GHC Stability State of Play, December 2023, updated April 2024, unpublished. A summary of the threads on GHC's stability policy. |

## Classification

| Layer | Meaning |
|---|---|
| **Language** | GHC accepts different programs, or gives them a different meaning. |
| **Diagnostics** | A warning is new, changed, or newly enabled. It breaks only builds that use `-Werror` (or warnings GHC emits by default). |
| **Bug** | A compiler bug or regression. |
| **base** | A change to the API of `base` (or `ghc-prim`) visible to ordinary programs. |
| **Boot library** | A change to another library that ships with GHC, so an upgrade of GHC forces it. |
| **GHC internals** | A change to the `ghc` package, `template-haskell` or `ghc-lib-parser`. It reaches only programs that use GHC as a library or use Template Haskell. |
| **Ecosystem** | A change in a third-party library that coincided with the upgrade, often because the old version did not build on the new GHC. |
| **Tooling** | A change in a build tool or developer tool. |

The **Mitigation** column follows Ellis's distinction. **FC** means a
*forward-compatible mitigation* existed: a change you can make before
upgrading that works with both the old and new versions. **BF** means only a
*breaking fix* was possible: a change that works only after the upgrade, or
only with CPP. **Partial** means a forward-compatible mitigation covers some
uses only.

The **Report** column names the section of the Haskell 2010 report that the
case touches, or "—" when the case is outside the report.

## Summary

| ID | Breakage | GHC | Layer | Mitigation | Report | Reported in |
|---|---|---|---|---|---|---|
| [L1](#l1) | Simplified subsumption rejects programs that need deep instantiation | 9.0 | Language | FC | — (rank-N types) | Ellis |
| [L2](#l2) | Type applications in constructor patterns need `TypeAbstractions` | 9.8–9.14 | Language | FC | — | Tilapia 9.8 |
| [L3](#l3) | Failable pattern in linear `do` no longer consumes the value | 9.10 | Language | FC | — (§3.14 for `do`) | Tilapia 9.10 |
| [L4](#l4) | `DuplicateRecordFields` loses type-directed disambiguation | 9.2–9.4 | Language | FC | §3.15 | Unpublished |
| [L5](#l5) | `UndecidableInstances` no longer implies `FlexibleContexts` | 9.2 | Language | FC | §4.1.3, §4.3.2 | Unpublished |
| [L6](#l6) | Strictness flag followed by a space, `! T`, is rejected | 9.0 | Language | FC | **§4.2.1, §2.4: GHC departs from the report** | Unpublished |
| [L7](#l7) | Contexts with type families are no longer inferred for derived instances | 9.6 | Language | FC | §4.3.3 | Unpublished |
| [L8](#l8) | Type-changing record update involving type families | 9.6 | Language | FC | §3.15.3 | Unpublished |
| [L9](#l9) | Constraints that older GHCs called redundant are now required | 9.6 | Language | FC | — | Unpublished |
| [L10](#l10) | Arity inference removed for type synonyms and families | 9.10 | Language | Partial | §4.2.2 | Discourse 9.10 |
| [W1](#w1) | Pattern-match checker flags more clauses as redundant | 9.0 | Diagnostics | FC | §3.17 | Ellis |
| [W2](#w2) | `*` as a kind warns | 9.0, 9.6 | Diagnostics | FC | §4.1.1 | Ellis |
| [W3](#w3) | Matching on a GADT without `MonoLocalBinds` warns | 9.4 | Diagnostics | FC | §4.5.2 | Ellis |
| [W4](#w4) | `-Weverything` gains new warnings each release | every | Diagnostics | FC | — | Unpublished |
| [W5](#w5) | `-Wall` includes `-Wincomplete-record-updates` | 9.2, 9.8 | Diagnostics | FC | §3.15.3 | Unpublished |
| [W6](#w6) | `-Wincomplete-record-selectors` fires spuriously | 9.10 | Diagnostics | FC | §3.15.1 | Tilapia 9.10 |
| [W7](#w7) | `Type.Reflection.Fun` left out of the `COMPLETE` set | 9.4 | Diagnostics | BF | — | Unpublished |
| [W8](#w8) | Coverage checker accounts for `⊥` in lazy fields (`Eq` for `TxBody`) | 9.2 | Diagnostics | FC | §3.17.2 | Unpublished |
| [W9](#w9) | `~` without `TypeOperators` warns | 9.4 | Diagnostics | FC | — | Unpublished |
| [W10](#w10) | `TypeInType` is deprecated | 9.6 | Diagnostics | FC | — | Unpublished |
| [X1](#x1) | "The impossible happened" with existential types | 9.6 | Bug | FC | — | Ellis |
| [X2](#x2) | Some uses of `$` no longer type-check | 9.14 | Bug | FC | — | Tilapia 9.14 |
| [B1](#b1) | `Prelude` exports `liftA2` | 9.6 | base | FC | §5.5.2, §5.6 | Ellis, Unpublished |
| [B2](#b2) | `MonadFail (ST s)` instance removed | 9.4 | base | FC | §6.3.6 | Ellis |
| [B3](#b3) | `Int64` wraps `Int64#` instead of `Int#` | 9.4 | base | BF | — (abstract in `Data.Int`) | Ellis |
| [B4](#b4) | `head` and `tail` warn as partial | 9.8 | base | FC | §9.1 | Tilapia 9.8, Unpublished |
| [B5](#b5) | `Data.Functor` exports `unzip` | 9.8 | base | FC | §5.5.2 | Tilapia 9.8, Unpublished |
| [B6](#b6) | `Prelude` exports `foldl'` | 9.10 | base | FC | §5.5.2, §5.6 | Tilapia 9.10 |
| [B7](#b7) | `GHC.Num` can no longer be imported from Safe Haskell | 9.10 | base | FC | — | Tilapia 9.10 |
| [B8](#b8) | `ErrorCallWithLocation` deprecated; its location field throws | 9.12 | base | FC | — | Tilapia 9.12 |
| [B9](#b9) | Tuple type constructors renamed `Unit`, `Tuple2`, … | 9.8 | base | BF | §6.1.4 | Tilapia 9.8 |
| [K1](#k1) | `mtl` modules stop re-exporting `Control.Monad` and `lift` | 9.6 | Boot library | FC | §5.5.2 | Ellis, Unpublished |
| [K2](#k2) | `deepseq` exports `Unit` | 9.8.3 | Boot library | FC | §5.5.2 | Tilapia 9.8.4 |
| [K3](#k3) | `Data.Text` exports `show` | 9.10.2, 9.12 | Boot library | FC | §5.5.2 | Tilapia 9.12 |
| [K4](#k4) | `Cabal`'s `readGenericPackageDescription` changes type | 9.12 | Boot library | BF | — | Tilapia 9.12 |
| [K5](#k5) | `transformers` drops the orphan `Alternative (Either e)` instance | 9.6 | Boot library | BF | — | Discourse 9.8 |
| [K6](#k6) | `time` hides internal modules and adds pattern synonyms | 9.14 | Boot library | Partial | §5.5.2 | Discourse 9.14 |
| [A1](#a1) | `GreName` removed from the GHC API | 9.8 | GHC internals | BF | — | Tilapia 9.8 |
| [A2](#a2) | `formatBulleted` loses its `SDocContext` argument | 9.8 | GHC internals | BF | — | Tilapia 9.8 |
| [A3](#a3) | `getKey` returns `Word64` in a minor release | 9.8.4, 9.6.7 | GHC internals | BF | — | Tilapia 9.8.4 |
| [A4](#a4) | TH `TyVarBndr ()` becomes `TyVarBndr BndrVis` | 9.8 | GHC internals | Partial | — | Tilapia 9.8 |
| [A5](#a5) | TH: the kind of `Code` changes | 9.10 | GHC internals | FC | — | Tilapia 9.10 |
| [A6](#a6) | TH `InfixD` gains a namespace specifier | 9.10 | GHC internals | Partial | — (§4.4.2 for fixity) | Tilapia 9.10 |
| [A7](#a7) | Typed TH moves from `Q (TExp a)` to `Code Q a` | 9.0 | GHC internals | Partial | — | Unpublished |
| [A8](#a8) | Exact-print annotations and AST churn in the GHC API | 9.10 | GHC internals | BF | — | Discourse 9.10 |
| [E1](#e1) | `aeson` 2 makes `Object` a `KeyMap` | 9.2 | Ecosystem | Partial | — | Ellis |
| [E2](#e2) | `xlsx` introduces `RowIndex`, `ColumnIndex` and `wsState` | — | Ecosystem | FC | — | Ellis |
| [E3](#e3) | `flatparse` renames its API | 9.4 | Ecosystem | FC | — | Ellis |
| [E4](#e4) | `constraints-extras` turns `Has` into a class | 9.6 | Ecosystem | FC | — | Ellis |
| [E5](#e5) | `genSingletons` stops working | 9.0+ | Ecosystem | BF | — | Ellis |
| [E6](#e6) | Many upstream packages broken early in a release cycle | 9.8 | Ecosystem | — | — | Unpublished |
| [T1](#t1) | `brittany` is unmaintained | 9.2 | Tooling | FC | — | Ellis |
| [T2](#t2) | Hadrian does not build GHCi for cross-compilers | 9.6 | Tooling | — | — | Ellis |

## Language

### L1

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

### L2

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

### L3

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

### L4

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

### L5

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

### L6

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

### L7

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

### L8

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

### L9

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

### L10

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

## Diagnostics

### W1

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

### W2

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

### W3

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

### W4

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

### W5

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

### W6

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

### W7

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

### W8

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

### W9

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

### W10

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

## Compiler bugs

### X1

**"The impossible happened" with existential types.** Reported by Ellis
(9.6).

- **Root cause.** Unidentified. The workaround (move an inner binding to top
  level and mark it `NOINLINE`) points to the optimiser, not the type
  checker. Candidates: `lookupIdSubst` panics on 9.4 and 9.6
  ([#25424](https://gitlab.haskell.org/ghc/ghc/-/issues/25424),
  [#25064](https://gitlab.haskell.org/ghc/ghc/-/issues/25064)).
- **Mitigation.** FC, as above.

### X2

**Some uses of `$` no longer type-check.** Reported by Tilapia 9.14.

- **Root cause.** [#26543](https://gitlab.haskell.org/ghc/ghc/-/issues/26543).
  - `$` is typed by Quick Look. GHC 9.14 added a shape test before Quick
    Look unifies (67a177b4), and a coercion hole left by a kind-checked type
    application makes that test fail.
  - The reduced case is fixed and backported to 9.14.2. The original case is
    fixed on master only (97adaf89, October 2026).
- **Mitigation.** FC: use parentheses instead of `$`.
- **Report.** In the report `$` is an ordinary function (§9). GHC types it
  specially.

## `base`

### B1

**`Prelude` exports `liftA2`.** Reported by Ellis and Unpublished (9.2 →
9.6).

- **Root cause.** [CLC proposal #50](https://github.com/haskell/core-libraries-committee/issues/50),
  base-4.18, GHC 9.6.1 ([migration guide](https://github.com/haskell/core-libraries-committee/blob/main/guides/export-lifta2-prelude.md)).
  The aim was to make every minimal method of `Applicative` nameable without
  an import.
  - `import Control.Applicative (liftA2)` is now redundant
    (`-Wunused-imports`).
  - A user-defined `liftA2` used unqualified is now ambiguous.
  - Unpublished says `Control.Applicative` stopped exporting `liftA2`. That
    is not so: it still exports it.
  - GHC's 9.6 migration guide cites the proposal as "CLC #3", which is wrong.
- **Mitigation.** FC: `import Prelude hiding (Applicative(..))` plus
  `import Control.Applicative (Applicative(..))`. Hiding only `liftA2` warns
  under `-Wdodgy-imports` on older `base`.
- **Report.** §5.5.2: a name imported from two modules is an error only
  where it is used, so adding an export to `Prelude` breaks any module that
  defines the same name and uses it unqualified. §5.6.2 requires such a
  module to hide the Prelude name explicitly. `Applicative` is not in the
  Haskell 2010 Prelude.

### B2

**The `MonadFail (ST s)` instance is removed.** Reported by Ellis.

- **Root cause.** [CLC proposal #33](https://github.com/haskell/core-libraries-committee/issues/33),
  base-4.17, GHC 9.4.1 (not 9.6). An instance whose `fail` is `error` goes
  against the MonadFail proposal.
- **Mitigation.** FC: use `error`, and bind refutable patterns through `case`.
- **Report.** §6.3.6 puts `fail` in `Monad`, and §3.14 calls it when a
  pattern fails in `do`. GHC moved `fail` into `MonadFail` (GHC 8.8). `ST` is
  not in the report.

### B3

**`Int64` wraps `Int64#` instead of `Int#`.** Reported by Ellis.

- **Root cause.** [#11953](https://gitlab.haskell.org/ghc/ghc/-/issues/11953)
  and [#11470](https://gitlab.haskell.org/ghc/ghc/-/issues/11470), base-4.17,
  GHC 9.4.1. The aim is fixed-width primitive types on every platform and a
  compiler that does not depend on its target's word size. `Word64` changed
  the same way. The same change broke `flatparse` (E3).
- **Mitigation.** BF: CPP on `MIN_VERSION_base(4,17,0)`, or stop using the
  constructor.
- **Report.** The report's `Data.Int` keeps `Int64` abstract, and
  `stdlib/src/Data/Int.hs` follows it.

### B4

**`head` and `tail` warn as partial.** Reported by Tilapia 9.8 and
Unpublished (9.6 → 9.8).

- **Root cause.** [CLC proposal #87](https://github.com/haskell/core-libraries-committee/issues/87)
  with the warning categories of [CLC #114](https://github.com/haskell/core-libraries-committee/issues/114)
  and GHC proposal #541. Shipped in base-4.19, GHC 9.8.1
  ([migration guide](https://github.com/haskell/core-libraries-committee/blob/main/guides/warning-for-head-and-tail.md)).
  base-4.23 extends the warning to `init` and `last`.
- **Mitigation.** FC: `-Wno-x-partial -Wno-unrecognised-warning-flags`, or
  rewrite the code.
- **Report.** §9.1 defines `head` and `tail` as partial functions. Haskell
  2010 has no pragma for attaching a warning to an entity.

### B5

**`Data.Functor` exports `unzip`.** Reported by Tilapia 9.8 and Unpublished
(9.6 → 9.8).

- **Root cause.** [CLC proposal #88](https://github.com/haskell/core-libraries-committee/issues/88),
  base-4.19, GHC 9.8.1. An unqualified `import Data.Functor` makes `unzip`
  ambiguous with `Prelude.unzip`.
- **Mitigation.** FC: import `Data.Functor` with an import list, or qualified.
- **Report.** §5.5.2. `Data.Functor` is not in the Haskell 2010 libraries.

### B6

**`Prelude` exports `foldl'`.** Reported by Tilapia 9.10.

- **Root cause.** [CLC proposal #167](https://github.com/haskell/core-libraries-committee/issues/167),
  base-4.20, GHC 9.10.1 ([migration guide](https://discourse.haskell.org/t/prelude-foldl-migration-guide/6950)).
  The aim was to steer newcomers away from the space leaks of `foldl`.
- **Mitigation.** FC: `import Prelude hiding (Foldable(..))` plus
  `import Data.Foldable (Foldable(..))`.
- **Report.** §5.5.2 and §5.6.2, as for B1. The Haskell 2010 Prelude exports
  `foldl` and not `foldl'`. The libraries report puts `foldl'` in
  `Data.List`.

### B7

**`GHC.Num` can no longer be imported from Safe Haskell.** Reported by
Tilapia 9.10.

- **Root cause.** When `base` was split into `ghc-internal` (GHC 9.10), the
  new `GHC.Num` became a re-export shim without its `Trustworthy` pragma.
  `ghc --show-iface` reports `trusted: trustworthy` on 9.8.4 and
  `trusted: none` on 9.10.3 and 9.14.1. Only `GHC.Num`, `GHC.Constants` and
  `System.CPUTime.Utils` lost their status. No changelog, proposal or issue
  mentions it, so it looks like an oversight. It is not fixed in 9.14.1.
- **Mitigation.** FC: import the names from `Prelude`
  ([protolude #149](https://github.com/protolude/protolude/issues/149)).
- **Report.** Outside the report.

### B8

**`ErrorCallWithLocation` is deprecated, and its location field throws.**
Reported by Tilapia 9.12.

- **Root cause.** [CLC proposal #285](https://github.com/haskell/core-libraries-committee/issues/285),
  base-4.21, GHC 9.12.1. Exception backtraces made `error` print two call
  stacks ([#25283](https://gitlab.haskell.org/ghc/ghc/-/issues/25283)), so
  `ErrorCall` stopped carrying its own.
  - The constructor became a pattern synonym whose location field calls
    `error`.
  - After release, committee members said they had not seen this as
    breaking. No resolution is recorded.
  - The base changelog does not mention it.
- **Mitigation.** FC: the `ErrorCall msg` pattern, available since GHC 8.0.
- **Report.** Outside the report. §3.1 specifies `error`, but not the
  exception it raises.

### B9

**Tuple type constructors are renamed `Unit`, `Tuple2`, ….** Reported by
Tilapia 9.8 as a GHC API change.

- **Root cause.** [Proposal #475](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0475-tuple-syntax.rst),
  [MR !9821](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/9821), GHC
  9.8.1. It prepares the ground for `NoListTuplePuns`.
  - Source syntax is unchanged.
  - `GHC.Generics.datatypeName` and `tyConName` now return `"Tuple2"`, which
    broke [swagger2's tests](https://github.com/GetShopTV/swagger2/issues/248).
  - `show (typeRep @(Int, Bool))` still prints `(Int,Bool)`.
  - The change went undocumented until 9.8.2.
- **Mitigation.** BF.
- **Report.** §6.1.4 and §3.8 give tuples special syntax only. The report has
  no reflection on type names.

## Other boot libraries

### K1

**`mtl` modules stop re-exporting `Control.Monad` and `lift`.** Reported by
Ellis and Unpublished (9.2 → 9.6).

- **Root cause.** mtl-2.3 ([#68](https://github.com/haskell/mtl/issues/68),
  [PR #108](https://github.com/haskell/mtl/pull/108)) removed the re-exports
  of `Control.Monad`, `Control.Monad.Fix` and `Data.Monoid`.
  - `Control.Monad.Except` and `Control.Monad.Cont` also lost `lift`,
    `MonadTrans` and `MonadIO`.
  - mtl-2.3.1 restored only `ExceptT`.
  - The stated reason is the PVP: re-exports turn upstream additions into
    downstream clashes.
  - GHC 9.6.1 is the first to ship mtl-2.3.1, as a dependency of `Cabal`.
- **Mitigation.** FC: mtl-2.3.1 builds with GHC 8.6 and later, or import
  `Control.Monad` and `Control.Monad.Trans.Class` explicitly.
- **Report.** §5.2: re-exporting a whole module makes the importer's
  namespace depend on that module's export list. This case is one of the
  §5.5.2 clashes going the other way.

### K2

**`deepseq` exports `Unit`.** Reported by Tilapia 9.8.4.

- **Root cause.** deepseq-1.5.1.0 added `newtype Unit` (a monoid built on
  `seq`), and GHC 9.8.3 picked it up. An unqualified
  `import Control.DeepSeq` in GHC's own `GHC.Unit.Types` made `Unit`
  ambiguous ([#25411](https://gitlab.haskell.org/ghc/ghc/-/issues/25411)),
  so GHC 9.10.1 could not be built with 9.8.3. Adding an export is a minor
  change under the PVP.
- **Mitigation.** FC: explicit or qualified imports.
- **Report.** §5.5.2.

### K3

**`Data.Text` exports `show`.** Reported by Tilapia 9.12.

- **Root cause.** text-2.1.2 ([PR #608](https://github.com/haskell/text/pull/608),
  closing [#183](https://github.com/haskell/text/issues/183)), bundled with
  GHC 9.10.2 and 9.12. The name was chosen because `Data.Text` is meant to
  be imported qualified. A clash with `Prelude.show` was raised as an
  objection in 2017.
- **Mitigation.** FC: qualified import.
- **Report.** §5.5.2.

### K4

**`Cabal`'s `readGenericPackageDescription` changes type.** Reported by
Tilapia 9.12.

- **Root cause.** [haskell/cabal#9718](https://github.com/haskell/cabal/pull/9718),
  Cabal 3.14, which GHC 9.12 ships. The aim is to make the library
  independent of the working directory, so builds can run in parallel in
  one process. Paths become `SymbolicPath`s.
- **Mitigation.** BF: CPP on `MIN_VERSION_Cabal(3,14,0)`.

### K5

**`transformers` drops the orphan `Alternative (Either e)` instance.**
Reported by Discourse 9.8 (from GHC 9.6).

- **Root cause.** transformers-0.6, shipped with GHC 9.6, removed the
  deprecated `Control.Monad.Trans.Error` and the orphan instance that came
  with it.
- **Mitigation.** BF: define the instance locally (as an orphan), or change
  the code.
- **Report.** §5.4: instances are imported whenever their module is imported,
  directly or indirectly, so removing a module can remove instances that
  programs relied on without naming it.

### K6

**`time` hides internal modules and adds pattern synonyms.** Reported by
Discourse 9.14.

- **Root cause.** time-1.15, shipped with GHC 9.14
  ([thread](https://discourse.haskell.org/t/breaking-changes-in-time-1-15-ghc-9-14/13711)).
  The hidden modules broke `timezone-series`. The new pattern synonyms clash
  with local definitions.
- **Mitigation.** Partial.
- **Report.** §5.5.2.

## GHC internals

### A1

**`GreName` is removed from the GHC API.** Reported by Tilapia 9.8.

- **Root cause.** [MR !8686](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/8686)
  moved record disambiguation to the renamer to fix many
  `DuplicateRecordFields` bugs. Record fields now have their own namespace,
  which also added a constructor to Template Haskell's `NameSpace`.

### A2

**`formatBulleted` loses its `SDocContext` argument.** Reported by Tilapia
9.8.

- **Root cause.** [MR !10135](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/10135),
  part of the move to structured diagnostics
  ([#20114](https://gitlab.haskell.org/ghc/ghc/-/issues/20114)).

### A3

**`getKey` returns `Word64` in a minor release.** Reported by Tilapia 9.8.4.

- **Root cause.** [#22010](https://gitlab.haskell.org/ghc/ghc/-/issues/22010),
  first shipped in GHC 9.10 and backported to 9.8.4 and 9.6.7, widened
  `Unique` to 64 bits to avoid miscompilation on 32-bit platforms.
  `ghc-lib-parser` inherits the change. It is a correctness fix that breaks
  the PVP in a minor release. It broke `clash-lib`, `calligraphy` and
  `ghc-typelits-presburger`.

### A4

**Template Haskell's `TyVarBndr ()` becomes `TyVarBndr BndrVis`.** Reported
by Tilapia 9.8.

- **Root cause.** [Proposal #425](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0425-decl-invis-binders.rst),
  [MR !9480](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/9480),
  template-haskell 2.21. Type declarations can now have invisible binders.
- **Mitigation.** Partial: the smart constructors `plainTV` and `kindedTV`,
  or th-abstraction 0.6.

### A5

**Template Haskell: the kind of `Code` changes.** Reported by Tilapia 9.10.

- **Root cause.** The `forall r` moved to the right, so that
  `type CodeQ = Code Q` still has arity 0 after arity inference was removed
  (L10, [#23592](https://gitlab.haskell.org/ghc/ghc/-/issues/23592)). Only
  code with explicit kind annotations breaks, such as
  [th-compat](https://github.com/haskell-compat/th-compat/issues/18).

### A6

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

### A7

**Typed Template Haskell moves from `Q (TExp a)` to `Code Q a`.** Reported
by Unpublished (8.10 → 9.2).

- **Root cause.** [Proposal #195](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0195-code-texp.rst)
  introduced `Code`, and [proposal #246](https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0246-overloaded-bracket.rst)
  overloaded quotes over the `Quote` class. Both shipped in template-haskell
  2.17, GHC 9.0.1.
- **Mitigation.** Partial: [th-compat](https://hackage.haskell.org/package/th-compat)
  provides `Splice`, `examineSplice` and `liftSplice` across versions.

### A8

**Exact-print annotations and AST churn in the GHC API.** Reported by
Discourse 9.10.

- **Root cause.** `SrcAnn` became `EpAnn`, and `HsToken` arguments moved into
  extension fields. This broke `tasty-autocollect` and `proto3-suite`. It is
  part of the ongoing exact-print work.

## Ecosystem

### E1

**`aeson` 2 makes `Object` a `KeyMap`.** Reported by Ellis.

- **Root cause.** Hash flooding ([aeson #864](https://github.com/haskell/aeson/issues/864),
  [HSEC-2023-0001](https://osv.dev/vulnerability/HSEC-2023-0001)).
  aeson-2.0.0.0 made the map type abstract, and 2.0.1.0 switched to an
  ordered map. aeson-1.5.6.0 caps `template-haskell < 2.18`, so it cannot
  build on GHC 9.2 or later, and the GHC upgrade forced the move.
- **Mitigation.** Partial: aeson 2 supports GHC 8.10. Ellis's compat-layer
  PR ([#932](https://github.com/haskell/aeson/pull/932)) was not merged.

### E2

**`xlsx` introduces `RowIndex`, `ColumnIndex` and `wsState`.** Reported by
Ellis as `xls`.

- **Root cause.** xlsx-1.1.0 ([#148](https://github.com/qrilka/xlsx/issues/148),
  [PR #161](https://github.com/qrilka/xlsx/pull/161),
  [PR #158](https://github.com/qrilka/xlsx/pull/158)) added the newtypes to
  stop row and column mix-ups and to reject indices below 1. It is not
  related to GHC.
- **Mitigation.** FC: xlsx-1.1.0 supports GHC 8.10.

### E3

**`flatparse` renames its API.** Reported by Ellis.

- **Root cause.** flatparse-0.4.0.0 ([PR #36](https://github.com/AndrasKovacs/flatparse/pull/36))
  bundled renames such as `anyCharASCII` → `anyAsciiChar` with the port to
  GHC 9.4. The port was needed because of the `Word64#` change (B3,
  [#25](https://github.com/AndrasKovacs/flatparse/issues/25)). There is no
  changelog.
- **Mitigation.** FC: flatparse-0.4 supports GHC 8.10.

### E4

**`constraints-extras` turns `Has` into a class.** Reported by Ellis.

- **Root cause.** constraints-extras-0.4.0.0
  ([PR #35](https://github.com/obsidiansystems/constraints-extras/pull/35)).
  The aims were better type errors and allowing `QuantifiedConstraints`,
  which a type family cannot return. 0.3 caps `base < 4.18`, so GHC 9.6
  forces 0.4.
- **Mitigation.** FC: 0.4 supports old `base`.

### E5

**`genSingletons` stops working.** Reported by Ellis.

- **Root cause.** Not confirmed. Likely causes:
  - singletons 3.0 split into `singletons-th` and `singletons-base`.
  - Each `singletons-th` major version supports exactly one GHC.
  - Generated code needs more extensions (`StandaloneKindSignatures`,
    `NoCUSKs`, `NoStarIsType`).
- **Mitigation.** BF: Ellis's team wrote the generated code by hand.

### E6

**Many upstream packages are broken early in a release cycle.** Reported by
Unpublished (9.6 → 9.8).

- **Root cause.** The combined effect of B4, B5, A4 and the other 9.8 changes
  in the [migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.8),
  plus upper bounds that lag behind releases.

## Tooling

### T1

**`brittany` is unmaintained.** Reported by Ellis.

- **Root cause.** The last release supports GHC 9.0 only. ghc-exactprint was
  rewritten for GHC 9.2's in-tree annotations, and nobody ported brittany.
  The [README](https://github.com/lspitzner/brittany/commit/420eac889e337c1b30a239bf57ca6a9f9eb0790b)
  announced the end of maintenance in November 2022.
- **Mitigation.** FC: switch to ormolu or fourmolu.

### T2

**Hadrian does not build GHCi for cross-compilers.** Reported by Ellis.

- **Root cause.** GHC 9.6 removed the make build system
  ([announcement](https://www.haskell.org/ghc/blog/20220805-make-to-hadrian.html)).
  Hadrian builds a stage-1 cross compiler with no internal interpreter and
  ignores `finalStage = Stage2`
  ([#26289](https://gitlab.haskell.org/ghc/ghc/-/issues/26289)). Stage-2
  cross compilers landed on master in 2026
  ([!15231](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/15231)).

## Against GHC's stability principles

The Principles define a *stable package*. A stable package names its
language edition, uses no Experimental extensions or features, relies on no
undefined behaviour, and does not build with `-Werror` or `-d` flags by
default. For such packages they set three rules:

- **GR1.** A stable package that works with GHC X keeps working with GHC
  X+1, provided its direct dependencies still build and the parts of their
  APIs it uses are unchanged. "API" includes semantics and performance. GR1
  does not cover warnings, or the APIs of `ghc`, `ghc-internal` or
  `template-haskell`.
- **GR2.** GR1 may be broken only for a compelling reason: a security hole,
  an outright bug, or a design flaw. Even a design flaw is better fixed in a
  new language edition.
- **GR3.** A break should come with a deprecation cycle: GHC N warns and
  GHC N+1 breaks, and code can be written to work with both.

The State of Play adds two goals:

- **BG1.** A program that compiles with one GHC, under a given language
  edition, compiles with later ones.
- **BG2.** Failing BG1, a program can be changed once, without CPP, so that
  it compiles with GHC X and its successors. A case with a forward-compatible
  mitigation (**FC**) is one where BG2 holds.

The State of Play lists five reasons why BG1 is hard:
1. the API of `base` changes;
2. the API of `Prelude` changes;
3. the API of `template-haskell` changes;
4. libraries such as `mtl` and `transformers` are tied to GHC;
5. the semantics of extensions change.

Its author does not know which of these cause users the most friction. The
industrial reports give a partial answer.

### Where the breakage falls

The catalog has 53 cases:

| Layer | Cases | State of Play reason |
|---|---|---|
| Language | 10 | 5, and L6 needs no extension at all |
| Diagnostics | 10 | none: the Principles exclude warnings |
| `base` | 9 | 1, and 2 for B1 and B6 |
| GHC internals | 8 | 3 for A4–A7. The `ghc` API (A1–A3, A8) is outside the list. |
| Boot library | 6 | 4 |
| Ecosystem | 6 | 4, indirectly, for E1, E3 and E4 |
| Bug | 2 | none |
| Tooling | 2 | none |

By mitigation, 35 cases had a forward-compatible mitigation, so BG2 held for
them. 10 needed a breaking fix and 6 had a partial mitigation; nearly all of
these are in GHC internals, boot libraries and the ecosystem. In 2 cases
(E6, T2) there was nothing to do but wait or give up the feature.

### Case by case

The table covers cases that a stable package could hit. Diagnostics (W1–W10,
B4) do not break GR1, because the Principles exclude `-Werror`. GHC internals
(A1–A8) are excluded by name. Ecosystem and tooling cases (E1–E6, T1–T2) are
outside GHC. K1, K4 and K5 change the API that the package uses, so GR1's
condition on dependencies fails and GR1 does not apply.

| ID | Breaks GR1? | GR2 reason | GR3 cycle |
|---|---|---|---|
| L1 | Yes, for `GHC2021` packages using `RankNTypes` (Stable), and for `Haskell2010` packages on 9.0–9.2.3. `Haskell2010` restored `DeepSubsumption` (Legacy) in 9.2.4: the language edition doing what GR1 intends. | Design: semantics of eta-expansion, groundwork for Quick Look | No |
| L2 | Yes, in 9.14, for packages using `TypeApplications` (Stable) with `ScopedTypeVariables` (uncategorised). The feature moved behind `TypeAbstractions`, which is Experimental. | Design: "extension flag hygiene" | Partial: an unconditional warning in 9.8, then only under `-Wcompat` in 9.10 and 9.12 |
| L3 | No: `LinearTypes` is Experimental. | — | No |
| L4 | Depends: `DuplicateRecordFields` is uncategorised. | Design: the Principles name this mechanism as a violation of the Lexical Scoping Principle. | Yes: warning in 9.2, error in 9.4 |
| L5 | Yes, for `Haskell2010` packages. | Bug: the implication was accidental. | No |
| L6 | Yes, under every edition, with no extensions. | Design: proposal #229 | No |
| L7 | Depends: `TypeFamilies` is uncategorised. | Bug: soundness | No |
| L8 | Depends: `TypeFamilies` is uncategorised. | Bug, and the Principles' clause on refactoring the type checker | No |
| L9 | Depends on uncategorised extensions. | Bug: soundness | Yes: warning in 9.6 and 9.8, error in 9.10 |
| L10 | Depends: `TypeFamilies` is uncategorised. | Design: proposal #425 | No, and undocumented at release |
| X1, X2 | Yes, as regressions. | Not decisions | — |
| B1, B6 | Yes, for modules that define the name themselves. | Design: CLC proposals | Impossible: the Principles note that an added export cannot get a deprecation cycle. |
| B2 | Yes. | Design: the MonadFail proposal | No warning |
| B3 | Arguably not: `GHC.Int` and `GHC.Exts` expose GHC's internals. | Design | No |
| B5, K2, K3, K6 | Yes. The parts of the API the package uses are unchanged, so GR1's condition on dependencies holds, yet the package breaks. | Design | Impossible, as for B1 |
| B7 | Yes, for `Safe` modules (uncategorised). | Not a decision: an oversight | — |
| B8 | Yes. The program compiles but fails at run time, and GR1 counts "runs successfully". | Design: CLC #285 | No: the deprecation and the break came in the same release. |
| B9 | Yes, for programs that read `Generic` or `Typeable` names. GR1 counts semantics as API. | Design: proposal #475 | No, and undocumented until 9.8.2 |

### What this shows

**Export additions defeat GR1 and GR3 together.** B1, B5, B6, K2, K3 and K6
break packages whose dependencies' used API is unchanged, so GR1's condition
on dependencies does not protect them. The Principles themselves say GR3
cannot apply to added exports. They are the most frequent single kind of
breakage in the catalog, and they come from the report's own name-clash rule
(§5.5.2); see [Observations](#observations).

**The Principles' warning exclusion does not match industrial practice.**
The Principles leave `-Werror` out of the definition of a stable package,
meaning a package's default configuration. Both experience reports build
their own code with warnings as errors, and Tilapia counts breakage under
`-Werror`. So 11 of the 53 cases (W1–W10, B4) are a large share of what
users had to fix. GR3 adds to the count: each
deprecation cycle is a new warning, so code that is warning-clean breaks
under `-Werror` one release before the real change.

**GR3 cycles were rare.** Of the language and `base` cases that break GR1,
only L4 and L9 had a full deprecation cycle, and L2 a partial one. Most of
these changes predate the stability principles
([#625](https://github.com/ghc-proposals/ghc-proposals/pull/625), merged in
February 2024). Only B6–B8, K2, K3, K6, L10 and the 9.14 step of L2
shipped later.

**Language editions work where they are used.** L1 shows the mechanism the
Principles recommend: `Haskell2010` keeps the old behaviour, and GHC's
default language moved to `GHC2021` in 9.2. L6 shows its limit. GHC's
lexer has no notion of edition, so a lexical change reaches `Haskell2010`
code with no way back.

## Observations

These patterns matter for a revision of the report.

**Adding an export breaks code.** B1, B5, B6, K2, K3 and K6 all add a name
to a module. Under §5.5.2 the import itself is legal, but every unqualified
use of the name becomes ambiguous. This includes uses of a module's own
top-level definitions, as in the `sin` example in §5.5.2. So the PVP's rule
that additions are non-breaking holds only for code that imports with lists
or qualifies its imports. K1 is the same problem in the other direction.
A revision could let local definitions shadow imported names, or make an
added export a non-breaking change for unqualified imports in some other
way.

**Most breakage is in diagnostics.** W1–W10 and B4 break only `-Werror`
builds, or appear where warnings are on by default. The report says nothing
about warnings. Several cases (L2, W2, W9) show the same path: GHC first
warns, then turns the warning on by default, and later rejects or plans to
reject the program. In three cases (W5, W8 and the long-distance part of
W1), the new warning is right by the report's semantics and the old
silence was a bug.

**`Haskell2010` mode protects some code, but not all of it.**
- Because `Haskell2010` implies `DeepSubsumption`, L1 did not reach modules
  compiled as Haskell 2010 from GHC 9.2.4 on. GHC's default language moved
  to `GHC2021` in 9.2, so modules that do not name a language are not
  protected.
- L5 goes the other way: it reaches only `Haskell2010` modules, because
  `GHC2021` includes `FlexibleContexts`.
- L6 is the one case where GHC rejects Haskell 2010 code that the report
  allows. L8 is a case where GHC moved closer to the report.

**Boot libraries tie library churn to compiler upgrades.** K1–K6, and E1, E3
and E4 indirectly, are library changes that a GHC upgrade forces through
boot libraries or upper bounds.

**GHC's API and Template Haskell are a stability boundary of their own.**
A1–A8 do not touch the language, but they break tools.

## Open items

- X1 and E5: root causes are not confirmed. L9: the exact sites in the
  unpublished report are not known.
- B7 looks like an unreported regression. An issue could be filed upstream.
- W3's message suggests enabling `GADTs` even when it is already on.
- Witnesses for the language cases could go next to
  [`../ghc-extensions/witnesses`](../ghc-extensions/witnesses), and be
  checked against several GHC versions.
