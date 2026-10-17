# Against GHC's stability principles

The catalog assessed against the GHC stability principles and the goals of the
State of Play. Part of the [GHC upgrade breakage catalog](README.md), which
explains the sources and the classification.

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

## Where the breakage falls

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

## Case by case

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

## What this shows

**Export additions defeat GR1 and GR3 together.** B1, B5, B6, K2, K3 and K6
break packages whose dependencies' used API is unchanged, so GR1's condition
on dependencies does not protect them. The Principles themselves say GR3
cannot apply to added exports. They are the most frequent single kind of
breakage in the catalog, and they come from the report's own name-clash rule
(§5.5.2); see [Observations](observations.md).

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
