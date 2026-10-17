# Accepted GHC proposals and the breakage they caused

Many of the breakages in the [GHC upgrade catalog](../ghc-upgrade-breakages/README.md)
trace back to accepted GHC proposals. This document goes through every
accepted proposal in the [ghc-proposals](https://github.com/ghc-proposals/ghc-proposals)
repository. For each it compares the breakage the proposal anticipated with
the breakage its implementation actually caused.
[Lessons learned](../ghc-upgrade-breakages/lessons.md) draws conclusions from
this review and the catalog, and suggests process changes.

## How proposals assess breakage

The proposal process did not always ask for a breakage analysis.

- **2016 to 2023.** The [template](https://github.com/ghc-proposals/ghc-proposals/blob/10b18465/proposals/0000-template.rst)
  had two sections near the subject:
  - "Effect and Interactions" asked about "possibly contentious interactions
    with existing language or compiler features".
  - "Costs and Drawbacks" asked about development cost, maintenance cost and
    learnability.

  Neither asked whether existing code would break. Authors who discussed
  breakage did so in one of these sections, or not at all.
- **February 2023.** Adam Gundry opened
  [issue #578](https://github.com/ghc-proposals/ghc-proposals/issues/578),
  "Backwards compatibility", during the stability discussion that followed
  the GHC 9.6 migration guide. It quotes Ben Gamari on proposal
  [#229](#229), whose whitespace rules broke code in GHC 9.0: the proposal
  "is silent on breakage extent, migration timeline, pre-breakage user
  warnings, or how tools might help aid migration".
- **May 2023.** [PR #579](https://github.com/ghc-proposals/ghc-proposals/pull/579)
  added a "Backward Compatibility" section to the template and a matching
  review criterion to the README.
  - Authors rate the expected breakage from 0 (none) to 4 (breakage in
    common cases), describe the migration path, and consider a warning
    period.
  - New warnings do not count as breakage, because packages are assumed not
    to use `-Werror`.
  - The template adds: "When the proposal is implemented, the implementers
    and/or GHC maintainers should test that the actual backwards
    compatibility impact of the implementation is no greater than the
    expected impact. If not, the proposal should be revised and the steering
    committee approve the change."
- **February 2024.** The [GHC stability principles](https://github.com/ghc-proposals/ghc-proposals/blob/master/principles.rst#ghc-stability-principles)
  ([#625](https://github.com/ghc-proposals/ghc-proposals/pull/625)) were
  added, and the template asks how a proposal meets them.

Of the 126 accepted proposals, 17 have a Backward Compatibility section. The
other 109 were written before it existed.

## Method

The list of accepted proposals is the `proposals/` directory of
ghc-proposals as of October 2026, minus the 53 redirect stubs numbered
0002–0054 that point to proposals' current numbers. That leaves 126
proposals. Amendments are folded into the proposal they amend.

For each proposal the entry records:

- **Implemented.** Which GHC versions implement it, and how fully. The
  `implemented` field in the proposals is often wrong or blank (for example
  #425, #448 and #475), so this was checked against GHC's release notes, its
  issue tracker and local compilers.
- **Anticipated.** What the proposal says about breaking existing code,
  quoted or paraphrased, with its 0–4 rating where it gives one.
- **Observed.** Breakage its implementation caused, with versions and links.
  The sources are:
  - GHC's [migration guides](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.0)
    from 8.0 to 10.2;
  - the release notes;
  - GHC's issue tracker;
  - head.hackage patches;
  - Discourse threads;
  - the [upgrade catalog](../ghc-upgrade-breakages/README.md).

  Many claims were reproduced with GHC 9.4.8, 9.8.4, 9.10.3, 9.12.2 and
  9.14.1.
- **Verdict.** One of:

  | Verdict | Meaning |
  |---|---|
  | No breakage found | The implementation broke nothing that the searches found. |
  | As anticipated | It broke code, in the way and to the extent the proposal said. |
  | Worse than anticipated | The proposal discussed breakage but underestimated it. |
  | Not anticipated | The proposal did not discuss breakage, or ruled it out, and the implementation broke code. |
  | Not implemented | Nothing has shipped, or only parts that cannot break code. |

- **Warning period.** Whether GHC warned at least one release before the
  break.
- **Catalog.** Cases in the [upgrade catalog](../ghc-upgrade-breakages/README.md)
  that the proposal caused.

Breakage counts here even where the stability principles exclude it: new
warnings under `-Werror`, and changes to the APIs of Template Haskell and the
`ghc` package. The principles exclude these, but they are what users hit.
Entries say when a breakage is of this kind.

**Limitations.** GitLab rate-limited the research, and its issue comments
need a login, so the searches behind "No breakage found" are lighter than
they should be. Treat that verdict as "none found in the release notes, the
migration guides and a search of the tracker". GHC 10.0.1 and 10.2 have not
been released. Entries that depend on them use the alpha release notes and
may change.

## Results

| Verdict | Proposals |
|---|---|
| No breakage found | 58 |
| As anticipated | 23 |
| Worse than anticipated | 10 |
| Not anticipated | 11 |
| Not implemented | 24 |

Of the 102 implemented proposals, 44 broke existing code. For 21 of those
44, the breakage was worse than the proposal said, or the proposal did not
foresee it:

- **Worse than anticipated:** [#103](#103), [#195](#195), [#229](#229),
  [#274](#274), [#287](#287), [#330](#330), [#370](#370), [#425](#425),
  [#493](#493), [#516](#516).
- **Not anticipated:** [#55](#55), [#65](#65), [#81](#81), [#99](#99),
  [#108](#108), [#109](#109), [#380](#380), [#409](#409), [#475](#475),
  [#518](#518), [#540](#540).

Of the 44, 6 had a full warning period ([#77](#77), [#121](#121),
[#143](#143), [#281](#281), [#366](#366), [#371](#371)). 6 had a partial one
and 29 had none. For the other 3 a warning period did not apply.

Of the 17 proposals with a Backward Compatibility section, none has yet
caused breakage beyond its own assessment. The one exception, [#540](#540),
gained its section in a later amendment written after the breakage. Most of
the 17 are recent, and several are unimplemented or ship only in the
unreleased GHC 10. So the record cannot yet show whether the section works.

## What the record shows

**Template Haskell is the blind spot.** Seven proposals changed the Template
Haskell AST or its types without anticipating it:

| Proposal | GHC | Change |
|---|---|---|
| [#55](#55) | 8.8 | type family instances and `RULES` gain binders |
| [#99](#99) | 9.0 | `TyVarBndr` gains a flag parameter |
| [#195](#195) | 9.0 | `Code` |
| [#425](#425) | 9.8 | `TyVarBndr BndrVis` |
| [#425](#425) | 9.10 | the kind of `Code` |
| [#65](#65) | 9.10 | `InfixD` gains a namespace |
| [#475](#475) | 9.8 | tuple names |
| [#493](#493) | 9.14 | `SpecialiseP` deprecated |

Proposals describe changes to source syntax and treat the Template Haskell
AST as an implementation detail. The stability principles exclude
`template-haskell` by name. Yet libraries that use Template Haskell are where
these changes reach users: `singletons`, `lens` and `th-desugar` among them,
and catalog cases A4–A7 and E5.

**Implementations went beyond their proposals.**
- [#103](#103) shipped four breaking changes in 8.10. The proposal described
  one, and only that one had a warning period.
- [#425](#425) removed arity inference, which it called "obscure… will go
  unnoticed by most users". In 9.10 that broke the `singletons` family and
  went undocumented at release.
- [#330](#330) expected "nearly no impact". It changed the output of
  exceptions in three consecutive releases.
- [#409](#409) relaxed defaulting for all code in 9.12, so GHC accepted under
  `-XHaskell2010` a program that §4.3.4 of the report rejects. 9.14
  reverted it, which breaks code that came to rely on 9.12.
- No implementation was followed by the revision that the template asks for
  when breakage exceeds the assessment. The only proposal that records a
  failed assessment is [#511](#511), which partly reverts [#287](#287):
  "the breakage study failed to accurately predict how annoying this change
  would be to users".

**Promised warning periods were often not delivered.**
- [#229](#229)'s warnings came one release after the break (9.2, not
  9.0). Amendment #368 asks for `-Woperator-whitespace` in `-Wall` and
  `-Wcompat`; in 9.14.1 it is in neither.
- [#65](#65) planned a deprecation cycle that never happened.
- [#77](#77) announced three releases of deprecation and removed the feature
  after one.
- [#448](#448), as amended, promised a two-release warning. It warned
  unconditionally in 9.8, then only under `-Wcompat` (L2).
- [#281](#281) put `-Wterm-variable-capture` in `-Wcompat`, but it shipped
  opt-in.

**Release notes missed breaking changes.** The release notes of the version
that shipped the break do not mention these:
- [#229](#229) in 9.0.1
- [#176](#176) in 9.0.1 (migration guide only)
- [#32](#32) in 9.4.1
- [#547](#547) in 9.8.1
- [#179](#179) (`:type +v`) in 9.2
- [#475](#475) until 9.8.2
- [#425](#425)'s arity change in 9.10.1
- [#65](#65)'s Template Haskell change in 9.10.1

**Changes of default were not assessed.** [#380](#380) defined GHC2021 and
said nothing about breakage. GHC 9.2 made it the default language, which
broke modules that name no language, through `PolyKinds`, the loss of
`CUSKs` and the loss of `NondecreasingIndentation`. Mitigations came only
with a 2025 amendment to #372. The same question now arises for GHC2024,
which becomes the default in GHC 10.0.

**Some proposals change Haskell 2010.**
- [#229](#229) makes GHC reject valid Haskell 2010 in `Haskell2010` mode.
  There are four witnesses in [GHC extensions](../ghc-extensions/reference.md#where-ghcs-haskell-2010-mode-departs-from-the-report):
  `! T` in a field, `~ p`, `x @ p` and `(!1)`.
- [#76](#76) and [#216](#216) reserve syntax even when their extensions are
  off.
- [#403](#403) writes down GHC's rule that numeric literals use only ASCII
  digits, where the 2010 report allowed any Unicode decimal digit. This
  revision of the report adopted the same rule (issue #3, PR #67), so GHC and
  the revised report agree.
- [#409](#409) briefly changed defaulting, as above. The witness
  [`DefaultingNonStandardClass.hs`](../ghc-extensions/witnesses/DefaultingNonStandardClass.hs)
  checks that only GHC 9.12 accepts the program.

#229 is the only one to say it departs from the report: "a slight deviation
from the standard". #409 promised "backward compatibility" with the report's
`default` declaration.

## Summary

| # | Proposal | Accepted | Implemented | Verdict | Warning period | Catalog |
|---|---|---|---|---|---|---|
| [#1](#1) | A Proposal for Proposals | 2017 | n/a | No breakage found | n/a | — |
| [#23](#23) | Overloaded Record Fields | 2017 | 8.2.1 | As anticipated | No | — |
| [#29](#29) | Revise Levity Polymorphism | 2017 | 8.2.1 | As anticipated | No | — |
| [#32](#32) | Declare `Constraint` is not apart from `Type` | 2018 | 9.4.1 | No breakage found | n/a | — |
| [#35](#35) | Make unboxed tuple patterns lazy / warn on unbanged strict patterns | 2018 | 8.2.1 | No breakage found | n/a | — |
| [#37](#37) | Hexadecimal Floats in Haskell | 2017 | 8.4.1 | No breakage found | n/a | — |
| [#42](#42) | Pattern synonym construction function signatures | 2017 | — | Not implemented | n/a | — |
| [#54](#54) | Standalone kind signatures | 2018 | 8.10.1 | No breakage found | n/a | — |
| [#55](#55) | More explicit `forall`s | 2017 | 8.8.1 | Not anticipated | No | — |
| [#63](#63) | Overhaul deriving instances for empty data types | 2017 | 8.4.1 | As anticipated | No | — |
| [#65](#65) | Require namespacing fixity declarations for type names and `WARNING`/`DEPRECATED` pragmas | 2017 | 9.10.1 (partial) | Not anticipated | No | A6 |
| [#71](#71) | Extend `-Wall` with `incomplete-uni-patterns` and `incomplete-record-updates` | 2018 | 9.2.1 | As anticipated | n/a | W5 |
| [#74](#74) | Add more fixed size primitive types, like Int8#/Word8# | 2018 | 8.8 | No breakage found | n/a | — |
| [#76](#76) | Underscores in Numeric Literals | 2017 | 8.6.1 | No breakage found | No | — |
| [#77](#77) | Deprecating STM invariant mechanism | 2018 | 8.4 | As anticipated | Yes | — |
| [#80](#80) | Type-level type applications | 2018 | 8.8.1 | No breakage found | n/a | — |
| [#81](#81) | A syntax for visible dependent quantification | 2018 | 8.10.1 | Not anticipated | No | — |
| [#83](#83) | Embrace `Type :: Type` | 2018 | 8.6.1 | As anticipated | Partial | W10 |
| [#90](#90) | BlockArguments Extension | 2017 | 8.6.1 | No breakage found | n/a | — |
| [#94](#94) | As patterns in pattern synonyms | 2018 | 8.6.1 | No breakage found | n/a | — |
| [#98](#98) | Unlifted Newtypes | 2018 | 8.10.1 | No breakage found | n/a | — |
| [#99](#99) | Explicit specificity in type variable binders | 2018 | 9.0.1 | Not anticipated | No | — (the same pattern recurs in 9.8 as A4) |
| [#103](#103) | Treat kind variables and type variables identically in `forall` | 2018 | 8.10.1 | Worse than anticipated | Partial | — |
| [#106](#106) | Define kinds without promotion (`type data`) | 2018 | 9.6.1 | No breakage found | n/a | — |
| [#107](#107) | Source plugins | 2018 | 8.6.1 | No breakage found | n/a | — |
| [#108](#108) | Refining the plugin recompilation API | 2018 | 8.6.1 | Not anticipated | No | — |
| [#109](#109) | Quantified constraints | 2018 | 8.6.1 | Not anticipated | No | — |
| [#111](#111) | Linear Types | 2018 | 9.0.1 | No breakage found | No | L3 (related, but its root cause is MR !10140) |
| [#112](#112) | UnliftedArray | 2018 | 9.4.1 | As anticipated | No | — |
| [#120](#120) | Deriving Via | 2018 | 8.6.1 | No breakage found | n/a | — |
| [#121](#121) | Offer more array resizing primitives | 2018 | 8.10.1 (partial) | As anticipated | Yes | — |
| [#125](#125) | Type Annotated Quoters | 2019 | — | Not implemented | n/a | — |
| [#126](#126) | Type applications in patterns | 2018 | 9.2.1 | No breakage found | n/a | — (the feature's later removal from `ScopedTypeVariables` is L2, rooted in #448/#604) |
| [#128](#128) | Allow ScopedTypeVariables to refer to types | 2018 | 8.8.1 | No breakage found | n/a | — |
| [#134](#134) | Deprecating Exports | 2018 | 9.8.1 | No breakage found | n/a | — |
| [#143](#143) | Remove the `*` kind syntax | 2018 | 8.6 (partial) | As anticipated | Yes | W2 |
| [#149](#149) | Replace the atomicModifyMutVar# primop | 2018 | 8.8.1 | No breakage found | n/a | — |
| [#155](#155) | Binding type variables in lambda-expressions | 2019 | 9.10.1 | No breakage found | n/a | — |
| [#158](#158) | Add `setField` to `HasField` | 2019 | — | Not implemented | n/a | — |
| [#160](#160) | NoFieldSelectors | 2019 | 9.2.1 | No breakage found | n/a | — |
| [#163](#163) | Remove an undocumented StableName guarantee | 2018 | — | Not implemented | n/a | — |
| [#166](#166) | List instances for a type in GHCi | 2018 | 8.10.1 | No breakage found | n/a | — |
| [#168](#168) | Make rebindable `fail` work with overloaded strings | 2018 | 8.8.1 | No breakage found | No | — |
| [#170](#170) | Unrestricted Overloaded Labels | 2018 | 9.6.1 | As anticipated | No | — |
| [#173](#173) | The dot type operator | 2018 | 8.8.1 | No breakage found | n/a | — |
| [#174](#174) | Lower precedence for `{-# UNPACK #-}` | 2018 | 8.8.1 | No breakage found | n/a | — |
| [#176](#176) | Meaning-preserving parsing rules for SCC annotations | 2019 | 9.0.1 | As anticipated | No | — |
| [#179](#179) | Clean up printing of foralls | 2019 | 9.0.1 | As anticipated | No | — |
| [#190](#190) | Allow `qualified` to follow module name | 2019 | 8.10.1 | No breakage found | n/a | — |
| [#193](#193) | Make `forall` a keyword | 2019 | 8.8.1 | No breakage found | No | — |
| [#195](#195) | Make Q (TExp a) into a newtype | 2020 | 9.0.1 | Worse than anticipated | No | A7, A5 (follow-up) |
| [#203](#203) | Pointer Rep | 2019 | 9.2.1 | As anticipated | No | — |
| [#209](#209) | Levity-polymorphic `Lift` | 2019 | 8.10.1 | As anticipated | No | — |
| [#210](#210) | MINIMAL should warn about extra definitions | 2019 | — | Not implemented | n/a | — |
| [#216](#216) | Qualified do | 2020 | 9.0.1 | No breakage found | No | — |
| [#228](#228) | Function Result Type Signatures | 2019 | — | Not implemented | n/a | — |
| [#229](#229) | Whitespace-sensitive operator parsing (~, !, @, $, $$, -) | 2019 | 9.0.1 | Worse than anticipated | No | L6, W4 |
| [#232](#232) | Ambiguous Type per-signature pragma | 2019 | — | Not implemented | n/a | — |
| [#240](#240) | Compile with threaded RTS by default | 2019 | — | Not implemented | n/a | — |
| [#242](#242) | Unsaturated type families | 2020 | — | Not implemented | n/a | — |
| [#246](#246) | Overloaded Quotations | 2019 | 9.0.1 | As anticipated | No | A7 |
| [#265](#265) | Unlifted Datatypes | 2020 | 9.2.1 | No breakage found | n/a | — |
| [#274](#274) | Quick Look Impredicativity | 2020 | 9.2.1 | Worse than anticipated | No | X2 |
| [#277](#277) | Add winapi pseudo calling convention | 2019 | — | Not implemented | n/a | — |
| [#281](#281) | Visible `forall` in types of terms, and types in terms | 2021 | 9.4.1 (partial) | As anticipated | Yes | — |
| [#282](#282) | Record Dot Syntax | 2020 | 9.2.1 | No breakage found | n/a | — |
| [#285](#285) | `-XNoImplicitForAll`, `-XNoPatternSignatureBinds` | 2020 | — | Not implemented | n/a | — |
| [#287](#287) | Simplify subsumption | 2020 | 9.0.1 | Worse than anticipated | No | L1 |
| [#302](#302) | `\cases` - Multi-way lambda expressions | 2021 | 9.4.1 | No breakage found | No | — |
| [#313](#313) | Delimited continuation primops | 2021 | 9.6.1 | No breakage found | n/a | — |
| [#314](#314) | Enable `-Wnoncanonical-monad-instances` and `-Wnoncanonical-monoid-instances` by default | 2020 | 9.2.1 | No breakage found | n/a | — |
| [#320](#320) | Defaults and backpack/hs-boot | 2020 | 9.2.1 | No breakage found | n/a | — |
| [#330](#330) | Decorate exceptions with backtrace information | 2023 | 9.10.1 | Worse than anticipated | No | B8 |
| [#344](#344) | Negative Literals Improved | 2020 | 9.0.1 | No breakage found | No | — |
| [#364](#364) | Unify `Nat` and `Natural` | 2020 | 9.2.1 | As anticipated | No | — |
| [#366](#366) | DuplicateRecordFields without ambiguous field access | 2020 | 9.2.1 (partial) | As anticipated | Yes | L4 |
| [#369](#369) | Add sumToTag# primop | 2021 | — | Not implemented | n/a | — |
| [#370](#370) | Syntax for Modifiers: a generalization of linear-types syntax | 2020 | 10.0.1 | Worse than anticipated | No | — |
| [#371](#371) | Export `~` from `Data.Type.Equality` | 2021 | 9.4.1 | As anticipated | Yes | W9 |
| [#372](#372) | The GHC20XX process | 2020 | 10.0 | No breakage found | n/a | — |
| [#378](#378) | Design for Dependent Types | 2021 | — | Not implemented | n/a | — |
| [#380](#380) | GHC 2021 | 2021 | 9.2.1 | Not anticipated | No | L1 (default-language modules), W10 (`PolyKinds` hides the difference) |
| [#387](#387) | The `Char` kind | 2021 | 9.2.1 | No breakage found | n/a | — |
| [#402](#402) | Stable GADT constructor syntax | 2021 | — | Not implemented | n/a | — |
| [#403](#403) | Cleanup lexical structure of numbers and identifiers | 2021 | 9.4 | No breakage found | n/a | — |
| [#409](#409) | Generalized, named, and exportable `default` declarations | 2021 | 9.12.1 | Not anticipated | No | — |
| [#415](#415) | OPAQUE pragma | 2021 | 9.4.1 | No breakage found | n/a | — |
| [#425](#425) | Invisible binders in type declarations | 2022 | 9.8.1 (partial) | Worse than anticipated | Partial | L10, A4, A5 |
| [#433](#433) | Unsatisfiable | 2021 | 9.8.1 | No breakage found | n/a | — |
| [#434](#434) | Fine-Grained Unused Warnings | 2024 | — | Not implemented | n/a | — |
| [#448](#448) | Modern Scoped Type Variables | 2022 | 9.14.1 (partial) | As anticipated | Partial | L2 |
| [#451](#451) | Sized primitive literals | 2022 | 9.8.1 | As anticipated | No | — |
| [#475](#475) | Non-punning list and tuple syntax | 2022 | 9.6.1 (partial) | Not anticipated | No | B9 |
| [#477](#477) | Unicode Ellipsis | 2022 | — | Not implemented | n/a | — |
| [#493](#493) | Allow expressions in SPECIALISE pragmas | 2024 | 9.14.1 | Worse than anticipated | Partial | — |
| [#496](#496) | Allow record wildcards for empty records | 2022 | 9.8.1 | No breakage found | n/a | — |
| [#511](#511) | Deep Subsumption | 2022 | 9.2.4 | No breakage found | n/a | L1 (partial mitigation) |
| [#512](#512) | `NoFieldSelectors` as a datatype and field annotation | 2024 | — | Not implemented | n/a | — |
| [#516](#516) | Add warning for incomplete record selectors | 2022 | 9.10.1 | Worse than anticipated | Partial | W6 |
| [#518](#518) | Generalising Type and Constraint | 2022 | 9.6.1 | Not anticipated | No | — |
| [#522](#522) | Or Patterns | 2022 | 9.12.1 | No breakage found | n/a | — |
| [#540](#540) | jsem: parallelism semaphores for GHC | 2023 | 9.8.1 | Not anticipated | n/a | — |
| [#541](#541) | `WARNING` pragmas with categories | 2022 | 9.8.1 | As anticipated | n/a | B4, E6 (contributing) |
| [#547](#547) | Disallow constraints in kinds | 2022 | 9.8.1 | No breakage found | n/a | — |
| [#555](#555) | Higher Order Patterns in Rewrite Rules | 2023 | 9.8.1 | No breakage found | n/a | — |
| [#569](#569) | Multiline strings | 2024 | 9.12.1 | No breakage found | n/a | — |
| [#570](#570) | Add native string interpolation syntax | 2026 | — | Not implemented | n/a | — |
| [#575](#575) | Deprecated instances | 2023 | 9.10.1 | No breakage found | n/a | — |
| [#581](#581) | Namespace-specified imports | 2023 | 9.14.1 (partial) | No breakage found | No | — |
| [#583](#583) | HasField redesign | 2023 | 9.12.1 (partial) | As anticipated | No | — |
| [#586](#586) | Split `-Wunused-imports` | 2023 | — | Not implemented | n/a | — |
| [#601](#601) | Extension Lifecycle Framework | 2024 | n/a | No breakage found | n/a | — |
| [#612](#612) | Change the semantics of -fhpc | 2024 | 9.12.1 (partial) | No breakage found | Yes | — |
| [#613](#613) | GHC2024 | 2024 | 9.10.1 | No breakage found | n/a | — |
| [#631](#631) | Meaningful main return types | 2024 | — | Not implemented | n/a | — |
| [#640](#640) | Fix quantification order for (a `op` b) and (a %m -> b) | 2024 | 9.12.1 | No breakage found | n/a | — |
| [#652](#652) | Import shadowing | 2024 | — | Not implemented | n/a | — |
| [#669](#669) | Categorization of Language Extensions | 2025 | — | Not implemented | n/a | — |
| [#682](#682) | Explicit Level Imports | 2025 | 9.14.1 | No breakage found | n/a | — |
| [#696](#696) | Splitting out stable interfaces from `template-haskell` | 2025 | 9.14.1 | No breakage found | n/a | — |
| [#700](#700) | Abstract Q | 2026 | 10.2 | No breakage found | No | — |
| [#723](#723) | Qualified Strings | 2025 | 10.0.1 | No breakage found | n/a | — |
| [#732](#732) | Simplifying static forms | 2025 | 10.0.1 | No breakage found | Partial | — |
| [#748](#748) | Extra Commas | 2026 | — | Not implemented | n/a | — |
| [#752](#752) | Lazy Field Annotations | 2026 | 10.2 | No breakage found | n/a | — |
| [#765](#765) | Pun warnings | 2026 | — | Not implemented | n/a | — |

## Proposals

### 1

**A Proposal for Proposals**
- **Implemented:** n/a — process (the GitHub-based proposal process, adopted January 2017).
- **Anticipated:** n/a — process. "Costs and Drawbacks" discusses only how well GitHub scales for discussion.
- **Observed:** n/a — process.
- **Verdict:** `No breakage found`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** Changes no code. The "Backward Compatibility" section with its 0–4 scale came later (issue #578 / PR #579, 2023).

### 23

**Overloaded Record Fields**
- **Implemented:** GHC 8.2.1, in part: the `HasField` class in `GHC.Records` with built-in constraint solving, and `fromLabel` without its `Proxy#` argument. The proposed orphan-free instance `HasField x r a => IsLabel x (r -> a)` never shipped in `base`.
- **Anticipated:** Costs and Drawbacks: "Existing code using `OverloadedLabels` from GHC 8.0.1 will need to be adapted", and the new `IsLabel (r -> a)` instance "may conflict with existing instances elsewhere". Otherwise limited to code that opts in.
- **Observed:** GHC 8.2.1 changed `fromLabel :: Proxy# x -> a` to `fromLabel :: a`, so every user-written `IsLabel` instance from 8.0 had to change. The 8.2 migration guide documents it ("`fromLabel` type signature change", [migration guide 8.2](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/8.2)). The anticipated instance conflict did not happen, because the instance was left out of `base`.
- **Verdict:** As anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** Only `OverloadedLabels` users of GHC 8.0, the one release before, were affected.

### 29

**Revise Levity Polymorphism**
- **Implemented:** GHC 8.2.1, full (Phabricator D2842).
- **Anticipated:** "The renaming is indeed gratuitous. But it still seems early enough in the adoption of this feature that we can do this." The proposal notes that the renamed names (`PtrRepLifted`→`LiftedRep`, `PtrRepUnlifted`→`UnliftedRep`, `VoidRep`→`TupleRep '[]`, and the parameterised `TupleRep`/`SumRep`) are exported only from `GHC.Types`/`GHC.Exts`, so only users of experimental features are affected. No level given (pre-2023 template).
- **Observed:** In 8.2, code that named the old `RuntimeRep` constructors stopped compiling. Libraries added CPP: `primitive` (`Data/Primitive/Internal/Operations.hs`), `structs`, and `text-show` (`TextShow/Data/Typeable.hs`) still carry `PtrRepUnlifted`/`PtrRepLifted` branches (GitHub code search). Proposal #203 later confirms that `primitive` "already [has] some CPP … for the RuntimeRep data constructor rename between GHC 8.0 and GHC 8.2". The 8.2 migration guide and release notes do not mention the rename.
- **Verdict:** `As anticipated`
- **Warning period:** `No`
- **Catalog:** —
- **Notes:** GHC internals (`GHC.Types`/`GHC.Exts`). The rename landed without deprecation synonyms.

### 32

**Declare `Constraint` is not apart from `Type`**
- **Implemented:** GHC 9.4.1, full. Commit [c8652a0a](https://github.com/ghc/ghc/commit/c8652a0afc3d8b56d39f39ff587271dcc46b17ba) closed [#21092](https://gitlab.haskell.org/ghc/ghc/-/issues/21092). The 9.4.1 release notes and migration guide do not mention it. Verified: 9.4.8 and 9.14.1 reject `type instance F Type = Int; type instance F Constraint = Bool` as "Conflicting family instance declarations".
- **Anticipated:** Not discussed as breakage. "Effect and Interactions" says that pairs of instances or type-family equations for `Type` and `Constraint` "would be rejected", and that `Equals Type Constraint` would get stuck.
- **Observed:** None found as an upgrade regression. The only report is [#25663](https://gitlab.haskell.org/ghc/ghc/-/issues/25663) (9.12.1, new code), closed as intended behaviour. Checked: GitLab searches "Constraint apart Type" and "Conflicting family instance Constraint", and the 9.4 notes and migration guide.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** Kept by #518 in 9.6 (`TYPE` and `CONSTRAINT` apart, but `Type` and `Constraint` not apart). [!15049](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/15049) ("Make TYPE and CONSTRAINT apart again", milestone 10.0.1) and [#24279](https://gitlab.haskell.org/ghc/ghc/-/issues/24279) continue the work.

### 35

**Make unboxed tuple patterns lazy / warn on unbanged strict patterns**
- **Implemented:** GHC 8.2.1, full ([Phabricator D2842](https://phabricator.haskell.org/D2842)). `-Wunbanged-strict-patterns` is documented "since 8.2". The proposal was accepted after the fact, in 2018.
- **Anticipated:** A change in semantics: unboxed-tuple patterns that bind no unlifted variable become lazy, which "could introduce hitherto-unexpected laziness". Change (B) turns a required bang into a warning so that change (A) does not "break code in the wild".
- **Observed:** None found (checked: 8.2.1 release notes, migration guides 8.0–10.2, GitLab search).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** Applies only to `UnboxedTuples` and `UnboxedSums`, so it is outside Haskell 2010.

### 37

**Hexadecimal Floats in Haskell**
- **Implemented:** GHC 8.4.1, opt-in `HexFloatLiterals` ([#13126](https://gitlab.haskell.org/ghc/ghc/issues/13126)). GHC 9.12 extended it to `Float#`/`Double#` literals.
- **Anticipated:** The proposal says the `Read` instance would change: `reads "0x1p3" :: [(Double,String)]` would give `[(8.0,"")]` instead of `[(1.0,"p3")]`, and no language pragma could guard this.
- **Observed:** None found. The anticipated `Read` change never shipped: `reads "0x1p3"` still gives `[(1.0,"p3")]` on 9.4.8 and 9.14.1. (Checked: 8.4.1 notes, migration guides, local test.)
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** Without the extension, `0x1p4` still lexes as `0x1` applied to `p4`, as the report says (witness `HexFloatLiterals.hs`).

### 42

**Pattern synonym construction function signatures**
- **Implemented:** Not implemented ([#14602](https://gitlab.haskell.org/ghc/ghc/issues/14602) is still open).
- **Anticipated:** Not discussed. The proposal expects no notable interactions.
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 54

**Standalone kind signatures**
- **Implemented:** GHC 8.10.1, full ([#16794](https://gitlab.haskell.org/ghc/ghc/-/issues/16794), [!1438](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/1438)).
- **Anticipated:** Not discussed. The feature is new syntax behind `StandaloneKindSignatures`, and the proposal says "Template Haskell will need to be updated accordingly". It planned to turn `-XCUSKs` off by default in 8.8.
- **Observed:** None found. Template Haskell gained the `KiSigD` constructor, which is additive. Checked: the 8.10.1 notes, the 8.10 migration guide, and GitLab searches on `StandaloneKindSignatures` regressions (all bug reports on the new feature).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** `CUSKs` is still on by default in 9.14.1, so the planned switch-off never happened. The related `-Wmissing-kind-signatures` (9.2) is the main offender in W4 (`-Weverything`), but the proposal did not cause that.

### 55

**More explicit `forall`s**
- **Implemented:** GHC 8.8.1, full ([#2600](https://gitlab.haskell.org/ghc/ghc/issues/2600), [#14268](https://gitlab.haskell.org/ghc/ghc/issues/14268)). Adds explicit `forall` to type family instances and `RULES`.
- **Anticipated:** "Given that `forall` is a keyword in types with `ExplicitForAll`, this change is fully backward-compatible."
- **Observed:** The Template Haskell AST broke in template-haskell 2.15 (GHC 8.8). `DataInstD`, `NewtypeInstD`, `TySynEqn` and `RuleP` gained a `Maybe [TyVarBndr]` field, and `tySynEqn` changed type. This is documented in the [8.8 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/8.8), which attributes it jointly with visible kind application (#15).
- **Verdict:** Not anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** Source code was unaffected. Only TH users broke, and a mechanical fix (`Nothing`) works.

### 63

**Overhaul deriving instances for empty data types**
- **Implemented:** GHC 8.4.1, full: the `EmptyDataDeriving` extension and new code for derived instances of empty types ([#7401](https://gitlab.haskell.org/ghc/ghc/-/issues/7401), [#10577](https://gitlab.haskell.org/ghc/ghc/-/issues/10577), [#13117](https://gitlab.haskell.org/ghc/ghc/-/issues/13117)).
- **Anticipated:** Costs and Drawbacks says derived instances for empty types change semantics "in a very slight (and benign) way": derived `Eq` returns `True` instead of calling `error`, and derived `Show` diverges (forces its argument) instead of calling `error`. It calls this "a very simple change to accommodate". No level given.
- **Observed:** The semantic change shipped as described, and the [8.4 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/8.4) ("Deriving for empty data types") documents it. An implementation bug, [#14692](https://gitlab.haskell.org/ghc/ghc/-/issues/14692) (derived `Show` cased on the wrong argument), was fixed before 8.4.1 shipped. I found no reports of user code breaking (checked: the 8.4 migration guide, the [8.4.1 notes](https://downloads.haskell.org/ghc/8.4.1/docs/html/users_guide/8.4.1-notes.html), and a GitLab search for "EmptyDataDeriving").
- **Verdict:** As anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** The change is a run-time semantic change with no warning, but it only turns `error` calls into `True` or into a forced `⊥`.

### 65

**Require namespacing fixity declarations for type names and `WARNING`/`DEPRECATED` pragmas**
- **Implemented:** GHC 9.10.1, partial ([MR !12012](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/12012); [#14032](https://gitlab.haskell.org/ghc/ghc/issues/14032) is still open). Only the optional `type`/`data` specifiers under `ExplicitNamespaces` exist. The planned warnings, and the later error for un-namespaced fixities of type names, are not implemented.
- **Anticipated:** "This will involve a deprecation/breakage cycle, so there will inevitably be some pain". It planned a warning in 8.(X+4) and an error in 8.(X+6), following the three-release policy. It did not discuss Template Haskell.
- **Observed:** Template Haskell's `InfixD` gained a `NamespaceSpecifier` field in template-haskell 2.22 (GHC 9.10). This broke TH code that builds or matches fixity declarations. It is not mentioned in the 9.10.1 release notes or the 9.10 migration guide.
- **Verdict:** Not anticipated
- **Warning period:** No
- **Catalog:** A6
- **Notes:** The breakage the proposal did announce, the deprecation cycle, has not happened. The breakage that did happen, to the TH API, was not foreseen.

### 71

**Extend `-Wall` with `incomplete-uni-patterns` and `incomplete-record-updates`**
- **Implemented:** GHC 9.2.1, full ([#15656](https://gitlab.haskell.org/ghc/ghc/-/issues/15656)). The 9.2.1 release notes do not mention it. I confirmed both warnings fire under `-Wall` on 9.4.8 and 9.8.4.
- **Anticipated:** "Existing code compiled with `-Wall` will start warning". Costs are described as minimal. Breakage is not otherwise discussed.
- **Observed:** Breakage came only through `-Werror` (warning-induced). An industrial user hit it on 8.10 → 9.2 (catalog W5). `-Wincomplete-record-updates` silently stopped firing in 9.6 ([#23520](https://gitlab.haskell.org/ghc/ghc/-/issues/23520)) and came back in 9.8.1, so 9.6 → 9.8 upgrades can trip it again. The 9.2 migration guide covers the uni-pattern warning on irrefutable patterns. A spurious `-Wincomplete-uni-patterns` under `-finfo-table-map` ([#27314](https://gitlab.haskell.org/ghc/ghc/-/issues/27314)) is fixed in 10.0.1.
- **Verdict:** As anticipated
- **Warning period:** n/a
- **Catalog:** W5
- **Notes:** Warnings only. The change was left out of the 9.2.1 release notes.

### 74

**Add more fixed size primitive types, like Int8#/Word8#**
- **Implemented:** Full, over several releases: `Int8#`/`Word8#` in GHC 8.8 (D5006), `Int16#`/`Word16#` in 8.10 (D5258), `Int32#`/`Word32#` in 9.2. `Int64#`/`Word64#` already existed on 32-bit platforms.
- **Anticipated:** Costs are given as implementation effort only: "nothing is likely to change after implementation". Redefining `Int8`…`Word32` on top of the new primitives, and removing the `narrow` primops, are explicitly ruled out of scope: "not part of this proposal … should be a separate proposal to the libraries committee". No level given.
- **Observed:** Adding the types broke nothing. The follow-up that the proposal deferred broke a good deal of code. It shipped in GHC 9.2 (ghc-prim 0.8 / base 4.16) as a GHC change motivated by Darwin/AArch64 FFI conventions, with no CLC proposal:
  - `Int{8,16,32}`/`Word{8,16,32}` now wrap the sized primitives (`data Int8 = I8# Int8#`).
  - `index/read/write{Int,Word}<N>Array#` now return the sized types.
  - `narrow{Int,Word}<N>#` was renamed to `intTo{Int,Word}<N>#`.

  The 9.2 migration guide documents this ("Sized Word/Int use sized Word#/Int# primitives"). Example: `basement` failed to build on 9.2 with "Couldn't match expected type 'Word32#' with actual type 'Word#'" (https://github.com/haskell-foundation/foundation/issues/554). Some sub-word miscompilations followed later, e.g. #25653 (`mod` on `Word8` wrong in 9.12) and #26711 (sub-word division broken in 9.12.3).
- **Verdict:** `No breakage found`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** GHC internals. B3 and E3 (`Int64`/`Word64` wrapping `Int64#`/`Word64#`, 9.4) are not rooted here. That change came from #11953/#11470, and the 64-bit primitives predate #74. The verdict covers #74 as scoped. The 9.2 `Word8#` rewiring it enabled was breaking and came with no warning period.

### 76

**Underscores in Numeric Literals**
- **Implemented:** GHC 8.6.1, opt-in `NumericUnderscores` ([#14473](https://gitlab.haskell.org/ghc/ghc/issues/14473)). Part of GHC2021.
- **Anticipated:** Not discussed beyond "Compatibility can be handled with language extension of `NumericUnderscores`."
- **Observed:** None found (checked: 8.6.1 notes, 8.6 migration guide, GitLab search).
- **Verdict:** No breakage found
- **Warning period:** No
- **Catalog:** —
- **Notes:** The implementation also changed GHC's behaviour with the extension off, which makes this a Haskell 2010 deviation. `1_000` (the report reads it as `1` applied to `_000`) is rejected under `-XHaskell2010` with "Illegal underscores in integer literals" (witness `NumericUnderscores.hs`; reproduced on 9.4.8).

### 77

**Deprecating STM invariant mechanism**
- **Implemented:** `always`, `alwaysSucceeds` and `checkInv` deprecated in GHC 8.4 (base 4.11, #14324), and removed in GHC 8.6 (base 4.12, RTS support dropped). Full.
- **Anticipated:** "The removal of the interfaces will break any existing users." The plan was to deprecate in 8.4 and remove "three major releases later". No level given.
- **Observed:** Code using `always`/`alwaysSucceeds` breaks in 8.6, as intended. The 8.6.1 release notes and the base-4.12 changelog say the removal "happened a bit earlier than proposed in the deprecation pragma included in GHC 8.4, but due to community feedback we decided to move ahead with the early removal". No reports of affected packages found (checked: GitLab title search, the 8.4/8.6 migration guides).
- **Verdict:** `As anticipated`
- **Warning period:** `Yes`
- **Catalog:** —
- **Notes:** The deprecation lasted one release instead of the three announced in the pragma.

### 80

**Type-level type applications**
- **Implemented:** GHC 8.8.1, full ([#12045](https://gitlab.haskell.org/ghc/ghc/issues/12045)). It shipped as "visible kind applications".
- **Anticipated:** Not discussed. The proposal only describes new syntax.
- **Observed:** None found. Checked: the 8.8.1 notes and the 8.8 migration guide.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 81

**A syntax for visible dependent quantification**
- **Implemented:** GHC 8.10.1, full, for kinds only (`forall k ->`, [#16326](https://gitlab.haskell.org/ghc/ghc/issues/16326)).
- **Anticipated:** Not discussed: "Shouldn't be any untoward interactions. Template Haskell will have to be updated".
- **Observed:** One later change of behaviour. In GHC 9.2, `NoPolyKinds` modules default arguments bound by a visible `forall ->` to `Type` (`y2 :: T2 Type` instead of `T2 a`). The [9.2 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.2) calls this "a breaking change" for code that relies on the old behaviour. It only affects clients of types with VDQ kinds. TH gained `ForallVisT`, which is additive.
- **Verdict:** Not anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** Minor and niche. It comes from later defaulting work, not from the 8.10 implementation itself.

### 83

**Embrace `Type :: Type`**
- **Implemented:** GHC 8.6.1 merged `TypeInType` into `PolyKinds`/`DataKinds` and added `StarIsType` ([#15195](https://gitlab.haskell.org/ghc/ghc/issues/15195)). `TypeInType` was deprecated in GHC 9.6.1 (`-Wdeprecated-flags`, [#20312](https://gitlab.haskell.org/ghc/ghc/-/issues/20312)). Full.
- **Anticipated:** Yes. Code using `*` as a binary type operator, such as `GHC.TypeLits.*`, "will need to explicitly enable `-XNoStarIsType`". Modules using `*` both as an operator and as a kind must switch to `Type`. The CUSK rule changes to the `TypeInType` one ("adding an explicit `forall k` in some cases"). `TypeInType` would be deprecated two releases later. "For most users, no migration will be necessary."
- **Observed:**
  - 8.6: `Proxy (m * n)` with `GHC.TypeLits` stops type-checking because `*` now means `Type`. The fix is to qualify `*` or use `NoStarIsType`, which needs CPP or a cabal conditional ([8.6 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/8.6), [#15857](https://gitlab.haskell.org/ghc/ghc/-/issues/15857)).
  - 8.6: CUSKs under `PolyKinds` now need kind variables quantified explicitly. "PolyKinds is pickier" ([8.6.1 notes](https://downloads.haskell.org/ghc/8.6.1/docs/users_guide/8.6.1-notes.html)).
  - 9.6: the `TypeInType` deprecation warning breaks `-Werror` builds. `DataKinds` alone is not a replacement (W10).
- **Verdict:** As anticipated
- **Warning period:** Partial (no warning before the 8.6 `*` change; the `TypeInType` deprecation is only a warning so far)
- **Catalog:** W10
- **Notes:** Amended by [#146](https://github.com/ghc-proposals/ghc-proposals/pull/146), which dropped "TypeOperators implies NoStarIsType". The deprecation planned for "two releases after" (about 8.10) came in 9.6. The later `*` warnings belong to #143 (W2).

### 90

**BlockArguments Extension**
- **Implemented:** GHC 8.6.1, opt-in `BlockArguments` ([#10843](https://gitlab.haskell.org/ghc/ghc/issues/10843)).
- **Anticipated:** "The proposed extension does not change the meaning of any valid program. It just accepts more programs."
- **Observed:** None found (checked: 8.6.1 notes, migration guides, GitLab search).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 94

**As patterns in pattern synonyms**
- **Implemented:** GHC 8.6.1 ([#9793](https://gitlab.haskell.org/ghc/ghc/-/issues/9793)).
- **Anticipated:** "None that I can see. It just lifts a restriction."
- **Observed:** None found (checked: 8.6 migration guide, GitLab).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 98

**Unlifted Newtypes**
- **Implemented:** GHC 8.10.1, full (#15219).
- **Anticipated:** Not discussed beyond losing the `#`-suffix naming convention. The proposal requires `coerce` to become levity-polymorphic.
- **Observed:** None found (checked: the 8.10 migration guide and release notes, GitLab "UnliftedNewtypes" issues). The reported bugs (#16827, #16828, #25611) affect only code that enables the extension.
- **Verdict:** `No breakage found`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** Opt-in (`-XUnliftedNewtypes`).

### 99

**Explicit specificity in type variable binders**
- **Implemented:** GHC 9.0.1, full ([#16393](https://gitlab.haskell.org/ghc/ghc/issues/16393)). Template Haskell changed in template-haskell 2.17.
- **Anticipated:** "This change is fully backward-compatible." Template Haskell is not discussed.
- **Observed:**
  - 9.0: TH's `TyVarBndr` became `TyVarBndr flag`, with `PlainTV n flag` and `KindedTV n flag k`. `ForallT` takes `TyVarBndr Specificity`, and most other sites take `TyVarBndr ()`. This broke every TH library that builds or matches binders, and they needed CPP or [th-abstraction 0.4](https://hackage.haskell.org/package/th-abstraction-0.4.0.0/docs/Language-Haskell-TH-Datatype-TyVarBndr.html)'s compatibility module ([9.0 migration guide, "template-haskell-2.17"](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.0)).
  - 9.0: field selectors no longer make inferred variables available for type application. This is related but separate ("Type variable order in top-level field selectors").
- **Verdict:** Not anticipated
- **Warning period:** No
- **Catalog:** — (the same pattern recurs in 9.8 as A4)
- **Notes:** Source-level Haskell was unaffected. All the breakage is in the TH AST.

### 103

**Treat kind variables and type variables identically in `forall`**
- **Implemented:** GHC 8.10.1, full. The release notes cite it as "proposal #24". `-Wimplicit-kind-vars` was added to `-Wcompat` in 8.6.1 ([#15264](https://gitlab.haskell.org/ghc/ghc/issues/15264)) and made obsolete in 8.10.
- **Anticipated:** "This will not be backward compatible". A signature with an explicit `forall` that mentions an unbound kind variable would be rejected. The plan was a `-Wcompat` warning, then an error two releases after #83.
- **Observed:** The [8.10 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/8.10) and [8.10.1 notes](https://downloads.haskell.org/ghc/8.10.1/docs/users_guide/8.10.1-notes.html) list four breaking changes, all under the #103 banner:
  1. The `forall` case the proposal described, which got the `-Wcompat` warning.
  2. Kind variables are no longer implicitly quantified in data constructor declarations.
  3. Implicit kind variables are no longer put first. This reorders type variables and "is a breaking change for users of TypeApplications".
  4. Free variables on the right-hand side of type synonyms and type family equations are no longer quantified unless they appear in an outermost kind annotation.

  Items 2–4 had no warning.
- **Verdict:** Worse than anticipated
- **Warning period:** Partial (only the `forall` case was warned under `-Wcompat`)
- **Catalog:** —

### 106

**Define kinds without promotion (`type data`)**
- **Implemented:** GHC 9.6.1, full (`TypeData`, [#6024](https://gitlab.haskell.org/ghc/ghc/-/issues/6024)).
- **Anticipated:** Not discussed ("no known draw-backs").
- **Observed:** None found. Template Haskell gained `TypeDataD`, which is additive. Checked: the 9.6.1 notes, the 9.6 migration guide, and a GitLab search.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 107

**Source plugins**
- **Implemented:** GHC 8.6.1, full (#14709).
- **Anticipated:** "No existing functionality is changed". The proposal says the change affects only users who opt into plugins. No level given.
- **Observed:** None found (checked: the 8.6.1 release notes, GitLab "source plugin" issues). The `Plugin` record gained fields (8.6 notes, "ghc library"). Plugins built from `defaultPlugin` are unaffected. Pre-release bugs (#15234) were fixed before 8.6.1.
- **Verdict:** `No breakage found`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** GHC internals (the `ghc` package plugin API).

### 108

**Refining the plugin recompilation API**
- **Implemented:** GHC 8.6.1 (`pluginRecompile`, `PluginRecompile`; #7414).
- **Anticipated:** Discusses only plugin authors choosing the wrong fingerprint. `defaultPlugin` keeps `ForceRecompile`, so existing plugins behave as before. No level given.
- **Observed:** The 8.6 implementation had a recompilation-avoidance bug: GHC did not recompile when a module switched from an impure plugin to a pure plugin or to none, leaving stale build output. This is #15858 (filed November 2018, fixed in 8.8.1). Pre-release panics (#15475, #15492, #15564) were fixed for 8.6.1. Later transitivity gaps were reported in #19772 and #20417.
- **Verdict:** `Not anticipated`
- **Warning period:** `No`
- **Catalog:** —
- **Notes:** A bug, not a design break. API changes are GHC internals.

### 109

**Quantified constraints**
- **Implemented:** GHC 8.6.1, full ([#2893](https://gitlab.haskell.org/ghc/ghc/issues/2893)).
- **Anticipated:** Not discussed ("no known drawbacks"). The extension is opt-in.
- **Observed:**
  - 9.0: new validity checks reject quantified constraints that 8.x accepted unless `FlexibleContexts` etc. is on, e.g. `(forall a. Show (F a)) => Int` ([9.0 migration guide, "More validity checking in quantified constraints"](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.0)).
  - 9.0.2/9.2.2: a solver regression for quantified-constraint instance contexts that 8.10.7 accepted ([#21550](https://gitlab.haskell.org/ghc/ghc/-/issues/21550)).
- **Verdict:** Not anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** Both items affect only users of `QuantifiedConstraints`. The 9.6 library breakage from new quantified superclasses (`Eq1`…, `Bifunctor`, transformers' `MonadTrans`) comes from library decisions that use the feature, not from the proposal.

### 111

**Linear Types**
- **Implemented:** GHC 9.0.1 as a "technology preview" ([#15981](https://gitlab.haskell.org/ghc/ghc/-/issues/15981)). The extension kept changing in 9.2, 9.10, 9.14 and 10.0.1.
- **Anticipated:** The proposal says it "does not modify Haskell for those who don't want to use it". The committee's acceptance conditions include "All programs accepted today must be accepted when `-XLinearTypes` is not in effect". A library exporting first-order linear functions only burdens consumers with η-expansion. The design is a preview, but later breakage for users of the extension is not discussed.
- **Observed:** I found no breakage of programs that do not enable `LinearTypes` (checked: the 9.0 migration guide, the 9.0.1 notes, and GitLab and web searches for multiplicity errors without the extension). Users of the extension did break:
  - 9.10: a failable pattern in linear `do` no longer consumes the value (L3). The cause is the `do`-expansion rework [!10140](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/10140), not #111 itself.
  - 10.0.1 ([migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/10.0), notes): multiplicity-polymorphic arrows need a kind annotation, `forall (m :: Multiplicity)`. Some `let %1` patterns with `-XStrict` parse differently or are rejected under the new modifier syntax.
  - template-haskell 2.17 (9.0) added `MulArrowT` to the TH `Type` AST, and the GHC API's `FunTy` gained a multiplicity. This is ordinary TH and GHC API churn.
- **Verdict:** No breakage found
- **Warning period:** No
- **Catalog:** L3 (related, but its root cause is MR !10140)
- **Notes:** The promise to non-users held. The breakage falls on users of an experimental extension.

### 112

**UnliftedArray**
- **Implemented:** GHC 9.4.1, in a different form: `Array#`/`SmallArray#`/`MutVar#` etc. became levity-polymorphic, with no separate `UnliftedArray#` (#14196). `ArrayArray#` was moved out of `GHC.Prim` into `GHC.Exts` and deprecated.
- **Anticipated:** "It is entirely backward-compatible for those who import `GHC.Exts` instead of `GHC.Prim`". No level given.
- **Observed:** As predicted, only code importing from `GHC.Prim` broke. The 9.4.1 release notes say "ArrayArray# and its operations are no longer exported from GHC.Prim and are deprecated". The 9.4 migration guide adds that the `same*#` pointer-equality primops moved from `GHC.Prim` to `GHC.Exts` and that importers must switch modules. Remaining `ArrayArray#` users get deprecation warnings. No package-level reports found (checked: GitLab "ArrayArray"/"UnliftedArray", GitHub issue search).
- **Verdict:** `As anticipated`
- **Warning period:** `No`
- **Catalog:** —
- **Notes:** GHC internals (ghc-prim). Shipped together with stage 2 of #203 (levity-polymorphic primops).

### 120

**Deriving Via**
- **Implemented:** GHC 8.6.1, full ([#15178](https://gitlab.haskell.org/ghc/ghc/-/issues/15178)).
- **Anticipated:** "No existing code will break because of `DerivingVia`, as programmers must consciously choose to make use of it." The `via` keyword is required.
- **Observed:** None found (checked: the 8.6 migration guide, the 8.6.1 notes, and GitLab issue #15178). The 9.0 migration guide's rejection of nested `forall`s in `via` types comes from a later, separate change.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 121

**Offer more array resizing primitives**
- **Implemented:** Partial. GHC 8.10.1 added `shrinkSmallMutableArray#` and `getSizeofSmallMutableArray#` (MR !1599), plus a library-level `resizeSmallMutableArray#` in `GHC.Exts`. Nothing was added for the boxed `MutableArray#`.
- **Anticipated:** "`sizeofMutableArray#`, `sizeofSmallMutableArray`, and `sizeofMutableUnliftedArray#` will cease to be reliable and we will have to add analogues of `getSizeofMutableByteArray#` to supplant them. This will break existing user code, but I doubt most of it will be very hard to fix."
- **Observed:** `sizeofSmallMutableArray#` was documented as deprecated in 2020 (commit 1b508a9). GHC began emitting a `-Wdeprecations` warning ("Use 'getSizeofSmallMutableArray#' instead") only in 9.12; checked locally, 9.10.3 is silent and 9.12.2 warns. That breaks only `-Werror` builds. The primop has not been removed.
- **Verdict:** `As anticipated`
- **Warning period:** `Yes`
- **Catalog:** —
- **Notes:** GHC internals. The impact was smaller than predicted: the proposal expected breakage, but in practice users got a deprecation warning.

### 125

**Type Annotated Quoters**
- **Implemented:** Not implemented. The proposal has no ticket and no `implemented` field. `TQuasiQuoter` is absent from every template-haskell changelog through 2.24, and a GitLab search finds no issue or MR.
- **Anticipated:** Not discussed. The proposal only adds a new type.
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 126

**Type applications in patterns**
- **Implemented:** GHC 9.2.1, constructor patterns only, under `TypeApplications` plus `ScopedTypeVariables` ([#11350](https://gitlab.haskell.org/ghc/ghc/issues/11350)). The metadata says "not implemented", which is wrong.
- **Anticipated:** Not discussed beyond a possible future clash with extended as-patterns.
- **Observed:** None found from the 9.2 implementation itself, since the syntax was previously a parse error. Checked: the 9.2 notes and migration guide.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** — (the feature's later removal from `ScopedTypeVariables` is L2, rooted in #448/#604)
- **Notes:** #448 superseded this proposal's semantics and #604 moved the feature to `TypeAbstractions`. Code written against #126 broke in 9.14 (L2).

### 128

**Allow ScopedTypeVariables to refer to types**
- **Implemented:** GHC 8.8.1, full ([#15050](https://gitlab.haskell.org/ghc/ghc/issues/15050)).
- **Anticipated:** Not discussed. It only lifts a restriction.
- **Observed:** None found. Checked: the 8.8.1 notes and migration guide.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 134

**Deprecating Exports**
- **Implemented:** GHC 9.8.1, full ([#4879](https://gitlab.haskell.org/ghc/ghc/-/issues/4879), [!10283](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/10283)). The 9.8.1 notes confirm it.
- **Anticipated:** "this should not cause any side-effects as the GHC could only display warning messages". No level given.
- **Observed:** None found (checked: the 9.8 migration guide, the 9.8.1 notes, and a GitLab search for deprecated exports). The amendment [ghc-proposals#595](https://github.com/ghc-proposals/ghc-proposals/pull/595) is still open. It records subtleties found during implementation: which entities count as deprecated with mixed implicit and explicit exports, and emitting every message when a name is in scope several ways.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** The feature produces warnings only. The amendment documenting the implemented semantics has not been merged.

### 143

**Remove the `*` kind syntax**
- **Implemented:** Partial. `-Wstar-is-type` was added in 8.6, put in `-Wcompat` in 8.8.1, in `-Wall` in 9.0.1, and turned on by default in 9.6.1 ([#22759](https://gitlab.haskell.org/ghc/ghc/-/issues/22759)). `StarIsType` is still on in 9.14.1. The final steps (switch it off, deprecate it, remove it) have not happened.
- **Anticipated:** Explicit. "less than 25% of packages published on Hackage will be affected", "the breakage is not silent", with a release-by-release schedule that turns `StarIsType` off about 7 years in.
- **Observed:** So far only warnings: builds with `-Werror` or `-Wall -Werror` broke in 9.0 and 9.6 (W2). No hard breakage yet. Checked: the 8.8, 9.0 and 9.6 notes, and GitLab (#15857, #19570, #23962 are about printing and messages).
- **Verdict:** As anticipated
- **Warning period:** Yes
- **Catalog:** W2
- **Notes:** The schedule has slipped. The step from `-Wall` to on by default took 3 releases rather than "two more releases, do nothing". GHC still prints kinds with `*` (#19570).

### 149

**Replace the atomicModifyMutVar# primop**
- **Implemented:** GHC 8.8.1 (commit af9b744, D4884, #15364). Adds the primops `atomicModifyMutVar2#` and `atomicModifyMutVar_#`. `atomicModifyMutVar#` became an ordinary function in `GHC.Exts`.
- **Anticipated:** "I don't foresee any significant interactions." The drawbacks section warns that the selector-thunk implementation could, in principle, cause space leaks.
- **Observed:** No build breakage found. Code importing `atomicModifyMutVar#` from `GHC.Prim` would break, but the name stays in `GHC.Exts`. The selector-thunk design did show up in one behaviour report: after `atomicModifyIORef'` the `IORef` holds a selector thunk, which confuses `nothunks`/`ghc-heap` users (#20823, 2021, closed). #23005 notes that the three successive implementations of `atomicModifyIORef'` differ in when the new value is installed relative to forcing it.
- **Verdict:** `No breakage found`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** GHC internals. `atomicSwapMutVar#` came later, via CLC proposal 139.

### 155

**Binding type variables in lambda-expressions**
- **Implemented:** GHC 9.10.1 (`\ @a ->` and `f @a x = …` under `TypeAbstractions`, [#17594](https://gitlab.haskell.org/ghc/ghc/issues/17594)). It shipped "in accordance with #448".
- **Anticipated:** Not discussed beyond parsing notes (`\@` stays an operator).
- **Observed:** None found. Template Haskell gained `InvisP` ([9.10 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.10)), which is additive. Checked: the 9.10 notes and migration guide, and GitLab.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 158

**Add `setField` to `HasField`**
- **Implemented:** Not implemented. Superseded by #583, which shares its tracking ticket [#16232](https://gitlab.haskell.org/ghc/ghc/-/issues/16232).
- **Anticipated:** Not discussed. The proposal removes `getField` from `HasField` and replaces it with `hasField`, which would break every user-written `HasField` instance. #583 later says so: the earlier design "would break all user-defined `HasField` instances".
- **Observed:** None. It was never released.
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** #516 calls out that its warning design assumes #158 is not implemented as specified.

### 160

**NoFieldSelectors**
- **Implemented:** GHC 9.2.1, full (`FieldSelectors` on by default, `NoFieldSelectors` opt-in). Ticket [#5972](https://gitlab.haskell.org/ghc/ghc/-/issues/5972).
- **Anticipated:** "Breakage estimation": turning the extension on breaks Template Haskell code that assumes a selector exists. The default is unchanged.
- **Observed:** None found (checked: 9.2.1 release notes, 9.2 migration guide, GitLab issue search for `NoFieldSelectors`). It is opt-in.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 163

**Remove an undocumented StableName guarantee**
- **Implemented:** Not implemented. The RTS still has `rts/StableName.c` and the `stable_name_table`, and the proposal's `implemented` field is empty.
- **Anticipated:** "Any code relying on the de facto guarantee will break, probably silently, and probably intermittently."
- **Observed:** n/a. The unrelated #27693 (2026: the non-moving collector gives different objects the same StableName) is a bug, not this change.
- **Verdict:** `Not implemented`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** —

### 166

**List instances for a type in GHCi**
- **Implemented:** GHC 8.10.1, full (`:instances`, #15610).
- **Anticipated:** "Because it is a GHCi command, it won't have any backwards compatibility or performance issues."
- **Observed:** None found (checked: the 8.10.1 release notes, the 8.10 migration guide).
- **Verdict:** `No breakage found`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** —

### 168

**Make rebindable `fail` work with overloaded strings**
- **Implemented:** GHC 8.8.1 ([#15645](https://gitlab.haskell.org/ghc/ghc/issues/15645)).
- **Anticipated:** "There may be a small number of libraries that fail to type-check", namely those combining `RebindableSyntax` and `OverloadedStrings` with a non-`String` `fail`. The proposal calls the change a bug fix.
- **Observed:** None found (checked: 8.8.1 notes, 8.8 migration guide, GitLab search "fail OverloadedStrings").
- **Verdict:** No breakage found
- **Warning period:** No
- **Catalog:** —

### 170

**Unrestricted Overloaded Labels**
- **Implemented:** GHC 9.6.1, full. [MR !8966](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/8966), ticket [#11671](https://gitlab.haskell.org/ghc/ghc/-/issues/11671).
- **Anticipated:** Under `OverloadedLabels` it "steals more syntax": `a#3`, `a#"foo"`, `a#'b'`, `a#Foo` change meaning.
- **Observed:** In 9.6.1-alpha1, `.` was allowed in labels, so `(#.)` stopped parsing as an operator under `OverloadedLabels`. This broke `optics-core` ([#22821](https://gitlab.haskell.org/ghc/ghc/-/issues/22821)). The proposal was amended to drop `.` ([ghc-proposals #573](https://github.com/ghc-proposals/ghc-proposals/pull/573), Feb 2023), and the fix landed before 9.6.1. `(#.)` with `OverloadedLabels` compiles on 9.8.4 and 9.14.1. The feature went undocumented in the user's guide until 9.6.4 ([#24249](https://gitlab.haskell.org/ghc/ghc/-/issues/24249)). No breakage reported after release.
- **Verdict:** As anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** The `(#.)` breakage was not anticipated. head.hackage caught it in an alpha, and the amendment fixed it before release.

### 173

**The dot type operator**
- **Implemented:** GHC 8.8.1 ([MR !363](https://gitlab.haskell.org/ghc/ghc/merge_requests/363)). The 8.8.1 notes say "`(!)` and `(.)` are now valid type operators".
- **Anticipated:** Costs: "None."
- **Observed:** None found (checked: 8.8.1 notes, 8.8 migration guide, GitLab search; `type (f . g) x` works on 9.4.8 and 9.14.1).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** This proposal motivated #193, which keeps `forall a.b` unambiguous.

### 174

**Lower precedence for `{-# UNPACK #-}`**
- **Implemented:** GHC 8.8.1 ([#14761](https://gitlab.haskell.org/ghc/ghc/issues/14761)). The 8.8.1 notes say "UNPACK annotation no longer requires parenthesization".
- **Anticipated:** "The change is conservative: strictly more programs will be accepted."
- **Observed:** None found (checked: 8.8.1 notes, migration guides).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 176

**Meaning-preserving parsing rules for SCC annotations**
- **Implemented:** GHC 9.0.1 ([#15730](https://gitlab.haskell.org/ghc/ghc/-/issues/15730)).
- **Anticipated:** "Some existing programs with annotations may require adding parentheses to compile."
- **Observed:** GHC 9.0.1 rejected SCC pragmas in previously accepted positions ("A pragma is not allowed in this position"), which broke `commonmark` ([#19325](https://gitlab.haskell.org/ghc/ghc/-/issues/19325)). The [9.0 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.0) documents exactly this case. The 9.0.1 release notes have no entry for the change. Reproduced: `1 / {-# SCC ann #-} 2 / 2` is rejected on 9.4.8 and 9.14.1.
- **Verdict:** As anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** Possibly a Haskell 2010 deviation. Report §12 says unrecognised pragmas should be ignored. GHC recognises `SCC`, but rejects the program even without profiling and under `-XHaskell2010`.

### 179

**Clean up printing of foralls**
- **Implemented:** Change (1), inferred variables printed in braces, is in GHC 9.0.1 ([!2540](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/2540)). Changes (2) and (3) are in GHC 9.2.1, done "partly by accident" in the Quick Look commit [97cff919](https://github.com/ghc/ghc/commit/97cff9190d346c3b51c32c88fd145fcf1e6678f1) and not in the 9.2.1 release notes. Tracking issue [#16320](https://gitlab.haskell.org/ghc/ghc/issues/16320) is still open.
- **Anticipated:** Users "might be surprised to see `:type +v` dropped". The proposal suggested an error message pointing to `:type`, and noted that more unsolved constraints may appear in `:type` output.
- **Observed:** `:type +v` was removed in 9.2. GHCi now prints "`:type +v' has gone; use `:type' instead" (verified on 9.4.8 and 9.14.1). GHCi scripts, doctests and documentation that use it break. 9.4 changed `:type` again so that it no longer instantiates inferred variables (9.4.1 notes).
- **Verdict:** As anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** This affects GHCi and output only, not compiled code. Golden or doctest outputs of `:type` changed in 9.0, 9.2 and 9.4.

### 190

**Allow `qualified` to follow module name**
- **Implemented:** GHC 8.10.1, opt-in `ImportQualifiedPost` ([MR !853](https://gitlab.haskell.org/ghc/ghc/merge_requests/853)). Part of GHC2021. `-Wprepositive-qualified-module` is off by default.
- **Anticipated:** "no discernible drawbacks". The proposal describes the change as purely additive.
- **Observed:** None found (checked: 8.10.1 notes, 8.10 migration guide).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 193

**Make `forall` a keyword**
- **Implemented:** GHC 8.8.1 ([MR !363](https://gitlab.haskell.org/ghc/ghc/merge_requests/363)). The 8.8.1 notes say "forall is now always a keyword in types".
- **Anticipated:** "This proposal would potentially break some existing programs, if any program uses a type variable spelled `forall`… This proposal author doubts the existence of any such programs in the wild." It also acknowledges that "it moves us further from the standard".
- **Observed:** None found (checked: 8.8.1 notes, 8.8 migration guide, GitLab search). Reproduced: `f :: forall -> forall` is rejected under `-XHaskell2010` on 9.4.8 and 9.14.1.
- **Verdict:** No breakage found
- **Warning period:** No
- **Catalog:** —
- **Notes:** This is a Haskell 2010 deviation; reference.md says it matches the revised report. The term-level change (`forall` as an identifier warns via `-Wforall-identifier` in 9.4 and is a parse error in 9.10, [#23719](https://gitlab.haskell.org/ghc/ghc/-/issues/23719)) comes from proposal #281, not #193. That change was announced with a warning period.

### 195

**Make Q (TExp a) into a newtype**
- **Implemented:** GHC 9.0.1, full (template-haskell 2.17, [#16177](https://gitlab.haskell.org/ghc/ghc/-/issues/16177)). Typed quotes have type `Quote m => Code m a`, and typed splices take `Code Q a`.
- **Anticipated:** "this will break all users of Typed Template Haskell who write type signatures. However, I feel like I am the only user so the impact will be minimal."
- **Observed:**
  - Every signature mentioning `Q (TExp a)` broke in 9.0.1 (9.0 migration guide, "Typed TH quotes and splices have different types").
  - The `Lift` method `liftTyped` changed type to `Code m t`. Hand-written `Lift` instances had been forced to define `liftTyped` in 8.10 (#209), so they had to change again one release later.
  - Ryan Scott wrote [th-compat](https://hackage.haskell.org/package/th-compat) (`Splice`, `liftSplice`, `examineSplice`) so code can compile across the change.
  - An industrial user reported it on 8.10 → 9.2 (catalog A7).
  - In 9.10 (template-haskell 2.22) the kind of `Code` changed again, which broke th-compat (A5).
- **Verdict:** Worse than anticipated
- **Warning period:** No
- **Catalog:** A7, A5 (follow-up)
- **Notes:** The proposal's estimate of a single user was wrong. Libraries and an industrial codebase needed CPP or th-compat.

### 203

**Pointer Rep**
- **Implemented:** Stage 1 in GHC 9.2.1: `LiftedRep`/`UnliftedRep` replaced by `BoxedRep Levity` (#17526). Stage 2 in 9.4.1: primops became levity-polymorphic (`forall {l :: Levity}`).
- **Anticipated:** "All code using `'LiftedRep` or `'UnliftedRep` will break", including `primitive`, and is "trivial to patch with CPP". The proposal recommended against shipping compatibility synonyms. It also claimed that inferred quantification would leave `TypeApplications` users of primops unaffected.
- **Observed:** As predicted, but softer: GHC shipped the synonyms `type LiftedRep = 'BoxedRep 'Lifted` and `type UnliftedRep = 'BoxedRep 'Unlifted` anyway (9.2 migration guide). Only code using the promoted, ticked constructors, or pattern-matching on `RuntimeRep`, broke. Packages that added `__GLASGOW_HASKELL__ >= 901` CPP for `BoxedRep` include `binary` (`Data/Binary/Class.hs`, the `Typeable`/`RuntimeRep` instances), `ghc-heap` and `template-haskell` (GitHub code search). The 9.2.1 release notes say "Code that references LiftedRep and UnliftedRep will need to be updated."
- **Verdict:** `As anticipated`
- **Warning period:** `No`
- **Catalog:** —
- **Notes:** GHC internals (`GHC.Exts`/`GHC.Types`). The synonyms made the breakage smaller than anticipated.

### 209

**Levity-polymorphic `Lift`**
- **Implemented:** GHC 8.10.1, full (template-haskell 2.16, [!789](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/789), merged 2019-04-19).
- **Anticipated:** Uses of `lift`, `TExp`, `unType`, `unTypeQ` and `unsafeTExpCoerce` with visible type applications break (`lift @Rational 1` must become `lift @_ @Rational 1`). Without a default for `liftTyped`, empty `Lift` instances "will crash as opposed to loop". There is "no way to write a CPP-free and backwards-compatible manual instance of `Lift`", which the proposal judges acceptable because `DeriveLift` exists.
- **Observed:** As anticipated. The 8.10 migration guide ("`Lift` changes") documents that the default `lift` is now `unTypeQ . liftTyped` rather than `liftData`. Instances that relied on the old `Data`-based default must define `liftTyped`, guarded by CPP, or use `DeriveLift`. I found no reports beyond this (checked: the 8.10 migration guide, the 8.10.1 notes and the template-haskell changelog).
- **Verdict:** As anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** Manual instances changed again in 9.0 (#195 and #246), so they broke twice in two releases. The default signature `r ~ 'LiftedRep` also caused compiler bugs: [#17723](https://gitlab.haskell.org/ghc/ghc/-/issues/17723) (an Iface Lint failure, fixed in 9.2.2) and [#19519](https://gitlab.haskell.org/ghc/ghc/-/issues/19519) (a 9.2 pre-release regression with `BoxedRep`, fixed before 9.2.1).

### 210

**MINIMAL should warn about extra definitions**
- **Implemented:** Not implemented. [#16314](https://gitlab.haskell.org/ghc/ghc/-/issues/16314) is open with no MR. On GHC 9.14.1, a class with `{-# MINIMAL foo #-}` and a default for `foo` produces no warning even with `-Weverything` (tested locally).
- **Anticipated:** "Drawbacks: I don't think there is any!" It would only add a new warning.
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 216

**Qualified do**
- **Implemented:** GHC 9.0.1, opt-in `QualifiedDo` ([#18214](https://gitlab.haskell.org/ghc/ghc/-/issues/18214)).
- **Anticipated:** Not discussed beyond "Enabling `-XQualifiedDo` doesn't change the meaning of existing do-expressions."
- **Observed:** None found (checked: 9.0.1 notes, 9.0 migration guide, GitLab search).
- **Verdict:** No breakage found
- **Warning period:** No
- **Catalog:** —
- **Notes:** This is a Haskell 2010 deviation: `M.do` (by the report, `M` composed with a `do` block) is rejected even with the extension off ("Illegal qualified ‘M.do’ block"; witness `QualifiedDo.hs`; reproduced on 9.4.8). ghc-proposals PR #722 (2025) clarified that no white space is allowed in `M.do`.

### 228

**Function Result Type Signatures**
- **Implemented:** Not implemented ([#18203](https://gitlab.haskell.org/ghc/ghc/issues/18203) is still open).
- **Anticipated:** Not discussed.
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 229

**Whitespace-sensitive operator parsing (~, !, @, $, $$, -)**
- **Implemented:** GHC 9.0.1 ([MR !1664](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/1664); [#1087](https://gitlab.haskell.org/ghc/ghc/-/issues/1087), [#17162](https://gitlab.haskell.org/ghc/ghc/-/issues/17162)). Amended by PR #293 (2019: suffix `@` is an error, plus `-Woperator-whitespace-ext-conflict`) and PR #368 (2021: `-Woperator-whitespace` in `-Wall`/`-Wcompat`). The warnings only arrived in 9.2.1 ([#18834](https://gitlab.haskell.org/ghc/ghc/-/issues/18834)). Contrary to #368, `-Woperator-whitespace` is still not in `-Wall` or `-Wcompat` in 9.14.1 (checked locally).
- **Anticipated:** Under Costs and Drawbacks: "It is a slight deviation from the standard… This may break existing programs. The migration strategy is to adjust whitespace". It lists `f ~ a ~ b`, `x !y`, `MkT ! Int` and `(!3)`, and says "not a backward compatible change in every corner case, but the migration path does not require `-XCPP`". It gives no estimate of the extent of breakage, no migration timeline, and no warnings before the break.
- **Observed:**
  - head.hackage [!62](https://gitlab.haskell.org/ghc/head.hackage/-/merge_requests/62) (Nov 2019) patched about 18 packages, including `Decimal`, `HTTP`, `hxt` (`:: ! T` fields), `alex`, `aivika`, `combinat`, `sop-core` (`x @ (p)` as-patterns), `regex-base`, `regex-compat` (`(!0)` sections), `mono-traversable` (`w@ ~(…)`), `shakespeare` (`($[])` under TH), `ghc-typelits-knownnat` (`Proxy @ a`) and `singletons`.
  - `cabal-install` needed a patch for `x @ (…)` in a module with no extensions. phadej asked for a revert in [#18251](https://gitlab.haskell.org/ghc/ghc/-/issues/18251); the issue is still open.
  - The 9.0.1 release notes omitted the change ([#19412](https://gitlab.haskell.org/ghc/ghc/-/issues/19412)); only the 9.0 migration guide lists it.
  - Industrial users still hit it on 8.10 → 9.2 upgrades (catalog L6).
  - The breakage prompted ghc-proposals issue #578 and PR #579, which added the Backward Compatibility section to the proposal template.
- **Verdict:** Worse than anticipated
- **Warning period:** No
- **Catalog:** L6, W4
- **Notes:**
  - #229 is the cause of two Haskell 2010 deviations in reference.md: `BangPatterns.hs` (`a !b = …`) and `StrictnessFlagSpace.hs`. No flag restores the report's reading.
  - Further report-valid programs that 9.4.8 and 9.14.1 reject under `-XHaskell2010` have no witness yet: `f ~ x = x` (lazy pattern followed by a space), `g x @ (Just y) = y` (as-pattern with spaces; `@` is a reservedop in the report), and `(!1)` (right section of `!`).

### 232

**Ambiguous Type per-signature pragma**
- **Implemented:** Not implemented (no ticket; GHC 9.14.1 does not recognise `{-# AMBIGUOUS #-}`).
- **Anticipated:** "Existing code using `AllowAmbiguousTypes` is not affected."
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 240

**Compile with threaded RTS by default**
- **Implemented:** Not implemented. Ticket #16126 is still open, and WIP MR !538 (2019) was never merged. Only the opt-out flag `-single-threaded` landed (#22795): it is present in 9.8.4 and absent in 9.4.8 (checked locally). The default is still the non-threaded RTS as of 9.14 and 10.0.1-alpha1.
- **Anticipated:** Performance changes, and a new warning for users who already pass `-threaded`, "which might be painful (e.g. in the `-Werror` setting)".
- **Observed:** n/a.
- **Verdict:** `Not implemented`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** Partial groundwork only: the `-single-threaded` flag.

### 242

**Unsaturated type families**
- **Implemented:** Not implemented. [#23193](https://gitlab.haskell.org/ghc/ghc/-/issues/23193) ("What happened with unsaturated type families?") is open.
- **Anticipated:** "aims to be backwards-compatible", but it names a break: `type S = 'MkT Maybe`, for `data T = MkT (Type -> Type)`, "is accepted today, but will be rejected". Choices on arity are "a breaking change".
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 246

**Overloaded Quotations**
- **Implemented:** GHC 9.0.1, full (template-haskell 2.17, [!2247](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/2247)). Untyped quotes have type `Quote m => m Exp`, `Lift` methods are generalised to `Quote m`, and the `Lib` combinators are generalised.
- **Anticipated:**
  - Generalising untyped brackets "does not seem like it will cause any significant breakage but it's hard to predict".
  - Unannotated top-level quotes fail under the monomorphism restriction.
  - "The main breakage" is `Lift` instances written in terms of `Q`, which "users should not define … anyway".
- **Observed:**
  - The 9.0 migration guide ("Overloaded Quotation Brackets") lists the same two breakages and recommends th-compat.
  - In practice, hand-written `Lift` instances whose helpers had `Q`-typed signatures needed rewriting.
  - Together with #195, this is the template-haskell 2.17 break reported by an industrial user (A7).
  - I found nothing worse than the proposal predicted (checked: the migration guide, the template-haskell changelog and th-compat).
- **Verdict:** As anticipated
- **Warning period:** No
- **Catalog:** A7
- **Notes:** It shipped in the same release as #195, so users met both changes at once.

### 265

**Unlifted Datatypes**
- **Implemented:** GHC 9.2.1, full (`-XUnliftedDatatypes`, #19523).
- **Anticipated:** Not discussed. Costs cover implementation effort and learnability only.
- **Observed:** None found (checked: the 9.2 release notes and migration guide, GitLab "UnliftedDatatypes"). Bugs such as segfaults in GHCi (#19628, #20849) affect only code that enables the extension.
- **Verdict:** `No breakage found`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** Opt-in.

### 274

**Quick Look Impredicativity**
- **Implemented:** GHC 9.2.1, full. Ticket [#18126](https://gitlab.haskell.org/ghc/ghc/-/issues/18126), MR !3220. Eager instantiation, which Quick Look relies on, landed in 9.0.1.
- **Anticipated:** No breakage section. The proposal keeps `($)` typed impredicatively without any flag "to maintain backward compatibility", because otherwise "many existing program … would suddenly fail to typecheck". It also replaces the old, unspecified `ImpredicativeTypes` ("changing … from one unspecified behavior to another").
- **Observed:**
  - 9.0.1: with eager instantiation, visible type application only works on a variable or an annotated expression, so `(let x = … in id) @Bool True` is rejected ([9.0 migration guide, "Eager instantiation"](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.0)).
  - 9.2.1: `$` combined with untyped TH splices regressed, as in `$([| MkFoo |]) $ \x -> x` ([#21038](https://gitlab.haskell.org/ghc/ghc/-/issues/21038), fixed in 9.2.2; [#21077](https://gitlab.haskell.org/ghc/ghc/-/issues/21077), fixed later by !10911). `do` notation behaves differently from its desugaring under `ImpredicativeTypes` ([#20651](https://gitlab.haskell.org/ghc/ghc/-/issues/20651)).
  - 9.12.1: a GADT/type-family program using `return $ False` was rejected ([#26030](https://gitlab.haskell.org/ghc/ghc/-/issues/26030), fixed in 9.14.1 by a shape test).
  - 9.14.1: that shape test made other uses of `$` fail ([#26543](https://gitlab.haskell.org/ghc/ghc/-/issues/26543), backported to 9.14.2). A further `$` regression after 9.14.1 was caught before release ([#27630](https://gitlab.haskell.org/ghc/ghc/-/issues/27630)).
- **Verdict:** Worse than anticipated
- **Warning period:** No
- **Catalog:** X2
- **Notes:** The special rule for `$` that was kept for compatibility is where the regressions keep appearing (9.2, 9.12, 9.14).

### 277

**Add winapi pseudo calling convention**
- **Implemented:** Not implemented. MR !2485 ("WIP: Implement winapi calling convention") has been open since January 2020. GHC 9.14.1 rejects `foreign import winapi` with a parse error (checked locally).
- **Anticipated:** Not discussed, beyond foreign exports becoming "slightly confusing".
- **Observed:** n/a.
- **Verdict:** `Not implemented`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** —

### 281

**Visible `forall` in types of terms, and types in terms**
- **Implemented:** Partial. `-Wforall-identifier` was on by default in 9.4.1. `forall` became a term-level keyword (parse error) in 9.10.1. `RequiredTypeArguments` arrived in 9.10.1, with types in terms (`->`, `=>`, `forall`) in 9.12.1. `-Wterm-variable-capture` came in 9.8.1 and `-Wview-pattern-signatures` is on by default from 9.12.
- **Anticipated:** Yes. `forall` becomes a keyword "not guarded by any extension", after 3 releases of `-Wforall-identifier` in `-Wdefault`. The view-pattern signature change also gets a 3-release warning. The change to implicit quantification ("a breaking change") is to be prepared by `-Wterm-variable-capture` in `-Wcompat`.
- **Observed:**
  - 9.10: modules that define `forall` as a term identifier fail to parse. The [9.10.1 notes](https://downloads.haskell.org/ghc/9.10.1/docs/users_guide/9.10.1-notes.html) quote `forall :: (Variable a, MonadQSAT s m) => m a` (from `ersatz`). This was forewarned in 9.4, 9.6 and 9.8.
  - Verified that `-Wterm-variable-capture` is not in `-Wcompat` or `-Wall` on 9.8.4–9.14.1, contrary to the proposal. `-Wview-pattern-signatures` fires by default on 9.12.2 and 9.14.1, with no error yet.
- **Verdict:** As anticipated
- **Warning period:** Yes
- **Catalog:** —
- **Notes:** The term-variable-capture warning is opt-in only, so the eventual change to implicit quantification will have weaker notice than proposed.

### 282

**Record Dot Syntax**
- **Implemented:** GHC 9.2.1: `OverloadedRecordDot` in full, `OverloadedRecordUpdate` in part (it needs `RebindableSyntax` and a user-supplied `getField`/`setField`). Ticket [#18599](https://gitlab.haskell.org/ghc/ghc/-/issues/18599).
- **Anticipated:** Under the extension, `a.b` without spaces becomes field selection, which "would break" lens code written `expr^.field1.field2`. Record updates lose type-changing behaviour. Code without the extension is unaffected.
- **Observed:** None found for code that does not enable the extensions (checked: 9.2.1 release notes, migration guides 9.2–10.2, GitLab searches for `OverloadedRecordDot`). Only minor bugs, such as [#22273](https://gitlab.haskell.org/ghc/ghc/-/issues/22273) (FFI's `label` keyword clashing with `.label`) and [#23040](https://gitlab.haskell.org/ghc/ghc/-/issues/23040) (`COLUMN` pragmas). `OverloadedRecordUpdate` users broke in 9.14 because of #583 (see there).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** Amended in 2021 and 2025 ([#668](https://github.com/ghc-proposals/ghc-proposals/pull/668): arbitrary identifiers as fields). The 9.2 user's guide marked `OverloadedRecordUpdate` as experimental and subject to change.

### 285

**`-XNoImplicitForAll`, `-XNoPatternSignatureBinds`**
- **Implemented:** Not implemented. Draft [!8629](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/8629) is open, and GHC 9.14.1 has neither flag. #448 absorbed the proposal.
- **Anticipated:** The new extensions are on by default "for backwards compatibility", so there is no breakage.
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 287

**Simplify subsumption**
- **Implemented:** GHC 9.0.1, full. Ticket [#17775](https://gitlab.haskell.org/ghc/ghc/-/issues/17775). Operator sections were simplified further in 9.2.1.
- **Anticipated:** "some existing programs will require some manual eta-expansion". Such changes are "simple, local, and arguably desirable anyway" and backward-compatible. The Hackage study is in §7 of the Quick Look paper, and the proposal works through one example from `cabal-doctest`.
- **Observed:**
  - 9.0.1 rejects programs that need deep skolemisation, deep instantiation, or co/contravariance of arrows ([9.0 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.0), [9.0.1 notes](https://downloads.haskell.org/ghc/9.0.1/docs/html/users_guide/9.0.1-notes.html)).
  - 9.2.1 rejects operator sections such as ``(`f` "hello")`` where `f` has a nested `forall` ([9.2 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.2)). On HEAD it first broke `conduit` ([#19457](https://gitlab.haskell.org/ghc/ghc/-/issues/19457)).
  - `ImplicitParams` became harder to use ([#20818](https://gitlab.haskell.org/ghc/ghc/-/issues/20818), open).
  - In May 2022, [#21548](https://gitlab.haskell.org/ghc/ghc/-/issues/21548) investigated supporting both kinds of subsumption, and [#21549](https://gitlab.haskell.org/ghc/ghc/-/issues/21549) asked for "Better communication about breaking changes".
  - Breakage was widespread enough that #511 restored deep subsumption in 9.2.4. #511 states: "the breakage study failed to accurately predict how annoying this change would be to users".
  - Under `GHC2021`, the default since 9.2, it still applies.
- **Verdict:** Worse than anticipated
- **Warning period:** No
- **Catalog:** L1
- **Notes:** Partly reverted by #511 (9.2.4) for `Haskell98`/`Haskell2010` only.

### 302

**`\cases` - Multi-way lambda expressions**
- **Implemented:** GHC 9.4.1 ([#20768](https://gitlab.haskell.org/ghc/ghc/-/issues/20768), [MR !7873](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/7873)), under `LambdaCase`.
- **Anticipated:** "not entirely backwards-compatible: Expressions like `\cases -> cases + 1` are now interpreted differently when `-XLambdaCase` is active."
- **Observed:** None found in the wild (checked: GitLab search, 9.4.1 notes). The [9.4 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.4) documents the change. Reproduced: `\cases -> cases + 1` is rejected under `LambdaCase` on 9.4.8 and 9.14.1.
- **Verdict:** No breakage found
- **Warning period:** No
- **Catalog:** —
- **Notes:** `LambdaCase` is part of GHC2024, so the change reaches GHC2024 modules that use no explicit extensions.

### 313

**Delimited continuation primops**
- **Implemented:** GHC 9.6.1, full (`prompt#`, `control0#`; MR !7942).
- **Anticipated:** The change affects only the RTS and "do[es] not require any changes to existing functionality".
- **Observed:** None found (checked: the 9.6 release notes and migration guide, GitLab "control0"). #25439 (`control0#` misbehaving under optimisation, fixed in 9.14.1) affects only users of the new primops.
- **Verdict:** `No breakage found`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** New primops. GHC internals.

### 314

**Enable `-Wnoncanonical-monad-instances` and `-Wnoncanonical-monoid-instances` by default**
- **Implemented:** GHC 9.2.1, full ([!3174](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/3174), milestone 9.2.1). The 9.2.1 release notes do not mention it. I confirmed both warnings fire with no flags on 9.4.8 and 9.8.4.
- **Anticipated:** "People are more likely get annoyed when they see the warnings." The aim is to prepare the ecosystem for phase 2 of monad-of-no-return and so avoid "catastrophic breakage like what we experienced when `fail` got removed".
- **Observed:** None found beyond the new default warnings, which can break `-Werror` builds (checked: the 9.2 migration guide, the 9.2.1 notes, and GitLab and GitHub searches for "noncanonical").
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** Warnings only. The breaking phase 2 has not happened. An attempt to amend monad-of-no-return ([ghc-proposals#687](https://github.com/ghc-proposals/ghc-proposals/pull/687)) was closed unmerged in 2025.

### 320

**Defaults and backpack/hs-boot**
- **Implemented:** GHC 9.2.1 (commit 59d7c9f, "Skip type family defaults with hs-boot and hsig files", merged October 2020, first tagged in ghc-9.2.1-alpha1; #17190).
- **Anticipated:** Users who want the default must now repeat it. A future change could become breaking. Effects: "I don't immediately foresee any negative interactions".
- **Observed:** None found. Before the change, the affected programs (an `hs-boot`/`hsig` instance of a class with an associated-type default) panicked or were rejected, so no working code changed meaning. Checked: the 9.2 migration guide, GitLab, and a local test on 9.4.8, which now accepts the example.
- **Verdict:** `No breakage found`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** The same commit also silenced a missing-method warning in `hs-boot` files.

### 330

**Decorate exceptions with backtrace information**
- **Implemented:** GHC 9.10.1, mostly (base-4.20; `ExceptionContext`, backtrace mechanisms, top-level handler via `displayException`). Follow-up CLC proposals reworked it in 9.12.1 (#202, #231, #261, #285) and in 10.0.1 (#383, #387, #397). The tracking issue [#18159](https://gitlab.haskell.org/ghc/ghc/-/issues/18159) is still open.
- **Anticipated:** The Migration section says the change "has nearly no impact on existing user-code". "The only direct breakage" would be applications of the `SomeException` constructor, which would need `?exceptionContext`, and the proposal promised a head.hackage study. Changes to displayed output are not presented as breakage.
- **Observed:** The predicted break did not happen: `wrap e = SomeException e` compiles on 9.10.3, 9.12.2 and 9.14.1 (tested). The breakage came from changed output and semantics:
  - **9.10.1:** `displayException` on `SomeException` appends a "HasCallStack backtrace:" block and blank lines. Uncaught exceptions print backtraces. I confirmed this by comparing 9.8.4 with 9.10.3. This changes user-visible messages and golden-test output, and caused a trailing-whitespace regression, [#25052](https://gitlab.haskell.org/ghc/ghc/-/issues/25052) (fixed in 9.10.3). `error` printed two call stacks ([#25283](https://gitlab.haskell.org/ghc/ghc/-/issues/25283)).
  - **9.10.1, handlers:** The `ExceptionWithContext` instance nested `SomeException`, so handlers for a specific exception type could stop firing ([#25235](https://gitlab.haskell.org/ghc/ghc/-/issues/25235), fixed in 9.12.1; [Well-Typed](https://well-typed.com/blog/2026/05/lay-annotation-land)).
  - **9.12.1:** The output changed again. `displayException` no longer shows context (CLC #261). The top-level handler prints an "Uncaught exception ghc-internal:GHC.Internal.Exception.ErrorCall:" header. `ErrorCallWithLocation` became a deprecated pattern synonym whose location field throws (CLC #285, catalog B8). As a result, a caught `head []` shown with `displayException` lost its `CallStack`: it is present on 9.8.4 and 9.10.3 and absent on 9.12.2 and 9.14.1 (tested).
  - **10.0.1:** More changes to rethrow and `WhileHandling` annotation semantics, with open bugs on context piling up and being lost ([#27850](https://gitlab.haskell.org/ghc/ghc/-/issues/27850), [#27194](https://gitlab.haskell.org/ghc/ghc/-/issues/27194), [#27851](https://gitlab.haskell.org/ghc/ghc/-/issues/27851)).
- **Verdict:** Worse than anticipated
- **Warning period:** No
- **Catalog:** B8
- **Notes:** The 9.10 migration guide only says output "will change in some cases". Behaviour changed in three consecutive major releases, partly through CLC follow-ups to this proposal.

### 344

**Negative Literals Improved**
- **Implemented:** GHC 9.0.1 ([MR !3624](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/3624)).
- **Anticipated:** "Code that relies on `x-1` being parsed as `x (-1)` will break." Costs: "Changing the behavior of an existing extension may not be the best practice."
- **Observed:** None found (checked: 9.0.1 notes, which document the change, the 9.0 migration guide, and GitLab search "NegativeLiterals"). Reproduced: with `NegativeLiterals`, `x-1` is `x - 1` on 9.4.8 and 9.14.1.
- **Verdict:** No breakage found
- **Warning period:** No
- **Catalog:** —
- **Notes:** The change brings `NegativeLiterals` closer to the report. The extension itself still departs from the report on `-1` (witness `NegativeLiterals.hs`).

### 364

**Unify `Nat` and `Natural`**
- **Implemented:** GHC 9.2.1, full (`type Nat = Natural`). Ticket [#10776](https://gitlab.haskell.org/ghc/ghc/-/issues/10776).
- **Anticipated:** Instances on `Nat` may now need `TypeSynonymInstances`, and separate instances for `Nat` and `Natural` become impossible. "Otherwise, this change should be backward compatible."
- **Observed:**
  - 9.2.1: instances on `Nat` need `TypeSynonymInstances`/`FlexibleInstances` ([9.2.1 notes](https://downloads.haskell.org/ghc/9.2.1/docs/html/users_guide/9.2.1-notes.html), [9.2 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.2)), as anticipated.
  - 9.2.1: type-checker plugins had to switch from the removed `typeNatKind` to `naturalTy` (9.2.1 notes, GHC API only). This was not anticipated.
- **Verdict:** As anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** Two related changes are not caused by #364:
  - The `(<=?)`/`Compare` change in 9.2 (GHC no longer deduces `0 <= n`) is separate.
  - The `DataKinds` check for `Nat` in kinds (9.4–9.8 wrongly skipped it, 9.10 warns with `-Wdata-kinds-tc`, 9.14 rejects) restores what GHC ≤ 9.2 already required ([#22141](https://gitlab.haskell.org/ghc/ghc/-/issues/22141)).

### 366

**DuplicateRecordFields without ambiguous field access**
- **Implemented:** Partial. GHC 9.2.1 added `-Wambiguous-fields`, on by default ([#18966](https://gitlab.haskell.org/ghc/ghc/-/issues/18966), !4770). GHC 9.4.1 removed type-directed disambiguation of selectors. Type-directed disambiguation of record updates is still accepted with the warning in 9.14.1. Ticket [#19461](https://gitlab.haskell.org/ghc/ghc/-/issues/19461).
- **Anticipated:** "The change is backwards-incompatible for code that makes use of the `DuplicateRecordFields` extension. Accordingly we propose a transition period with a compatibility warning." Enabling the extension stays conservative.
- **Observed:** Ambiguous selector occurrences are rejected from 9.4.1 ("Ambiguous occurrence ‘x’", reproduced on 9.4.8 and 9.14.1). Ambiguous updates warn on 9.4.8 and 9.14.1. Neither the 9.2.1 nor the 9.4.1 release notes, nor the 9.4 migration guide, mention the selector change.
- **Verdict:** As anticipated
- **Warning period:** Yes
- **Catalog:** L4
- **Notes:** Removing disambiguation for updates is stalled because `OverloadedRecordUpdate`/`HasField` (#583) are not yet adequate replacements. [#660](https://github.com/ghc-proposals/ghc-proposals/pull/660) amended references only.

### 369

**Add sumToTag# primop**
- **Implemented:** Not implemented. No commit in ghc/ghc mentions `sumToTag`, there is no GitLab issue or MR, and the `implemented` field is empty.
- **Anticipated:** Only a theoretical loss of parametricity.
- **Observed:** n/a.
- **Verdict:** `Not implemented`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** —

### 370

**Syntax for Modifiers: a generalization of linear-types syntax**
- **Implemented:** GHC 10.0.1 (in the 10.0.1-alpha1 release notes, still unreleased as of October 2026; #22624). Amended by #392 and #681 ("Updates to modifiers proposal", accepted December 2025). Not in 9.14.1: `f :: Int %m -> Int` still compiles there (checked locally).
- **Anticipated:** "`Int %m -> Bool`, acceptable today as a multiplicity-polymorphic function, would be rejected. The user would need to add a kind annotation". Spec item 15 adds that `-XLinearTypes -XNoModifiers` restores "backwards compatible behavior".
- **Observed:** The 10.0 migration guide and release notes confirm the kind-annotation requirement. The release notes add a gap the proposal did not foresee: `-XNoModifiers` "doesn't reliably work with -XStrict". Some previously accepted linear `let` patterns now need parentheses, because "modifiers now bind tighter than constructors". For example, `let %1 x:xs = …` and `let %1 Just x = …` are rejected even with `-XNoModifiers`.
- **Verdict:** `Worse than anticipated`
- **Warning period:** `No`
- **Catalog:** —
- **Notes:** `LinearTypes` is experimental. Not yet in a final release.

### 371

**Export `~` from `Data.Type.Equality`**
- **Implemented:** GHC 9.4.1, full ([#18862](https://gitlab.haskell.org/ghc/ghc/-/issues/18862), [!5597](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/5597)). The compatibility fallback is still present in 9.14.1.
- **Anticipated:** "This is a breaking change": users must enable `TypeOperators`, and custom preludes must re-export `(~)`. The fallback emits `-Wtype-equality-requires-operators` (on by default) and `-Wtype-equality-out-of-scope` (`-Wcompat`). Both warnings were to be on by default at n+2, and the fallback removed at n+8 or GHC 10.
- **Observed:** Warnings only so far. `~` without `TypeOperators` warns from 9.4 (W9; e.g. [haskell/cabal#8268](https://github.com/haskell/cabal/issues/8268)). Verified that a `NoImplicitPrelude` module using `~` gets `-Wtype-equality-out-of-scope` by default from 9.10.3 (not 9.8.4), so the step came at n+3 instead of n+2. No hard errors yet.
- **Verdict:** As anticipated
- **Warning period:** Yes
- **Catalog:** W9
- **Notes:** The `Prelude` now exports `~`, which the Haskell 2010 `Prelude` does not.

### 372

**The GHC20XX process**
- **Implemented:** Process proposal. It is applied through #380 (GHC2021, the default from 9.2) and #613 (GHC2024, 9.10). The 2025 amendment ([#632](https://github.com/ghc-proposals/ghc-proposals/pull/632)) adds a GHCi banner naming the edition ([#26037](https://gitlab.haskell.org/ghc/ghc/-/issues/26037)) and a "missing language edition" warning on failure ([#26038](https://gitlab.haskell.org/ghc/ghc/-/issues/26038), still open). It also makes new editions the default immediately ([#26039](https://gitlab.haskell.org/ghc/ghc/-/issues/26039), GHC 10.0, unreleased).
- **Anticipated:** Original text: the next major GHC release after a `GHC20XX` is accepted "will change the default language edition". The amendment's "Breaking changes" section adds: "Silently switching from one language edition to another may involve breaking changes". Mitigations: release notes, a banner, and a warning on failure. It notes that Cabal pins its own default.
- **Observed:** No breakage of its own. The breakage from changing the default edition is recorded under #380 (9.2) and #613 (10.0).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** The mitigations in the amendment came four years after the first switch of default edition (9.2).

### 378

**Design for Dependent Types**
- **Implemented:** Not implemented as such. It is a meta-proposal that sets design criteria for later proposals.
- **Anticipated:** It "does *not* invalidate any current syntax". It lists what may later be given up: punning, `'` for promotion, `forall` as a term variable.
- **Observed:** n/a directly. The concrete breakage came through #281 (`forall` keyword, 9.10).
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 380

**GHC 2021**
- **Implemented:** GHC 9.2.1, full, and made GHC's default language in the same release. Ticket [#19234](https://gitlab.haskell.org/ghc/ghc/-/issues/19234).
- **Anticipated:** Not discussed. The proposal only lists the extensions and notes that `CUSKs` and `DatatypeContexts` are left out. It says nothing about GHC2021 becoming the default or about breakage. #372 provided for the default switch.
- **Observed:** For modules compiled without a language (plain `ghc`/`ghci`, or Cabal packages without `default-language` where Cabal passes none):
  - `PolyKinds` generalises kinds, so instances may no longer be found ([9.2 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.2)).
  - `StandaloneKindSignatures` turns off `CUSKs`, so polymorphically recursive data types need a standalone kind signature ([#20752](https://gitlab.haskell.org/ghc/ghc/-/issues/20752), [#22104](https://gitlab.haskell.org/ghc/ghc/-/issues/22104)).
  - The old default mode included `NondecreasingIndentation` and GHC2021 does not ([9.2.1 notes](https://downloads.haskell.org/ghc/9.2.1/docs/html/users_guide/9.2.1-notes.html)).
  - `GeneralisedNewtypeDeriving` makes the default unsafe for Safe Haskell.
  - GHC2021 lacks `DeepSubsumption` (from 9.2.4), so default-language modules keep the #287 breakage.
- **Verdict:** Not anticipated
- **Warning period:** No
- **Catalog:** L1 (default-language modules), W10 (`PolyKinds` hides the difference)
- **Notes:** The migration guide says Cabal packages are largely unaffected because they usually set `default-language`.

### 387

**The `Char` kind**
- **Implemented:** GHC 9.2.1, full ([#11342](https://gitlab.haskell.org/ghc/ghc/-/issues/11342)): `CmpChar`, `ConsSymbol`, `UnconsSymbol`, `CharToNat`, `NatToChar` and `KnownChar` in `GHC.TypeLits`.
- **Anticipated:** Not discussed. The only cost given is a larger API surface in `GHC.TypeLits`.
- **Observed:** None found. The new `GHC.TypeLits` exports could clash with user definitions of the same names, as in B1, but no report was found. Checked: the 9.2.1 notes, the 9.2 migration guide, and a GitLab search for `UnconsSymbol`.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 402

**Stable GADT constructor syntax**
- **Implemented:** Not implemented ([#18389](https://gitlab.haskell.org/ghc/ghc/-/issues/18389) is still open). The stricter rejection of nested `forall`s in GADT constructors in 9.0 predates the proposal and is unrelated.
- **Anticipated:** Not discussed (it only allows more programs).
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 403

**Cleanup lexical structure of numbers and identifiers**
- **Implemented:** GHC 9.4 ([#18158](https://gitlab.haskell.org/ghc/ghc/-/issues/18158)). Letter Numbers inside identifiers, as in `xⅫ`, are accepted on 9.4.8. Not mentioned in the 9.4.1 release notes.
- **Anticipated:** Not discussed. The proposal presents itself as documenting existing GHC behaviour plus one small extension (Letter Number becomes a digit).
- **Observed:** None found (checked: 9.4.1 notes, 9.4 migration guide, GitLab).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** It writes down a long-standing GHC departure from the 2010 report: `decimal → ascDigit{ascDigit}`, where the 2010 report had `digit{digit}` with Unicode digits. `print (٣ :: Int)` is a lexical error on 9.4.8, 9.8.4 and 9.14.1. The revised report made the same change to `decimal` and `hexit` (issue #3, PR #67), so this is no longer a deviation. Unicode digits are still allowed in identifiers, and GHC accepts them there.

### 409

**Generalized, named, and exportable `default` declarations**
- **Implemented:** GHC 9.12.1 (`NamedDefaults`). Ticket [#24305](https://gitlab.haskell.org/ghc/ghc/-/issues/24305).
- **Anticipated:** Conflicts between imported defaults, which the user resolves with a local `default`. No breakage of existing code was claimed.
- **Observed:**
  - Pre-release: GHC HEAD could not build `colour-2.3.6` ("Could not deduce ‘Integral b0’", [#25206](https://gitlab.haskell.org/ghc/ghc/-/issues/25206)), because defaults were exported implicitly from modules without an export list. An amendment ([ghc-proposals #672](https://github.com/ghc-proposals/ghc-proposals/pull/672), Sept 2024) restricted exports to explicit export lists. Its stated reason: the proposal "is not entirely backward compatible". Fixed before 9.12.1.
  - 9.12.1: the implementation ([!11853](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/11853)) relaxed the use-site defaulting rules for all code, whether or not `NamedDefaults` is on. A type variable constrained by a non-standard class becomes defaultable, which Haskell 2010 §4.3.4 forbids. This was undocumented ([#25777](https://gitlab.haskell.org/ghc/ghc/-/issues/25777), [#25778](https://gitlab.haskell.org/ghc/ghc/-/issues/25778)).
  - Reproduced with `class C a` (instances for `Integer` and `Double`) and `main = putStrLn (c 3)` under `-XHaskell2010`: 9.10.3 rejects (ambiguous), 9.12.2 accepts and prints `Integer`, 9.14.1 rejects again. This change accepts more programs rather than breaking any. Code that relied on it in 9.12 breaks in 9.14.
  - `NamedDefaults`-only bugs fixed in 9.12.3/9.14.1: [#25858](https://gitlab.haskell.org/ghc/ghc/-/issues/25858), [#25912](https://gitlab.haskell.org/ghc/ghc/-/issues/25912), [#25914](https://gitlab.haskell.org/ghc/ghc/-/issues/25914).
- **Verdict:** Not anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** Two findings matter for the report:
  - The accepted specification was not backward compatible, and the fix (an amendment) came before release.
  - GHC 9.12 departed from the report's defaulting rule (§4.3.4) in `Haskell2010` mode. I did not find the 9.14 change back in the release notes.

### 415

**OPAQUE pragma**
- **Implemented:** GHC 9.4.1, full (#19553).
- **Anticipated:** Not discussed. Costs are implementation steps only.
- **Observed:** None found (checked: the 9.4.1 release notes and migration guide, GitLab "OPAQUE"). The bugs #21463 and #22502 affect only code that uses the pragma, and older GHCs ignore the unknown pragma, with a warning.
- **Verdict:** `No breakage found`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** Opt-in pragma.

### 425

**Invisible binders in type declarations**
- **Implemented:** Partial, over several releases:
  - 9.8.1: `@k` binders in type declarations under `TypeAbstractions` ([#22560](https://gitlab.haskell.org/ghc/ghc/-/issues/22560), [!9480](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/9480)), no implicit RHS quantification in type and data family instances (Breakage 3), and `-Wimplicit-rhs-quantification`.
  - 9.10.1: arity inference removed ([#23514](https://gitlab.haskell.org/ghc/ghc/-/issues/23514), [!10660](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/10660)).
  - 9.12.1: wildcard binders.
  - The type-synonym scoping change (Breakage 1) is not yet enforced.
- **Anticipated:** Four named breakages:
  1. Type-synonym RHS scoping, with a 3-release `-Wimplicit-rhs-quantification` period.
  2. Arity inference: "an obscure situation and the change will go unnoticed by most users", "No migration strategy".
  3. Instance RHS scoping, with a backward-compatible fix, so no migration needed.
  4. Instantiation by the LHS alone.

  Template Haskell is not mentioned.
- **Observed:**
  - 9.8: the TH `TyVarBndr ()` binders of declarations became `TyVarBndr BndrVis` (A4, [9.8 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.8)). Breakage 3 is listed under "Breaking changes" in the [9.8.1 notes](https://downloads.haskell.org/ghc/9.8.1/docs/users_guide/9.8.1-notes.html).
  - 9.10: removing arity inference broke the `singletons` family and was undocumented at release ([#24830](https://gitlab.haskell.org/ghc/ghc/-/issues/24830), L10). It forced the change to `Code`'s kind, which broke th-compat (A5, [#23592](https://gitlab.haskell.org/ghc/ghc/-/issues/23592)).
  - Breakage 1: verified that `-Wimplicit-rhs-quantification` is in `-Wcompat` only on 9.8.4–9.12.2 and on by default on 9.14.1 ("The next version of GHC will reject this program").
- **Verdict:** Worse than anticipated
- **Warning period:** Partial (Breakage 1 got its warning period; Breakages 2 and 3 and the TH changes had none)
- **Catalog:** L10, A4, A5

### 433

**Unsatisfiable**
- **Implemented:** GHC 9.8.1, full (`GHC.TypeError.Unsatisfiable`, `unsatisfiable`). Ticket [#20835](https://gitlab.haskell.org/ghc/ghc/-/issues/20835).
- **Anticipated:** "Both `Unsatisfiable` and `TypeError` will remain available … so this proposal does not lead to significant backwards incompatibility."
- **Observed:** None found (checked: 9.8.1 release notes, 9.8 migration guide, GitLab search for `Unsatisfiable`).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 434

**Fine-Grained Unused Warnings**
- **Implemented:** Not implemented. [#20190](https://gitlab.haskell.org/ghc/ghc/-/issues/20190) is open, the proposal has no `implemented` field, and the release notes through 10.0.1 do not mention it.
- **Anticipated:** Warning messages change. Code may get "more or fewer warnings" where flags interact, and new warnings about indirectly unused imports and `forall` binders.
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 448

**Modern Scoped Type Variables**
- **Implemented:** Partial:
  - `TypeAbstractions` for constructor patterns in 9.8.1.
  - Declaration binders in 9.8.1 (via #425).
  - `@`-binders in lambdas and function equations in 9.10.1 (via #155).
  - The rule that `-XScopedTypeVariables` + `-XTypeApplications` no longer enables type abstractions in constructor patterns is enforced in 9.14.
  - `ExtendedForAllScope`, `NoImplicitForAll` and `NoPatternSignatureBinds` are not implemented. GHC 9.14.1 still accepts `((\x -> (x :: a)) :: forall a. a -> a)` with `TypeAbstractions`.
- **Anticipated:** The original text claimed backward compatibility for constructor patterns (`ScopedTypeVariables` would imply `TypeAbstractions`). It anticipated rejecting `((\x -> (x :: a)) :: forall a. a -> a)` with no migration period ("constructs such as this one are rare"). Amendment [#604](https://github.com/ghc-proposals/ghc-proposals/pull/604) (merged August 2023, just before 9.8) dropped the implication: the old flag pair would warn for 2 releases and then be removed. "This *is* a breaking change, but with the advanced notice given via the warning, the costs are reduced".
- **Observed:** `Nothing @a <- …` under `TypeApplications` + `ScopedTypeVariables`:
  - 9.8: an unconditional warning (GHC-69797) that nothing, not even `-w`, can suppress.
  - 9.10 and 9.12: only `-Wdeprecated-type-abstractions` in `-Wcompat` ([#24154](https://gitlab.haskell.org/ghc/ghc/-/issues/24154)).
  - 9.14: rejected (GHC-78249).
  - Enabling `TypeAbstractions` needs CPP before 9.8 (L2).
  - The anticipated `ExtendedForAllScope` break has not happened.
- **Verdict:** As anticipated
- **Warning period:** Partial (2 releases of the warning, but only under `-Wcompat` in the second and third)
- **Catalog:** L2
- **Notes:** The breakage was introduced by amendment #604 and moved a 9.2 feature from #126 behind an Experimental extension. The `implemented` metadata is blank but should be "partial".

### 451

**Sized primitive literals**
- **Implemented:** GHC 9.8.1, full (`-XExtendedLiterals`, #21422). Amendment #596 (MR !10673, also 9.8.1) changed derived `Show` for sized unboxed fields.
- **Anticipated:** Original: "Costs: None." Amendment #596: "This change is technically changing the behavior of GHC … I don't expect much breakage".
- **Observed:** In 9.8 the output of derived `Show` changed for constructors with `Int8#`…`Word32#` fields: they now print `MkT 42#Int8` instead of `MkT (intToInt8# 42#)` (9.8.1 release notes). No reports of breakage found (checked: the 9.8 migration guide, GitLab "ExtendedLiterals"). #25258 is a lexing oddity that occurs only with the extension on.
- **Verdict:** `As anticipated`
- **Warning period:** `No`
- **Catalog:** —
- **Notes:** The visible change came from the amendment (#596), not the original proposal.

### 475

**Non-punning list and tuple syntax**
- **Implemented:** Partial, in stages:
  - 9.6.1: `List` exported from `GHC.Types`, and `Solo`'s constructor renamed `MkSolo`.
  - 9.8.1: tuple tycons become `Unit`, `Tuple2`, … ([MR !9821](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/9821)).
  - 9.10.1: `ListTuplePuns`/`NoListTuplePuns`, and unboxed and constraint tuples renamed `Tuple#N`, `CTupleN`, `Unit#`.
  Ticket [#21294](https://gitlab.haskell.org/ghc/ghc/-/issues/21294), closed April 2026. Still to do: the `Tuple`/`Constraints` type families ([#27179](https://gitlab.haskell.org/ghc/ghc/-/issues/27179)), and removing the deprecated `Solo` pattern synonym ([#27180](https://gitlab.haskell.org/ghc/ghc/-/issues/27180)).
- **Anticipated:** "Everything in this proposal is fully backward-compatible (except for the deprecation on the data constructor `Solo`, but that has a migration period)." It also expects pretty-printing to stay the same.
- **Observed:**
  - From 9.6/9.8, `GHC.Generics.datatypeName` and `tyConName` return `"List"`, `"Tuple2"`, `"Unit"` instead of `"[]"`, `"(,)"`, `"()"` (reproduced: 9.4.8 vs 9.8.4). This broke [swagger2's tests](https://github.com/GetShopTV/swagger2/issues/248) and anything keyed on generic type names. It went undocumented until 9.8.2 ([#24291](https://gitlab.haskell.org/ghc/ghc/-/issues/24291), "Missing changelog for (at least) tuples"). The ghc-prim 0.11 changelog then said it "may affect tools and libraries that rely on type names, such as Generic and Template Haskell".
  - In Template Haskell on 9.8, `''(,)` is `GHC.Tuple.Prim.Tuple2` but `tupleTypeName 2` is still `(,)`, so `''(,) == tupleTypeName 2` is `False`. It is `True` on 9.4.8, 9.10.3 and 9.14.1 (reproduced).
  - `nameBase ''[]` becomes `"List"`.
  - Follow-up TH and renamer bugs: [#24702](https://gitlab.haskell.org/ghc/ghc/-/issues/24702), [#24750](https://gitlab.haskell.org/ghc/ghc/-/issues/24750) (`unboxedTupleTypeName 2 /= ''(#,#)`, fixed in 9.10.2), and [#25179](https://gitlab.haskell.org/ghc/ghc/-/issues/25179).
- **Verdict:** Not anticipated
- **Warning period:** No
- **Catalog:** B9
- **Notes:** Amended by [#603](https://github.com/ghc-proposals/ghc-proposals/pull/603) (exports via `ghc-experimental`) and [#638](https://github.com/ghc-proposals/ghc-proposals/pull/638) (`MkSolo#`). The breakage is in reflection and metaprogramming, not in source syntax.

### 477

**Unicode Ellipsis**
- **Implemented:** Not implemented. [MR !8697](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/8697) is still an open draft. Under `UnicodeSyntax` on 9.14.1, `[1…3]` still parses `…` as a user operator.
- **Anticipated:** "There are no costs and no drawbacks." It does not mention that `…` is a legal operator symbol (Unicode punctuation) under Haskell 2010.
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** If implemented, it would take `…` from user operators under `UnicodeSyntax`, which is opt-in.

### 493

**Allow expressions in SPECIALISE pragmas**
- **Implemented:** GHC 9.14.1, full (#24359, MR !12319). Removal of the old syntax is planned for 9.18 (#25540).
- **Anticipated:** The undocumented "multiple-types syntax" (`{-# SPECIALISE f :: T1, T2 #-}`) will be removed. Everything else "generalises the current syntax … in a natural way". No level given.
- **Observed:**
  1. The multi-signature form is deprecated through `-Wdeprecated-pragmas`, which is on by default, so `-Werror` builds break in 9.14 (9.14.1 release notes).
  2. Template Haskell's `SpecialiseP`, `pragSpecD` and `pragSpecInlD` are deprecated in favour of `SpecialiseEP` (9.14 migration guide; how-to issue #26356). The GHC API's `SpecSig` is deprecated in favour of `SpecSigE`.
  3. A regression the proposal did not foresee: under the new expression-based desugaring, `SPECIALIZE` pragmas with higher-rank argument types fail with "RULE left-hand side too complicated to desugar". Agda's build broke under `-Werror` (#26349, 9.14 alpha). The fix is an HsWrapper optimiser in 10.0.1.

  The separate specialisation regression #26831 (9.14) has no confirmed root cause.
- **Verdict:** `Worse than anticipated`
- **Warning period:** `Partial`
- **Catalog:** —
- **Notes:** The multi-type syntax got a proper deprecation cycle. The TH and GHC API changes are GHC internals.

### 496

**Allow record wildcards for empty records**
- **Implemented:** GHC 9.8.1, full. Ticket [#22161](https://gitlab.haskell.org/ghc/ghc/-/issues/22161).
- **Anticipated:** Costs: "Cannot think of any." It only accepts `C{..}` for constructors without fields.
- **Observed:** None found (checked: 9.8.1 release notes, 9.8 migration guide, GitLab search). It only makes more programs valid.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 511

**Deep Subsumption**
- **Implemented:** GHC 9.2.4, a minor release ([MR !8210](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/8210)). `DeepSubsumption` is on in `Haskell98`/`Haskell2010` and off in `GHC2021`/`GHC2024`. It does not restore deep instantiation.
- **Anticipated:** It restores pre-9.0 behaviour. Drawbacks are about recommending against the feature and about churn for maintainers who already eta-expanded. No breakage expected.
- **Observed:** None found (checked: 9.2.4 and 9.4.1 release notes, migration guides, GitLab searches). Later fixes ([#26225](https://gitlab.haskell.org/ghc/ghc/-/issues/26225) and others in 9.14.1) concern programs it should accept but did not, not new rejections.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** L1 (partial mitigation)
- **Notes:** A language change in a minor release, made to undo breakage from #287. It does not reach modules that use the default language.

### 512

**`NoFieldSelectors` as a datatype and field annotation**
- **Implemented:** Not implemented in any release up to 9.14.1. Ticket [#24481](https://gitlab.haskell.org/ghc/ghc/-/issues/24481).
- **Anticipated:** Same effects as `NoFieldSelectors`, opt-in per datatype. No breakage discussed.
- **Observed:** None. It is not released.
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 516

**Add warning for incomplete record selectors**
- **Implemented:** GHC 9.10.1 (`-Wincomplete-record-selectors`, off by default). Added to `-Wall` in 9.14.1. Ticket [#18650](https://gitlab.haskell.org/ghc/ghc/-/issues/18650).
- **Anticipated:** The warning "is implied by `-Wall`". "Users who set `-Wall -Werror` may see build failures if they use partial fields as selectors". It allows the implementation to warn on every partial selector occurrence.
- **Observed:**
  - 9.14.1: `-Wall -Werror` builds that use partial selectors fail. The 9.14.1 notes say "if a library is compiled with -Werror, compilation may now fail. Solution: fix the library."
  - False positives: `sel $ x` warns where `sel x` does not ([#24824](https://gitlab.haskell.org/ghc/ghc/-/issues/24824); still warns on 9.10.3/9.12.2, clean on 9.14.1). Further spurious warnings in [#25592](https://gitlab.haskell.org/ghc/ghc/-/issues/25592) and [#25749](https://gitlab.haskell.org/ghc/ghc/-/issues/25749). In 9.14.1 the warning fires on `(.ta)` for a GADT field whose type rules out the missing constructor, and on `optics`' `gafield @"t2"`, which handles the missing constructor safely ([#26686](https://gitlab.haskell.org/ghc/ghc/-/issues/26686), milestone 9.14.2). Per catalog W6, contributors there suggested taking it out of `-Wall` again.
- **Verdict:** Worse than anticipated
- **Warning period:** Partial
- **Catalog:** W6
- **Notes:** The "Partial" warning period is that the flag existed opt-in for two releases (9.10, 9.12) before joining `-Wall`.

### 518

**Generalising Type and Constraint**
- **Implemented:** GHC 9.6.1, full ([#21623](https://gitlab.haskell.org/ghc/ghc/-/issues/21623), [!8750](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/8750)).
- **Anticipated:** "This proposal is fully backward compatible". "We do not expect routine users to notice this change, but users who specify `-fprint-explicit-runtime-reps` will see some changes."
- **Observed:** No source-level breakage found. The GHC API changed substantially: `FunTyFlag`, `Nth` became `SelCo`, `mkTc*Co` were removed, `One`/`Many` became `OneTy`/`ManyTy`, and `eqType` moved. This breaks type-checker plugins and GHC-API clients ([9.6 migration guide, "Type vs Constraint"](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.6)). Checked: the 9.6 notes, the migration guide, and GitLab searches.
- **Verdict:** Not anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** The breakage is confined to the GHC API, where churn is routine. If GHC-API changes are out of scope, read this as "No breakage found".

### 522

**Or Patterns**
- **Implemented:** GHC 9.12.1, opt-in `OrPatterns` ([#22596](https://gitlab.haskell.org/ghc/ghc/-/issues/22596)). Its syntax was amended to `(p1; p2)` by PRs #585 and #609.
- **Anticipated:** Not discussed (syntactic sugar behind an extension).
- **Observed:** None found (checked: 9.12.1 notes, 9.12 migration guide).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 540

**jsem: parallelism semaphores for GHC**
- **Implemented:** GHC 9.8.1 (`-jsem`, `semaphore-compat-1.0`; #19416). Amended by #673 (protocol v2 over Unix domain sockets, `semaphore-compat-2.0.1`), which is in GHC 10.0.1 and cabal 3.18.
- **Anticipated:** The original proposal had no compatibility discussion: "The implementation in GHC is self-contained, and doesn't impact the rest of the compiler much." The #673 amendment adds a "Backwards Compatibility" section with a compatibility matrix.
- **Observed:** Protocol v1 used POSIX semaphores, whose memory layout depends on the libc. With a glibc-linked GHC and a musl-static `cabal-install` (as ghcup ships it), `cabal build --semaphore` failed ("semOpen: does not exist") or crashed. This is https://github.com/haskell/cabal/issues/9993 (2024, GHC 9.8.2, reproduced on ouroboros-consensus) and GHC #25087. The amendment says this combination is broken and "cannot be fixed retroactively". After v2, GHC 10.0 with cabal 3.12–3.16 ignores `-jsem` and compiles sequentially with a warning. Also a token leak, #27253 (fixed in 9.14.2 and 10.0.1).
- **Verdict:** `Not anticipated`
- **Warning period:** `n/a`
- **Catalog:** —
- **Notes:** Only users who opt in (`--semaphore`/`-jsem`) were affected. The degraded parallelism between v1 and v2 tools is anticipated in amendment #673.

### 541

**`WARNING` pragmas with categories**
- **Implemented:** GHC 9.8.1, full ([#17209](https://gitlab.haskell.org/ghc/ghc/-/issues/17209)). The 9.8.1 notes confirm it.
- **Anticipated:**
  - Points 3 and 4 "make the proposal backwards compatible". The proposal notes that a library adding a category to a previously uncategorised warning makes `-Wno-deprecations` stop suppressing it.
  - It explicitly intends `head` and `tail` to get categorised warnings so that "users will be warned about their use by default".
- **Observed:**
  - As intended, CLC #87 used the mechanism: `x-partial` warnings on `head` and `tail` in base-4.19 / GHC 9.8.1 (catalog B4), extended to `init` and `last` in 10.0.1 (CLC #292).
  - Builds with `-Werror` broke (warning-induced). This added to the 9.8 ecosystem churn (E6).
  - `-Wno-x-partial` is unknown to GHC before 9.8, so silencing it portably also needs `-Wno-unrecognised-warning-flags`.
- **Verdict:** As anticipated
- **Warning period:** n/a
- **Catalog:** B4, E6 (contributing)
- **Notes:** The proposal itself only adds syntax and flags. The breakage is warnings that the CLC added using it.

### 547

**Disallow constraints in kinds**
- **Implemented:** GHC 9.8.1, full. Commit [3c3060e4](https://github.com/ghc/ghc/commit/3c3060e4645b12595b187e7dbaa758e8adda15e0) ([!9325](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/9325), [#22298](https://gitlab.haskell.org/ghc/ghc/issues/22298)) is not in the 9.6.1 tag. Verified: 9.4.8 accepts `data T :: forall a. (a ~ Bool) => a -> Type`, and 9.8.4 rejects it ("Illegal constraint in a kind").
- **Anticipated:** Yes. The example in the introduction "would now be rejected", as would any promoted use of a data constructor with an equality constraint. The use case is "very modestly useful, and this proposal destroys" it.
- **Observed:** None found. The 9.8.1 notes do not mention it. Checked: the 9.8 notes and migration guide, and a GitLab search for "Illegal constraint in a kind".
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** The change was undocumented in the release notes even though it rejects previously accepted programs.

### 555

**Higher Order Patterns in Rewrite Rules**
- **Implemented:** GHC 9.8.1, full ([#22465](https://gitlab.haskell.org/ghc/ghc/-/issues/22465)). The amendment [ghc-proposals#577](https://github.com/ghc-proposals/ghc-proposals/pull/577) was merged in 2024.
- **Anticipated:** Backward Compatibility says that where the old matcher succeeds, the new one gives the same result. Extra matches are β-equivalent, and the most specific rule still wins. "We are not aware of any rule-sets whose behaviour would change."
- **Observed:** None found (checked: the 9.8 migration guide, the 9.8.1 notes, and GitLab searches on rule matching and higher-order patterns).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 569

**Multiline strings**
- **Implemented:** GHC 9.12.1, opt-in `MultilineStrings` ([#24390](https://gitlab.haskell.org/ghc/ghc/-/issues/24390)). Later fixes came through PRs #637, #686 and #730.
- **Anticipated:** "Should not break existing code, unless someone is actually using `"""a"""` to mean `"" "a" ""`" (only when the extension is on).
- **Observed:** None found (checked: 9.12.1 and 9.14.1 notes, migration guides).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** With the extension off, `"""x"` still lexes as the report says on 9.4.8 and 9.14.1 (witness `MultilineStrings.hs`).

### 570

**Add native string interpolation syntax**
- **Implemented:** Not implemented. Accepted 2026-07; [work item #27592](https://gitlab.haskell.org/ghc/ghc/-/work_items/27592) is open.
- **Anticipated:** "An existing program containing `s"..."` will break when `-XStringInterpolation` is enabled". The proposal calls this the first case where white space matters after an alphanumeric identifier, and expects the impact to be small.
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 575

**Deprecated instances**
- **Implemented:** GHC 9.10.1, full ([#17485](https://gitlab.haskell.org/ghc/ghc/-/issues/17485)). The 9.10.1 notes confirm it.
- **Anticipated:** Not discussed. Only implementation cost ("minimal") and parsing (no conflicts) are covered.
- **Observed:** None found (checked: the 9.10 migration guide, the 9.10.1 notes and a GitLab search). The feature is an opt-in pragma that only produces warnings.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 581

**Namespace-specified imports**
- **Implemented:** Partial in GHC 9.14.1, the rest in 10.0.1, which is unreleased (snapshot of 2026-09-17) ([#23781](https://gitlab.haskell.org/ghc/ghc/-/issues/23781), closed 2026-01).
  - 9.14.1: the `data` specifier in import and export lists, rejection of invalid `type` specifiers in subordinate import lists ([#22581](https://gitlab.haskell.org/ghc/ghc/-/issues/22581)), and `-Wpattern-namespace-specifier`.
  - 10.0.1: `type ..` and `data ..` wildcards, and rejection of `module M (T (type A))` ([#12488](https://gitlab.haskell.org/ghc/ghc/-/issues/12488)).
- **Anticipated:** Backward Compatibility section: "mostly backwards compatible". Only bogus `type` specifiers on data constructors are rejected. A patched GHC 9.10.1 built 3182 packages with no failures. The `pattern` specifier only gets a `-Wcompat` warning: "this is not a breaking change". No 0–4 level is given.
- **Observed:** No build breakage found. `-Wpattern-namespace-specifier` drew complaints. It could not be fixed without CPP across 9.12 and 9.14 ([#26111](https://gitlab.haskell.org/ghc/ghc/-/issues/26111)), and it was called "surprisingly annoying… not actionable for quite some time" ([#26469](https://gitlab.haskell.org/ghc/ghc/-/issues/26469)). In 9.14.1 it fires only under `-Wcompat` (checked locally).
- **Verdict:** No breakage found
- **Warning period:** No
- **Catalog:** —
- **Notes:** One of the few proposals in this batch that measured its impact before implementation (Hackage build of 3182 packages).

### 583

**HasField redesign**
- **Implemented:** Partial:
  - 9.12.1: `HasField` is representation-polymorphic (via CLC #194), and `OverloadedRecordDot` works for unlifted types.
  - 9.14.1: `OverloadedRecordUpdate` passes arguments to `setField` in the flipped order, `a -> r -> r`.
  - The `SetField` class and `modifyField` are not in `base` as of 9.14.1.
  Ticket [#16232](https://gitlab.haskell.org/ghc/ghc/-/issues/16232).
- **Anticipated:** "Users relying on `OverloadedRecordUpdate` plus `RebindableSyntax` will need to follow the change to the order of arguments to `setField`. This is a breaking change, but `OverloadedRecordUpdate` has been explicitly advertised as experimental". Otherwise backward compatible.
- **Observed:** 9.14.1 breaks `OverloadedRecordUpdate` + `RebindableSyntax` code with the old `setField` order ([9.14.1 notes](https://downloads.haskell.org/ghc/9.14.1/docs/users_guide/9.14.1-notes.html), [9.14 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.14)). Nothing else found.
- **Verdict:** As anticipated
- **Warning period:** No
- **Catalog:** —
- **Notes:** Supersedes #158.

### 586

**Split `-Wunused-imports`**
- **Implemented:** Not implemented. [#21879](https://gitlab.haskell.org/ghc/ghc/-/issues/21879) is open. The draft [!8991](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/8991) ("Split up -Wunused-imports into three warnings") was closed unmerged on 2026-03-19.
- **Anticipated:** "The main cost is changing the behaviour of a warning without notice", which the proposal judged acceptable. The change is to warnings only.
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 601

**Extension Lifecycle Framework**
- **Implemented:** Policy proposal, no compiler change of its own. Its categories were assigned by #669.
- **Anticipated:** "Because this proposal does not change the semantics of any programs, we expect that it will not be a major disturbance."
- **Observed:** None found (checked: release notes 9.10–9.14, migration guides).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 612

**Change the semantics of -fhpc**
- **Implemented:** Partial.
  - Done: GHC 9.12.1 added the RTS flag `--read-tix-file=<yes|no>` (default `yes`) and a deprecation warning when a `.tix` file is read implicitly ([!11401](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/11401), [#23955](https://gitlab.haskell.org/ghc/ghc/-/issues/23955)).
  - Not done: changing the default to `no`. That is [!16826](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/16826), still open and blocked on review. It is not in the 10.0.1-alpha1 notes.
- **Anticipated:** Backward Compatibility: "This is a breaking change w.r.t. to the semantics of `-fhpc`", affecting only users who accumulate coverage over several runs ("very few people"). There is a two-release deprecation plan: warn first, stop reading in the next release.
- **Observed:** None found. The breaking step has not shipped. The schedule slipped: the warning text in !11401 promised the change for 9.12, but the 9.12.1 notes say "a future version".
- **Verdict:** No breakage found
- **Warning period:** Yes
- **Catalog:** —
- **Notes:** The warning has been in place since 9.12, and the semantic change is still pending.

### 613

**GHC2024**
- **Implemented:** GHC 9.10.1 as an opt-in edition. GHC2021 stayed the default through 9.14.1 (verified: `:show language` on 9.14.1). Under the 2025 amendment ([#632](https://github.com/ghc-proposals/ghc-proposals/pull/632)), GHC2024 becomes the default in GHC 10.0 ([#26039](https://gitlab.haskell.org/ghc/ghc/-/issues/26039), closed 2026-04, unreleased). Ticket [#24320](https://gitlab.haskell.org/ghc/ghc/-/issues/24320).
- **Anticipated:** It discusses backward compatibility per extension. "Enabling `GADTs` alone does not break existing `GHC2021` code … but enabling `MonoLocalBinds` does". `DataKinds` and the others are claimed harmless. Users who pin an edition are unaffected.
- **Observed:** None found for the opt-in edition (checked: 9.10.1–9.14.1 release notes, migration guides, GitLab searches). One related bug: `TypeAbstractions` leaks into GHC2021/GHC2024 ([#25448](https://gitlab.haskell.org/ghc/ghc/-/issues/25448)). The switch of default in 10.0 is unreleased. On master it already broke nofib ([#27155](https://gitlab.haskell.org/ghc/ghc/-/issues/27155)). The 10.0 migration guide draft does not mention it.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** Once 10.0 ships, modules without a language edition get `MonoLocalBinds`. The proposal itself names this breakage.

### 631

**Meaningful main return types**
- **Implemented:** Not implemented. [#24848](https://gitlab.haskell.org/ghc/ghc/-/issues/24848) is open, and the implementation [!16783](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/16783) ("Implement GHC proposal #631") is still open.
- **Anticipated:** "This proposal is fully backwards compatible." The behaviour is behind an extension, which may reject programs or change the meaning of `main :: IO ExitCode`.
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 640

**Fix quantification order for (a `op` b) and (a %m -> b)**
- **Implemented:** GHC 9.12.1, full ([#23764](https://gitlab.haskell.org/ghc/ghc/-/issues/23764)). The [9.12.1 notes](https://downloads.haskell.org/ghc/9.12.1/docs/users_guide/9.12.1-notes.html) say it is "backwards-incompatible, although in practice we don't expect it to cause significant disruption".
- **Anticipated:** Has a "Backward Compatibility" section with no 0–4 level. "Technically, this is a breaking change… practically no code in the wild relies on the current buggy behavior". It was tested on 3337 packages with no build failures.
- **Observed:** None found. Checked: the 9.12 notes and migration guide, and a GitLab search for quantification order.
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** The proposal measured the actual impact before acceptance, as the later Backward Compatibility template asks.

### 652

**Import shadowing**
- **Implemented:** Not in any release up to 9.14.1 (`ImportShadowing` is not among 9.14.1's supported extensions). Ticket [#25187](https://gitlab.haskell.org/ghc/ghc/-/issues/25187) is open. The implementation, [MR !13161](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/13161), is still open; it was milestoned for 9.14.1 but did not ship. Amended Aug 2026 to match Haskell 2010 §5.2.5 on re-exports ([ghc-proposals #678](https://github.com/ghc-proposals/ghc-proposals/pull/678)).
- **Anticipated:** Backward Compatibility: a "-1"-impact change. Valid Haskell 2010 programs keep their meaning, and the extension only makes rejected programs accepted.
- **Observed:** None. It is not released.
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** Relevant to the catalog's "adding an export breaks code" observation (B1, B5, B6, K2, K3, K6), which this extension would mitigate.

### 669

**Categorization of Language Extensions**
- **Implemented:** Accepted Aug 2025. Ticket [#27329](https://gitlab.haskell.org/ghc/ghc/-/issues/27329). Not reflected in 9.14.1.
- **Anticipated:** "Since there is no impact to feature availability from this proposal, it is completely backward compatible." Extensions categorised `Deprecated` must be added to `-Wdeprecated-flags`, which adds new warnings.
- **Observed:** None. Not in a release.
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** The catalog uses its categories (Stable, Legacy, Experimental) in its stability analysis.

### 682

**Explicit Level Imports**
- **Implemented:** GHC 9.14.1 (`ExplicitLevelImports`, `ImplicitStagePersistence`; [#25828](https://gitlab.haskell.org/ghc/ghc/-/issues/25828)). Fixes followed in 9.14.2 and 10.0.1.
- **Anticipated:** "Since `ImplicitStagePersistence` is enabled by default, this proposal is backwards compatible." Making `NoImplicitStagePersistence` the default would break code, but is not proposed.
- **Observed:** I found no rejection of previously accepted programs that do not enable the extension (checked: the 9.14 migration guide, the 9.14.1 and 9.14.2-rc2 notes, and all GitLab issues labelled `ExplicitLevelImports`). One diagnostic regression affects all Template Haskell users in 9.14.1. A stage-restriction error, such as a locally defined type used in a top-level splice, is reported as "GHC internal error: 'T' is not in scope during type checking, but it passed the renamer" ([#26099](https://gitlab.haskell.org/ghc/ghc/-/issues/26099); I confirmed it on 9.14.1, and 9.12.2 gives the old message). The fix is due in 9.14.2. The other bugs (#26088, #26098, #26568, #26616, #27683, #27756, …) affect only modules that opt in. Some of the fixes tighten the opt-in checks, for example by applying level checks to types (#26098, in 10.0.1).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —
- **Notes:** The 9.14.1 regression is in an error message only. The affected programs were already rejected.

### 696

**Splitting out stable interfaces from `template-haskell`**
- **Implemented:** GHC 9.14.1, full. `template-haskell-lift-0.1.0.0` and `template-haskell-quasiquoter-0.1.0.0` ship with 9.14.1 (confirmed with `ghc-pkg`) and were uploaded to Hackage in October 2025. 10.0.1 adds `defaultQuasiQuoter` and `namedDefaultQuasiQuoter`.
- **Anticipated:** "As this proposal deals exclusively with creating new packages, there are no backwards compatibility worries."
- **Observed:** None found (checked: Hackage, the 9.14 and 10.0 migration guides, and the 9.14.1 and 10.0.1 notes).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 700

**Abstract Q**
- **Implemented:** Merged to master for GHC 10.2 ([!15696](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/15696), closed 2026-07-01; [#27341](https://gitlab.haskell.org/ghc/ghc/-/issues/27341) closed). It is not in any release: it is absent from the 10.0.1-alpha1 notes and the 10.2 migration guide.
- **Anticipated:**
  - "While this is a breaking change to `template-haskell`, this interface breaks regularly anyway."
  - It lists seven Hackage packages with custom `Quasi` instances: RepLib, aeson-schema, large-records, geniplate, th-test-utils, nyan-interpolation-core and th-traced.
  - `unQ` is kept for compatibility, and a new `qRunQ` method is added.
  - Mocking `Q` through a custom `Quasi` monad becomes harder.
- **Observed:** None yet. The change is unreleased.
- **Verdict:** No breakage found
- **Warning period:** No
- **Catalog:** —
- **Notes:** The proposal gives no deprecation cycle. Recheck when 10.2 is released.

### 723

**Qualified Strings**
- **Implemented:** GHC 10.0.1, unreleased (in the 10.0.1-alpha1 and 2026-09-17 snapshot release notes), opt-in `QualifiedStrings` ([#26503](https://gitlab.haskell.org/ghc/ghc/-/issues/26503)).
- **Anticipated:** "No breakage, as the new syntax is only enabled with the extension."
- **Observed:** None found (checked: 10.0.1 prerelease notes, 10.0 migration guide).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 732

**Simplifying static forms**
- **Implemented:** GHC 10.0.1 (in alpha): the new rule that free variables of `static e` must be bound at top level ([#26556](https://gitlab.haskell.org/ghc/ghc/-/issues/26556), commit 318ee13b, Oct 2025). A deprecation warning with no flag to turn it off is in 9.14.2 ([!15292](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/15292), [#26718](https://gitlab.haskell.org/ghc/ghc/-/issues/26718)). 9.14.2 is still at rc2.
- **Anticipated:** "there may be some back-compat issues. Perhaps existing libraries rely on using nested let-bindings in `static`." A survey of 51 Hackage packages found one affected, `imprint`, and concluded the "impact on Hackage is extremely small". Cabal-hooks' `static Dict` usage is unaffected. The proposal asks for a "minimal deprecation cycle": a warning in 9.14.2, then the change in 9.16 (now 10.0).
- **Observed:** None yet. Neither 9.14.2 nor 10.0.1 has a final release.
- **Verdict:** No breakage found
- **Warning period:** Partial
- **Catalog:** —
- **Notes:** The warning comes only in a minor release (9.14.2) just before the breaking major release.

### 748

**Extra Commas**
- **Implemented:** Not implemented (accepted 2026-10-13; no ticket).
- **Anticipated:** "This change is backward compatible with existing Haskell code". Tooling that parses Haskell will need updates.
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —

### 752

**Lazy Field Annotations**
- **Implemented:** Merged for GHC 10.2, which is unreleased ([#24455](https://gitlab.haskell.org/ghc/ghc/-/issues/24455), closed 2026-07-29). It is not in the 10.0.1 prerelease notes.
- **Anticipated:** "expected impact level 0 under the scale in the proposal template: no breakage."
- **Observed:** None found (checked: 10.0/10.2 migration guides, GitLab).
- **Verdict:** No breakage found
- **Warning period:** n/a
- **Catalog:** —

### 765

**Pun warnings**
- **Implemented:** Not implemented ([work item #27774](https://gitlab.haskell.org/ghc/ghc/-/work_items/27774) is open).
- **Anticipated:** Not discussed (new warnings only; maintenance cost).
- **Observed:** n/a
- **Verdict:** Not implemented
- **Warning period:** n/a
- **Catalog:** —
