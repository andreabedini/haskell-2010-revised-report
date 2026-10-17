# Lessons learned

This document draws on two analyses:
- the [catalog](README.md) of 53 breakages that industrial users hit when
  upgrading GHC;
- the review of all 126 [accepted GHC proposals](../ghc-proposal-breakages/README.md),
  which compares the breakage each proposal anticipated with what its
  implementation caused.

It states what went wrong, with the cases that show it, and suggests changes
to the processes that produce GHC, its libraries and this report.

Most of the changes behind these cases had good reasons: soundness fixes,
security fixes and cleaner designs. The lessons are about how the changes
were assessed, delivered and communicated, not about whether they should
have been made.

## Lessons

### 1. Breakage assessments are not checked against reality

Of the 102 implemented proposals, 44 broke existing code. For 21 of them the
breakage was worse than the proposal said, or the proposal did not foresee
it. Some estimates were far off:

- #195: "I feel like I am the only user so the impact will be minimal". It
  broke Typed Template Haskell for libraries and for an industrial codebase
  ([A7](ghc-internals.md#a7)).
- #425 called removing arity inference "obscure… will go unnoticed by most
  users". It broke the `singletons` family ([L10](language.md#l10)).
- #330 expected "nearly no impact". It changed how exceptions are displayed
  in three consecutive releases.
- #287 rested on a Hackage study. The proposal that partly reverted it,
  #511, says "the breakage study failed to accurately predict how annoying
  this change would be to users" ([L1](language.md#l1)).

Since 2023 the template says implementers should check actual impact against
the assessment, and revise the proposal if it is worse. The review found no
proposal revised this way. Today a proposal's assessment is the last word on
its breakage, even when it is wrong.

### 2. Many breaking changes never went through the proposal process

Of the 20 language and diagnostics cases in the catalog, 10 trace back to an
accepted proposal. The other 10 came from bug fixes, refactorings and new
checks:

- the loopy superclass fix ([L7](language.md#l7), [L9](language.md#l9));
- the record-update rewrite ([L8](language.md#l8));
- the pattern-match checker ([W1](diagnostics.md#w1), [W8](diagnostics.md#w8));
- the `MonoLocalBinds` check ([W3](diagnostics.md#w3));
- the `do`-expansion refactoring ([L3](language.md#l3));
- an accidental implication removed ([L5](language.md#l5)).

`base` changes outside the CLC process add more:
- the `Int64` representation ([B3](base.md#b3));
- the rewiring of `Int8`…`Word32` in 9.2, which proposal #74 had left out of
  scope;
- the loss of `GHC.Num`'s Safe Haskell status ([B7](base.md#b7)).

Many of these are correct by the report's semantics, and the stability
principles allow bug fixes to break code. But nothing measured their impact,
none had a warning period, and several are missing from the release notes.

Even where there was a proposal, the implementation often did more than it
said:
- #103 shipped four breaking changes and described one.
- #409's implementation relaxed defaulting for all code in GHC 9.12, so GHC
  accepted, under `-XHaskell2010`, a program the report rejects. 9.14 undid
  it.

### 3. Template Haskell and the GHC API are outside every assessment

Seven proposals changed the Template Haskell AST or its types without
anticipating it: #55, #65, #99, #195, #425, #475 and #493. The stability
principles exclude `template-haskell` and the `ghc` package by name. The
proposal template asks about existing *programs*, and authors read that as
source code.

This is where libraries break. TH-heavy libraries such as `singletons`,
`lens` and `th-desugar` must change in lock step with GHC, and their users
cannot upgrade until they do. Catalog cases A1–A8 and E5 all come from this
layer. `singletons-th` now supports exactly one GHC per major version.

### 4. Adding a name to a module breaks code, and nothing can warn first

Six catalog cases are a module gaining an export that clashes with a name
already in scope: [B1](base.md#b1), [B5](base.md#b5), [B6](base.md#b6),
[K2](boot-libraries.md#k2), [K3](boot-libraries.md#k3) and
[K6](boot-libraries.md#k6). This is the most frequent single kind of
breakage in the catalog.

The cause is the report's name-clash rule (§5.5.2): an unqualified use of
an ambiguous name is an error, even when one of the candidates is defined in
the module itself. The PVP counts an added export as a minor change, and the
stability principles admit that no deprecation cycle can precede it. The
added names `liftA2`, `foldl'`, `unzip`, `Unit` and `show` all broke real
code.

Proposal #652 (import shadowing, accepted in 2024) would let local
definitions win over imports. It is not implemented.

### 5. Warnings are breakage for industrial users

The template and the stability principles assume packages do not use
`-Werror`. Both experience reports build with warnings as errors, and
Tilapia counts breakage under `-Werror`. 11 of the 53 catalog cases are new
or changed warnings: [W1–W10](diagnostics.md) and [B4](base.md#b4).

A deprecation cycle is itself a new warning. So under `-Werror`, a warning
period moves the break one release earlier rather than removing it.

The warnings are not always reliable either:
- `-Wincomplete-record-selectors` gave false positives through three
  releases ([W6](diagnostics.md#w6)).
- `-Wincomplete-record-updates` silently stopped firing in 9.6 and came back
  in 9.8 ([W5](diagnostics.md#w5)).
- `-Woperator-whitespace` was promised for `-Wall` and `-Wcompat` by an
  amendment to #229, and is in neither as of GHC 9.14.1.

### 6. Warning periods are promised more often than delivered

Of the 44 proposals that broke code, 6 had a full warning period. Several
promised one and did not deliver it:
- #229's warnings arrived one release after the break.
- #65's deprecation cycle never happened.
- #77 announced three releases of deprecation and removed the feature after
  one.
- #448's warning could not be suppressed in 9.8, then moved to `-Wcompat`
  only, so most users never saw it before 9.14 rejected their code
  ([L2](language.md#l2)).
- In CLC #285, the deprecation and the run-time failure came in the same
  release ([B8](base.md#b8)).

### 7. Release notes are not a reliable record of breaking changes

Breaking changes missing from the release notes of the version that shipped
them:
- #229 in 9.0.1;
- #32 in 9.4.1;
- #547 in 9.8.1;
- the `Tuple2` rename until 9.8.2 ([B9](base.md#b9));
- #425's arity change in 9.10.1;
- the Template Haskell change from #65 in 9.10.1;
- the `-Wall` change of #71 in 9.2.1 ([W5](diagnostics.md#w5));
- `ErrorCallWithLocation` in the `base` changelog ([B8](base.md#b8)).

The migration guides are better, but they are written by hand, sometimes
after the release. Even GHC's own 9.6 migration guide cites the wrong CLC
proposal for `liftA2`.

### 8. Language editions protect only code that names one, and not its lexical syntax

Editions work when used. `Haskell2010` kept deep subsumption, so
[L1](language.md#l1) stopped affecting Haskell 2010 modules from GHC 9.2.4
on. But GHC 9.2 made `GHC2021` the default, and proposal #380 did not assess
what that would break. Modules that name no language lost the old
behaviour, and some broke through `PolyKinds` and the loss of `CUSKs`.

The lexer has no notion of edition. #229's whitespace rules apply in
`Haskell2010` mode with no way back. The witnesses in
[GHC extensions](../ghc-extensions/reference.md#where-ghcs-haskell-2010-mode-departs-from-the-report)
show four valid Haskell 2010 programs that every GHC since 9.0 rejects.

### 9. Boot libraries tie unrelated library changes to compiler upgrades

A boot library cannot be reinstalled once the `ghc` library is in the build
plan, and old versions often do not build on a new GHC. So a GHC upgrade
forces library upgrades, which bring their own API changes:

| Case | Library change forced by the GHC upgrade |
|---|---|
| [K1](boot-libraries.md#k1) | `mtl` dropped re-exports |
| [E1](ecosystem.md#e1) | `aeson` 2 |
| [E3](ecosystem.md#e3) | the `flatparse` renames |
| [E4](ecosystem.md#e4) | `constraints-extras` |

Users can't separate "upgrade the compiler" from "absorb a year of library
churn".

### 10. Minor releases are not safe

Minor releases changed APIs:

| Case | Release | Change |
|---|---|---|
| [A3](ghc-internals.md#a3) | 9.8.4 and 9.6.7 | `getKey` changed type |
| [K2](boot-libraries.md#k2) | 9.8.3 | deepseq's new `Unit` export broke building GHC 9.10.1 |
| [K3](boot-libraries.md#k3) | 9.10.2 | text-2.1.2 brought the `Data.Text.show` clash |

A pinned major version does not protect against breakage.

### 11. Users misdiagnose what broke

The industrial reports contain several wrong diagnoses:
- `Control.Applicative` "no longer exports `liftA2`" ([B1](base.md#b1)).
- `Type.Reflection.Fun` "disappeared" ([W7](diagnostics.md#w7)).
- `Eq` "lost commutativity" ([W8](diagnostics.md#w8)).
- Changes were dated to the wrong release ([L6](language.md#l6),
  [B2](base.md#b2)).
- `xls` was confused with `xlsx` ([E2](ecosystem.md#e2)).

Errors do not point to what changed or why, so teams fix symptoms and
cannot apply a forward-compatible fix in advance.

## Suggested process changes

### For the GHC Steering Committee

1. **Add an implementation report to each proposal.** When the last
   breaking part of a proposal ships, record:
   - the GHC version;
   - what shipped and how it differs from the specification;
   - the breakage measured on head.hackage or a Stackage snapshot;
   - links to the release notes and migration guide.

   If the measured breakage exceeds the assessment, send the proposal back
   to the committee, as the template already says (lessons 1, 2).
2. **Widen the backward-compatibility section.** Ask for separate ratings
   for:
   - source programs;
   - Template Haskell and documented GHC API surfaces used by plugins;
   - builds with `-Werror` under `-Wall`;
   - changes of default, such as language editions.

   A proposal that changes the TH AST should say how TH libraries migrate,
   for example through `th-abstraction` (lessons 3, 5, 8).
3. **Make warning periods checkable.** A breaking change should come with:
   - a named warning flag that can be suppressed;
   - the warning on by default, not only under `-Wcompat`, in at least one
     release before the break.

   The committee should confirm the warning has shipped before approving the
   step that breaks code (lesson 6).
4. **Keep the `implemented` field accurate**, for example by checking it
   against ticket milestones at each release. The review found it wrong or
   blank for many proposals.

### For GHC developers and release managers

1. **Give every change that rejects or reinterprets previously accepted
   programs a breakage review**, whether or not it comes from a proposal.
   This includes bug fixes and refactorings. Label such merge requests, and
   require for each:
   - a release-note entry;
   - a migration-guide entry;
   - an impact measurement on head.hackage.

   (Lessons 2, 7.)
2. **Build the breaking-changes section of the release notes from those
   labels**, and check it against the patches head.hackage needed during
   the release cycle (lesson 7).
3. **Diff APIs between releases mechanically**: exports, instances, types,
   Safe Haskell trust (B7), and names visible through `Generic` and
   `Typeable` (B9). Do this for `base`, `ghc-prim` and `template-haskell`.
   Review the diff before release (lessons 2, 7).
4. **Run a Haskell 2010 conformance suite in GHC's testsuite.** It should
   hold programs the report accepts and programs it rejects, with expected
   results, like the [witnesses](../ghc-extensions/witnesses) in this
   repository. It would have flagged the 9.12 defaulting change and the
   #229 deviations (lessons 2, 8).
5. **Keep APIs stable in minor releases.** When a backport must change a
   type, keep the old function under its old name, and only bump boot
   libraries with new exports in a major release (lesson 10).
6. **Make diagnostics point to the change.** For errors and warnings
   introduced by a known change, mention the GHC version and link to the
   migration-guide entry, through the error-code index (lesson 11).

### For the Core Libraries Committee and library maintainers

1. **Measure export additions to `Prelude` and to modules commonly imported
   whole** (`Data.Functor`, `Data.List`, `Control.DeepSeq`, `Data.Text`)
   with a clc-stackage build before accepting them. Publish a migration guide
   with the release (lesson 4).
2. **Support implementing #652 (import shadowing).** It turns most added
   exports into non-breaking changes, and addresses the most common kind of
   breakage in the catalog (lesson 4).
3. **Separate deprecation from changes in behaviour.** Deprecate in one
   release, and change semantics or remove in a later one. A field that
   starts throwing at run time ([B8](base.md#b8)) is a semantic change, not
   a deprecation (lesson 6).
4. **Avoid re-exporting whole modules**, which makes downstream namespaces
   depend on upstream export lists ([K1](boot-libraries.md#k1)) (lesson 4).
5. **Continue decoupling boot libraries**: reinstallable `base`,
   `template-haskell` no longer wired in, private dependencies in Cabal.
   Then a GHC upgrade need not force library upgrades (lesson 9).

### For users

1. **Name a language edition** in every package (lesson 8).
2. **Import modules that grow with an import list, or qualified.** This
   applies especially to `Data.Functor`, `Data.Text`, `Control.DeepSeq` and
   `mtl`'s modules (lesson 4).
3. **Use `-Werror` in CI, not in the default build**, and avoid
   `-Weverything`. Then a new warning is a task, not a blocked upgrade
   (lesson 5).
4. **Apply forward-compatible mitigations before upgrading**, and report
   breakage with its root cause to the Tilapia inventories (lesson 11).

### For this report

1. **Decide how an added export interacts with local definitions.** §5.5.2
   is the source of lesson 4. A revision could adopt the semantics of #652,
   so that a module's own definitions take priority over imported names.
2. **Decide on #229's lexical rules.** Either adopt them in a revision, with
   the four programs that change meaning listed, or keep them as a
   documented GHC deviation (lesson 8).
3. **Run the witness suite against each new GHC release**, so that
   deviations such as the 9.12 defaulting change are noticed when they
   appear, not years later (lesson 2).
