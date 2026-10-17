# GHC upgrade breakages

A catalog of breaking changes that industrial users hit when upgrading GHC.
Each case is traced to its root cause: a change to the language, to GHC's
diagnostics, a compiler bug, a change to `base` or another boot library, a
change to GHC's own API, a change in a third-party library, or a change in
tooling. Where a case touches something the report specifies, the entry
points at the section. The cases are then assessed against GHC's own
[stability principles](stability.md).

The catalog is input to future revisions of the report, alongside
[GHC extensions](../ghc-extensions/README.md). It records what broke in
practice, so it is not a complete list of what changed. Many cases trace
back to accepted GHC proposals; [Accepted GHC proposals and the breakage they
caused](../ghc-proposal-breakages/README.md) goes through those proposals one
by one. [Lessons learned](lessons.md) draws on both, and proposes changes to
how GHC and its libraries evolve.

## Contents

- [Language](language.md): Cases where GHC accepts different programs, or
  gives them a different meaning.
- [Diagnostics](diagnostics.md): Cases where a warning is new, changed or
  newly enabled. They break only builds that use `-Werror`.
- [Compiler bugs](compiler-bugs.md): Cases caused by a compiler bug or
  regression.
- [`base`](base.md): Cases caused by a change to the API of `base` (or
  `ghc-prim`) visible to ordinary programs.
- [Other boot libraries](boot-libraries.md): Cases caused by a change to a
  library that ships with GHC, so that upgrading GHC forces it.
- [GHC internals](ghc-internals.md): Cases caused by a change to the `ghc`
  package, `template-haskell` or `ghc-lib-parser`. They reach only programs
  that use GHC as a library or use Template Haskell.
- [Ecosystem](ecosystem.md): Cases caused by a change in a third-party library
  that coincided with an upgrade, often because the old version did not build
  on the new GHC.
- [Tooling](tooling.md): Cases caused by a change in a build tool or developer
  tool.
- [Against GHC's stability principles](stability.md): The catalog assessed
  against the GHC stability principles and the goals of the State of Play.
- [Lessons learned](lessons.md): What went wrong across the catalog and the
  accepted proposals, and suggested changes to the processes behind GHC, its
  libraries and this report.
- [Observations](observations.md): Patterns in the catalog that matter for a
  revision of the report.

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
[assessing the cases](stability.md):

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
| [L1](language.md#l1) | Simplified subsumption rejects programs that need deep instantiation | 9.0 | Language | FC | — (rank-N types) | Ellis |
| [L2](language.md#l2) | Type applications in constructor patterns need `TypeAbstractions` | 9.8–9.14 | Language | FC | — | Tilapia 9.8 |
| [L3](language.md#l3) | Failable pattern in linear `do` no longer consumes the value | 9.10 | Language | FC | — (§3.14 for `do`) | Tilapia 9.10 |
| [L4](language.md#l4) | `DuplicateRecordFields` loses type-directed disambiguation | 9.2–9.4 | Language | FC | §3.15 | Unpublished |
| [L5](language.md#l5) | `UndecidableInstances` no longer implies `FlexibleContexts` | 9.2 | Language | FC | §4.1.3, §4.3.2 | Unpublished |
| [L6](language.md#l6) | Strictness flag followed by a space, `! T`, is rejected | 9.0 | Language | FC | **§4.2.1, §2.4: GHC departs from the report** | Unpublished |
| [L7](language.md#l7) | Contexts with type families are no longer inferred for derived instances | 9.6 | Language | FC | §4.3.3 | Unpublished |
| [L8](language.md#l8) | Type-changing record update involving type families | 9.6 | Language | FC | §3.15.3 | Unpublished |
| [L9](language.md#l9) | Constraints that older GHCs called redundant are now required | 9.6 | Language | FC | — | Unpublished |
| [L10](language.md#l10) | Arity inference removed for type synonyms and families | 9.10 | Language | Partial | §4.2.2 | Discourse 9.10 |
| [W1](diagnostics.md#w1) | Pattern-match checker flags more clauses as redundant | 9.0 | Diagnostics | FC | §3.17 | Ellis |
| [W2](diagnostics.md#w2) | `*` as a kind warns | 9.0, 9.6 | Diagnostics | FC | §4.1.1 | Ellis |
| [W3](diagnostics.md#w3) | Matching on a GADT without `MonoLocalBinds` warns | 9.4 | Diagnostics | FC | §4.5.2 | Ellis |
| [W4](diagnostics.md#w4) | `-Weverything` gains new warnings each release | every | Diagnostics | FC | — | Unpublished |
| [W5](diagnostics.md#w5) | `-Wall` includes `-Wincomplete-record-updates` | 9.2, 9.8 | Diagnostics | FC | §3.15.3 | Unpublished |
| [W6](diagnostics.md#w6) | `-Wincomplete-record-selectors` fires spuriously | 9.10 | Diagnostics | FC | §3.15.1 | Tilapia 9.10 |
| [W7](diagnostics.md#w7) | `Type.Reflection.Fun` left out of the `COMPLETE` set | 9.4 | Diagnostics | BF | — | Unpublished |
| [W8](diagnostics.md#w8) | Coverage checker accounts for `⊥` in lazy fields (`Eq` for `TxBody`) | 9.2 | Diagnostics | FC | §3.17.2 | Unpublished |
| [W9](diagnostics.md#w9) | `~` without `TypeOperators` warns | 9.4 | Diagnostics | FC | — | Unpublished |
| [W10](diagnostics.md#w10) | `TypeInType` is deprecated | 9.6 | Diagnostics | FC | — | Unpublished |
| [X1](compiler-bugs.md#x1) | "The impossible happened" with existential types | 9.6 | Bug | FC | — | Ellis |
| [X2](compiler-bugs.md#x2) | Some uses of `$` no longer type-check | 9.14 | Bug | FC | — | Tilapia 9.14 |
| [B1](base.md#b1) | `Prelude` exports `liftA2` | 9.6 | base | FC | §5.5.2, §5.6 | Ellis, Unpublished |
| [B2](base.md#b2) | `MonadFail (ST s)` instance removed | 9.4 | base | FC | §6.3.6 | Ellis |
| [B3](base.md#b3) | `Int64` wraps `Int64#` instead of `Int#` | 9.4 | base | BF | — (abstract in `Data.Int`) | Ellis |
| [B4](base.md#b4) | `head` and `tail` warn as partial | 9.8 | base | FC | §9.1 | Tilapia 9.8, Unpublished |
| [B5](base.md#b5) | `Data.Functor` exports `unzip` | 9.8 | base | FC | §5.5.2 | Tilapia 9.8, Unpublished |
| [B6](base.md#b6) | `Prelude` exports `foldl'` | 9.10 | base | FC | §5.5.2, §5.6 | Tilapia 9.10 |
| [B7](base.md#b7) | `GHC.Num` can no longer be imported from Safe Haskell | 9.10 | base | FC | — | Tilapia 9.10 |
| [B8](base.md#b8) | `ErrorCallWithLocation` deprecated; its location field throws | 9.12 | base | FC | — | Tilapia 9.12 |
| [B9](base.md#b9) | Tuple type constructors renamed `Unit`, `Tuple2`, … | 9.8 | base | BF | §6.1.4 | Tilapia 9.8 |
| [K1](boot-libraries.md#k1) | `mtl` modules stop re-exporting `Control.Monad` and `lift` | 9.6 | Boot library | FC | §5.5.2 | Ellis, Unpublished |
| [K2](boot-libraries.md#k2) | `deepseq` exports `Unit` | 9.8.3 | Boot library | FC | §5.5.2 | Tilapia 9.8.4 |
| [K3](boot-libraries.md#k3) | `Data.Text` exports `show` | 9.10.2, 9.12 | Boot library | FC | §5.5.2 | Tilapia 9.12 |
| [K4](boot-libraries.md#k4) | `Cabal`'s `readGenericPackageDescription` changes type | 9.12 | Boot library | BF | — | Tilapia 9.12 |
| [K5](boot-libraries.md#k5) | `transformers` drops the orphan `Alternative (Either e)` instance | 9.6 | Boot library | BF | — | Discourse 9.8 |
| [K6](boot-libraries.md#k6) | `time` hides internal modules and adds pattern synonyms | 9.14 | Boot library | Partial | §5.5.2 | Discourse 9.14 |
| [A1](ghc-internals.md#a1) | `GreName` removed from the GHC API | 9.8 | GHC internals | BF | — | Tilapia 9.8 |
| [A2](ghc-internals.md#a2) | `formatBulleted` loses its `SDocContext` argument | 9.8 | GHC internals | BF | — | Tilapia 9.8 |
| [A3](ghc-internals.md#a3) | `getKey` returns `Word64` in a minor release | 9.8.4, 9.6.7 | GHC internals | BF | — | Tilapia 9.8.4 |
| [A4](ghc-internals.md#a4) | TH `TyVarBndr ()` becomes `TyVarBndr BndrVis` | 9.8 | GHC internals | Partial | — | Tilapia 9.8 |
| [A5](ghc-internals.md#a5) | TH: the kind of `Code` changes | 9.10 | GHC internals | FC | — | Tilapia 9.10 |
| [A6](ghc-internals.md#a6) | TH `InfixD` gains a namespace specifier | 9.10 | GHC internals | Partial | — (§4.4.2 for fixity) | Tilapia 9.10 |
| [A7](ghc-internals.md#a7) | Typed TH moves from `Q (TExp a)` to `Code Q a` | 9.0 | GHC internals | Partial | — | Unpublished |
| [A8](ghc-internals.md#a8) | Exact-print annotations and AST churn in the GHC API | 9.10 | GHC internals | BF | — | Discourse 9.10 |
| [E1](ecosystem.md#e1) | `aeson` 2 makes `Object` a `KeyMap` | 9.2 | Ecosystem | Partial | — | Ellis |
| [E2](ecosystem.md#e2) | `xlsx` introduces `RowIndex`, `ColumnIndex` and `wsState` | — | Ecosystem | FC | — | Ellis |
| [E3](ecosystem.md#e3) | `flatparse` renames its API | 9.4 | Ecosystem | FC | — | Ellis |
| [E4](ecosystem.md#e4) | `constraints-extras` turns `Has` into a class | 9.6 | Ecosystem | FC | — | Ellis |
| [E5](ecosystem.md#e5) | `genSingletons` stops working | 9.0+ | Ecosystem | BF | — | Ellis |
| [E6](ecosystem.md#e6) | Many upstream packages broken early in a release cycle | 9.8 | Ecosystem | — | — | Unpublished |
| [T1](tooling.md#t1) | `brittany` is unmaintained | 9.2 | Tooling | FC | — | Ellis |
| [T2](tooling.md#t2) | Hadrian does not build GHCi for cross-compilers | 9.6 | Tooling | — | — | Ellis |

## Open items

- X1 and E5: root causes are not confirmed. L9: the exact sites in the
  unpublished report are not known.
- B7 looks like an unreported regression. An issue could be filed upstream.
- W3's message suggests enabling `GADTs` even when it is already on.
- Witnesses for the language cases could go next to
  [`../ghc-extensions/witnesses`](../ghc-extensions/witnesses), and be
  checked against several GHC versions.
