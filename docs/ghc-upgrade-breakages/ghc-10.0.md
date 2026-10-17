# GHC 10.0: expected breakage

Breakage we expect from the upgrade to GHC 10.0, the next major release. Part
of the [GHC upgrade breakage catalog](README.md), which explains the sources
and the classification.

The rest of the catalog records what broke in practice. This chapter looks
forward. Nobody has reported these cases yet. Each one is a change in GHC
10.0 that resembles a catalogued case, or a change that the
[lessons](lessons.md) say is likely to break code. The cases use their own
prefix, **F**, and are not counted in the catalog's totals. When reports from
the GHC 10.0 upgrade come in, a confirmed case should move to its layer's
chapter with a new ID, and this chapter should record where it went.

## Method

GHC 10.0.1 is compared with GHC 9.14.1. The sources are:

- the [10.0.1 release notes](https://gitlab.haskell.org/ghc/ghc/-/blob/ghc-10.0/docs/users_guide/10.0.1-notes.rst)
  on the `ghc-10.0` branch (commit `2994ef05`, 18 September 2026; tag
  `ghc-10.0.1-alpha1`, 17 September 2026);
- the changelogs of `base`, `ghc-prim`, `template-haskell`,
  `ghc-experimental` and `ghc-internal` on that branch;
- the boot library submodules on that branch, compared with
  `ghc-9.14.1-release` and with `ghc-9.14.2-rc2`;
- the [GHC 10.0 migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/10.0)
  on the GHC wiki;
- the commits behind the changes, and the patches in
  [head.hackage](https://gitlab.haskell.org/ghc/head.hackage/-/tree/master/patches).

Nothing here has been compiled with GHC 10.0. The cases come from reading
sources and diffs. The [open items](#open-items) list what remains to check.

## Summary

| ID | Expected breakage | Layer | Mitigation | Report | Precedent |
|---|---|---|---|---|---|
| [F1](#f1) | The default language becomes `GHC2024`, which turns on `MonoLocalBinds` | Language | FC | §4.5.2 | [L1](language.md#l1), lesson 8 |
| [F2](#f2) | Infix promoted data constructors need `DataKinds` | Language | FC | — | [L5](language.md#l5), lesson 2 |
| [F3](#f3) | Namespace specifiers on subordinate export items are checked | Language | FC | §5.2 | lesson 2 |
| [F4](#f4) | `static e` allows only top-level free variables | Language | FC | — | lesson 2 |
| [F5](#f5) | `LinearTypes` syntax changes for `Modifiers` | Language | FC | — | [L3](language.md#l3) |
| [F6](#f6) | `init` and `last` warn as partial | Diagnostics | FC | §9.1 | [B4](base.md#b4) |
| [F7](#f7) | `deepseq` deprecates `NFData` for functions, in a minor release too | Diagnostics | FC | — | [K2](boot-libraries.md#k2), lessons 5 and 10 |
| [F8](#f8) | Polymorphic specialisation is on by default | Bug | FC | — | [X1](compiler-bugs.md#x1) |
| [F9](#f9) | `Data.List` exports `nubOrd` and `nubOrdBy` | base | FC | §5.5.2 | [B5](base.md#b5), [B6](base.md#b6) |
| [F10](#f10) | `Control.Monad` exports `thenM`, `Control.Applicative` exports `thenA` | base | FC | §5.5.2 | [B1](base.md#b1) |
| [F11](#f11) | Smaller export and instance additions | base | Partial | §5.5.2, §4.3.2 | [B5](base.md#b5), [K5](boot-libraries.md#k5) |
| [F12](#f12) | `GHC.Num.{BigNat,Integer,Natural}` leave `base` without a warning | base | FC | — | [B7](base.md#b7) |
| [F13](#f13) | `Bifunctor` instances for tuples become strict | base | FC | — | [B8](base.md#b8) |
| [F14](#f14) | Other run-time changes in `base` | base | Partial | §9 | [B8](base.md#b8) |
| [F15](#f15) | Exceptions are displayed differently again | base | — | — | lesson 1 |
| [F16](#f16) | GHC 9.14.2 brings new versions of `deepseq`, `text` and `transformers` | Boot library | FC | §5.5.2 | [K2](boot-libraries.md#k2), [K3](boot-libraries.md#k3) |
| [F17](#f17) | `time`, `mtl` and `text` change behaviour or add names | Boot library | Partial | §5.5.2 | [K6](boot-libraries.md#k6), lesson 9 |
| [F18](#f18) | The typechecker plugin API changes | GHC internals | BF | — | [A1](ghc-internals.md#a1)–[A3](ghc-internals.md#a3) |
| [F19](#f19) | The GHC syntax tree changes | GHC internals | BF | — | [A8](ghc-internals.md#a8) |
| [F20](#f20) | `template-haskell` 2.25 and the move of `Q` | GHC internals | FC | — | [A4](ghc-internals.md#a4)–[A7](ghc-internals.md#a7), [E6](ecosystem.md#e6) |
| [F21](#f21) | `-fbyte-code` no longer produces object code | Tooling | FC | — | lesson 7 |
| [F22](#f22) | GHC's output, package database and bindists change | Tooling | Partial | — | [T2](tooling.md#t2) |

## Language

### F1

**The default language becomes `GHC2024`, which turns on
`MonoLocalBinds`.**

- **Root cause.** [Proposal #632](https://github.com/ghc-proposals/ghc-proposals/pull/632),
  [#26039](https://gitlab.haskell.org/ghc/ghc/-/issues/26039) (commit
  `7fbb4fcb`). `GHC2024` adds `DataKinds`, `DerivingStrategies`,
  `DisambiguateRecordFields`, `ExplicitNamespaces`, `GADTs`, `LambdaCase`,
  `MonoLocalBinds` and `RoleAnnotations` to `GHC2021`.
  - `MonoLocalBinds` is the risk. A local `let` or `where` binding that
    mentions a variable from an enclosing scope is no longer generalised, so
    using it at two types becomes a type error.
  - The other additions only make more programs legal, or reserve syntax
    that ordinary programs do not use.
  - Cabal 3.18.1.0, which GHC 10.0 ships, still passes `-XHaskell98` when a
    component has no `default-language`
    (`Distribution.Simple.GHC.Internal.componentGhcOptions`). So packages
    built by Cabal or Stack do not see the change.
  - Code built without Cabal does see it: `ghc`, `ghci` and `runghc` run
    directly, scripts, and build systems such as Bazel, Nix or Shake that
    pass no language flag.
  - The migration guide does not mention the change.
- **Mitigation.** FC: name a language edition in every module or build
  target, or give the local bindings type signatures.
- **Report.** §4.5.2 generalises every `let` binding. With
  `MonoLocalBinds`, GHC does not. [W3](diagnostics.md#w3) is the same
  extension reached through `GADTs`.
- **Precedent.** [L1](language.md#l1): GHC 9.2 made `GHC2021` the default,
  and modules that named no language lost the old behaviour.

### F2

**Infix promoted data constructors need `DataKinds`.**

- **Root cause.** [#26318](https://gitlab.haskell.org/ghc/ghc/-/issues/26318)
  (commit `13250d97`). GHC 9.10 began accepting an infix promoted constructor
  such as ``Int ': '[]`` without `DataKinds`. The fix applies the same
  check to infix and prefix uses.
  - Under `GHC2024`, which includes `DataKinds`, nothing changes.
  - Cabal packages that name no language, or name `GHC2021` or
    `Haskell2010`, do see it.
- **Mitigation.** FC: enable `DataKinds`.
- **Report.** Outside Haskell 2010.
- **Precedent.** [L5](language.md#l5): GHC accepted the program only by
  accident, and the fix came with no warning period.

### F3

**Namespace specifiers on subordinate export items are checked.**

- **Root cause.** [#12488](https://gitlab.haskell.org/ghc/ghc/-/issues/12488).
  `module M (T (type A))` used to be accepted and the specifier ignored. It is
  now rejected.
- **Mitigation.** FC: remove the specifier.
- **Report.** §5.2 defines the export list. The report has no namespace
  specifiers.

### F4

**`static e` allows only top-level free variables.**

- **Root cause.** [Proposal #732](https://github.com/ghc-proposals/ghc-proposals/pull/732),
  [#26556](https://gitlab.haskell.org/ghc/ghc/-/issues/26556). The rule for
  `StaticPointers` becomes: every free term variable of `e` must be bound at
  top level. Programs that used closed local bindings inside `static` are
  rejected. Users are mostly distributed-computing libraries.
- **Mitigation.** FC: move the bindings to top level.
- **Report.** Outside Haskell 2010.

### F5

**`LinearTypes` syntax changes for `Modifiers`.**

- **Root cause.** The new `Modifiers` extension generalises the `%m` syntax.
  - `f :: Int %m -> Int` needs `forall (m :: Multiplicity).`.
  - Modifiers bind tighter than constructors, so `let %1 x:xs = …` now parses
    as `let (%1 x):xs = …`.
  - `-XNoModifiers` restores only part of the old syntax.
  - List comprehensions become non-linear
    ([#25081](https://gitlab.haskell.org/ghc/ghc/-/issues/25081)).
- **Mitigation.** FC: add kind annotations and parentheses.
- **Report.** Outside Haskell 2010. `LinearTypes` is Experimental, so the
  stability principles do not cover it.
- **Precedent.** [L3](language.md#l3).

## Diagnostics

### F6

**`init` and `last` warn as partial.**

- **Root cause.** [CLC proposal #292](https://github.com/haskell/core-libraries-committee/issues/292),
  base-4.23. The `x-partial` category is on by default, so the warning
  appears without `-Wall`. The base changelog calls the proposal "CLC
  proposal #87", the one behind [B4](base.md#b4), but links to #292.
- **Mitigation.** FC: `-Wno-x-partial -Wno-unrecognised-warning-flags`, or
  rewrite the code.
- **Report.** §9.1 defines `init` and `last` as partial functions.
- **Precedent.** [B4](base.md#b4), which put the same warning on `head` and
  `tail`.

### F7

**`deepseq` deprecates `NFData` for functions, in a minor release too.**

- **Root cause.** deepseq-1.5.2.0 ([#16](https://github.com/haskell/deepseq/issues/16),
  [#109](https://github.com/haskell/deepseq/issues/109)) marks
  `instance NFData (a -> b)` with a `DEPRECATED` pragma on GHC 9.10 and
  later.
  - Every use of the instance should warn. That includes a derived or
    `Generic`-default `NFData` instance for a record with a function field.
    This has not been checked.
  - GHC 9.14.2-rc2 already ships deepseq-1.5.2.0, so the warning arrives in
    a minor release before 10.0.
  - Neither the release notes nor the migration guide mention it.
- **Mitigation.** FC: write the instance by hand with `rwhnf` for the
  function fields, or drop the instance.
- **Report.** Outside the report.
- **Precedent.** [K2](boot-libraries.md#k2): deepseq changed in a GHC minor
  release (9.8.3) and broke builds.

## Compiler bugs

### F8

**Polymorphic specialisation is on by default.**

- **Root cause.** [#23559](https://gitlab.haskell.org/ghc/ghc/-/issues/23559)
  (commit `1fd25987`). `-fpolymorphic-specialisation` was off because of
  earlier soundness bugs. Fixes in the same release show that this part of
  the optimiser is still changing:
  - the specialiser dropped an argument that a stable unfolding still used
    ([#27703](https://gitlab.haskell.org/ghc/ghc/-/issues/27703));
  - an absent constraint argument became an error thunk that was then
    evaluated ([#27627](https://gitlab.haskell.org/ghc/ghc/-/issues/27627));
  - a dictionary was evaluated speculatively and crashed or looped through
    an hs-boot import ([#27704](https://gitlab.haskell.org/ghc/ghc/-/issues/27704),
    [#27717](https://gitlab.haskell.org/ghc/ghc/-/issues/27717));
  - demand analysis gave an absent demand to a used argument
    ([#26416](https://gitlab.haskell.org/ghc/ghc/-/issues/26416),
    [#27626](https://gitlab.haskell.org/ghc/ghc/-/issues/27626)).

  All of these crash at run time, not at compile time. Compile time can
  also grow: GHC's own `ExactPrint.hs` needed `-fno-specialise` to avoid a
  fourfold increase.
- **Mitigation.** FC: `-fno-polymorphic-specialisation`, as a first step
  when bisecting a new crash or slowdown.
- **Report.** Outside the report.
- **Precedent.** [X1](compiler-bugs.md#x1), an optimiser bug, though one
  that failed at compile time. [X2](compiler-bugs.md#x2)'s original case is
  fixed on master (`97adaf89`), which is not on the `ghc-10.0` branch.

## `base`

### F9

**`Data.List` exports `nubOrd` and `nubOrdBy`.**

- **Root cause.** [CLC proposal #336](https://github.com/haskell/core-libraries-committee/issues/336),
  base-4.23. `Data.List.NonEmpty` gains the same names.
  - `containers` exports `nubOrd` from `Data.Containers.ListUtils`. A
    module that imports `Data.List` whole and also uses `nubOrd` from
    `containers`, or defines its own, gets an ambiguity error.
  - `extra`'s `Data.List.Extra` re-exports `Data.List` whole and defines
    `nubOrd`. Its master branch now defines `nubOrd` and `nubOrdBy` only for
    GHC 9.14 and older, so the library needed a breaking fix
    ([K1](boot-libraries.md#k1) in the other direction).
- **Mitigation.** FC: import `Data.List` with an import list, or qualified.
- **Report.** §5.5.2. `Data.List` is part of the Haskell 2010 libraries
  (Part II), so this adds to a module the report specifies.
- **Precedent.** [B5](base.md#b5), [B6](base.md#b6), lesson 4.

### F10

**`Control.Monad` exports `thenM`, `Control.Applicative` exports `thenA`.**

- **Root cause.** [CLC proposal #351](https://github.com/haskell/core-libraries-committee/issues/351),
  base-4.23. Both modules are usually imported whole. A module that defines
  its own `thenM` or `thenA` and uses it unqualified gets an ambiguity
  error. The migration guide says `Control.Monad` exports both names. In
  fact `thenA` is in `Control.Applicative`.
- **Mitigation.** FC: import lists, or hide the new name.
- **Report.** §5.5.2. `Control.Monad` is part of the Haskell 2010 libraries.
- **Precedent.** [B1](base.md#b1), lesson 4.

### F11

**Smaller export and instance additions.**

- **Root cause.** base-4.23 also adds:
  - `Data.List.NonEmpty.mapMaybe` ([CLC #337](https://github.com/haskell/core-libraries-committee/issues/337));
  - `labelThread` in `Control.Concurrent` ([CLC #376](https://github.com/haskell/core-libraries-committee/issues/376));
  - `System.IO.hGetNewlineMode` ([CLC #370](https://github.com/haskell/core-libraries-committee/issues/370));
  - `Semigroup` and `Monoid` instances for lazy `ST`
    ([CLC #374](https://github.com/haskell/core-libraries-committee/issues/374)),
    which clash with orphan instances of the same classes;
  - a more general type for `deleteBy` and `deleteFirstsBy`
    ([CLC #372](https://github.com/haskell/core-libraries-committee/issues/372)),
    which can leave a type ambiguous where the old one fixed it.
- **Mitigation.** Partial. Import lists cover the names. An orphan instance
  needs CPP to drop it on base-4.23 (BF).
- **Report.** §5.5.2 for the names. §4.3.2 forbids two instances for the
  same class and type, and §5.4 imports instances implicitly.
- **Precedent.** [B5](base.md#b5) for the names, [K5](boot-libraries.md#k5)
  for instances that come and go with a library.

### F12

**`GHC.Num.{BigNat,Integer,Natural}` leave `base` without a warning.**

- **Root cause.** [CLC proposal #359](https://github.com/haskell/core-libraries-committee/issues/359).
  - In 9.14.1 the three modules re-export `ghc-internal` modules with no
    deprecation pragma. In 10.0 they are gone from `base`.
  - [CLC #360](https://github.com/haskell/core-libraries-committee/issues/360)
    deprecates the internals that `GHC.Num` still exports, with removal
    planned for base-4.24.
  - `GHC.Desugar` is removed too, a release later than planned.
- **Mitigation.** FC: depend on `ghc-bignum`, which has these modules since
  GHC 9.0.
- **Report.** Outside the report.
- **Precedent.** [B7](base.md#b7), also in `GHC.Num`. The removal had no
  warning period, against GR3.

### F13

**`Bifunctor` instances for tuples become strict.**

- **Root cause.** [CLC proposal #339](https://github.com/haskell/core-libraries-committee/issues/339).
  `bimap`, `first` and `second` on tuples now match the pair strictly
  (`bimap f g (a, b)` instead of `bimap f g ~(a, b)`), the same as `fmap`.
  Code that ties a knot through `first` or `second`, or applies them to
  `⊥`, can now diverge. The program still compiles.
- **Mitigation.** FC: write the lazy match explicitly,
  `\ ~(a, b) -> (f a, b)`.
- **Report.** Outside Haskell 2010.
- **Precedent.** [B8](base.md#b8): a change that shows only at run time.
  GR1 counts semantics as part of the API.

### F14

**Other run-time changes in `base`.**

- **Root cause.** None of these changes is visible to the compiler.
  - `iterate'` forces each element when its cons cell is forced
    ([CLC #335](https://github.com/haskell/core-libraries-committee/issues/335)).
  - `sortOn` compares with `(>)` instead of `compare`
    ([CLC #332](https://github.com/haskell/core-libraries-committee/issues/332)).
    The order differs for `Ord` instances that break the laws, such as
    `Double` with NaN.
  - `hIsReadable` and `hIsWritable` throw on every closed or semi-closed
    handle, not just file handles
    ([CLC #371](https://github.com/haskell/core-libraries-committee/issues/371)).
  - `toRational` changes for infinities and NaN
    ([CLC #338](https://github.com/haskell/core-libraries-committee/issues/338)).
  - Constant folding keeps the sign of zero, so `x + 0` is no longer
    rewritten to `x` ([#9811](https://gitlab.haskell.org/ghc/ghc/-/issues/9811),
    [#21227](https://gitlab.haskell.org/ghc/ghc/-/issues/21227)). This is a
    correctness fix, but a program's output can change.
- **Mitigation.** Partial: tests that cover these functions.
- **Report.** §9 gives a reference definition of `iterate` in the Prelude.
  `sortOn`, `iterate'` and handle predicates are outside the report.
- **Precedent.** [B8](base.md#b8).

### F15

**Exceptions are displayed differently again.**

- **Root cause.** base-4.23 changes the output of uncaught exceptions in
  several ways:
  - backtraces for `error` are taken when it is thrown
    ([CLC #383](https://github.com/haskell/core-libraries-committee/issues/383));
  - `throw` and `throwSTM` hide implementation frames
    ([CLC #387](https://github.com/haskell/core-libraries-committee/issues/387));
  - `onException` and `catchSTM` add `WhileHandling` annotations
    ([CLC #397](https://github.com/haskell/core-libraries-committee/issues/397),
    [#25365](https://gitlab.haskell.org/ghc/ghc/-/issues/25365));
  - `toException` keeps the exception context, and `WhileHandling` shows it
    ([#27455](https://gitlab.haskell.org/ghc/ghc/-/issues/27455),
    [#27456](https://gitlab.haskell.org/ghc/ghc/-/issues/27456));
  - `throwSTM` gains a `HasCallStack` constraint.

  Golden tests of error output, and tools that parse it, will need
  updating.
- **Mitigation.** None that works across versions, short of normalising the
  output in tests.
- **Report.** Outside the report.
- **Precedent.** Lesson 1: proposal #330 already changed how exceptions are
  displayed in three consecutive releases. This is the fourth.

## Other boot libraries

### F16

**GHC 9.14.2 brings new versions of `deepseq`, `text` and `transformers`.**

- **Root cause.** The submodules of `ghc-9.14.2-rc2` move to:
  - deepseq-1.5.2.0, with the deprecation in [F7](#f7);
  - text-2.1.4, which moves to Unicode 17;
  - transformers-0.6.3.0, which adds `onE` to
    `Control.Monad.Trans.Except` and, since 0.6.2.0, defines `runExceptT`
    and similar functions as record fields;
  - process-1.6.30.0.

  GHC 10.0 ships the same versions. So a team that stays on 9.14 meets part
  of the 10.0 change set in a minor release.
- **Mitigation.** FC: import lists, and `-Wno-deprecations` for F7.
- **Report.** §5.5.2.
- **Precedent.** [K2](boot-libraries.md#k2) and [K3](boot-libraries.md#k3),
  lesson 10.

### F17

**`time`, `mtl` and `text` change behaviour or add names.**

- **Root cause.** GHC 10.0 ships time-1.16.0.1 (from 1.15), mtl-2.3.2 (from
  2.3.1), filepath-1.5.5.0, directory-1.3.11.0, os-string-2.0.11 and
  file-io-0.2.0.
  - time-1.16 adds `periodIn`. time-1.16.0.1 changes what its parsers accept:
    numbers that overflow their type are rejected, and the case-insensitive
    matching of AM/PM markers, `UTC` and time zone names is fixed. It also
    fixes several date calculations, such as `gregorianEaster`.
  - mtl-2.3.2 adds the `Accum` monad and `onError`.
  - text-2.1.4 changes case mapping and character properties with
    Unicode 17.

  Cabal can install other versions of these libraries, unless the `ghc`
  package is in the build plan. Then they are fixed to GHC's versions.
- **Mitigation.** Partial: import lists for new names. Behaviour changes
  need tests.
- **Report.** §5.5.2.
- **Precedent.** [K6](boot-libraries.md#k6), which also came from `time`.
  Lesson 9.

## GHC internals

### F18

**The typechecker plugin API changes.**

- **Root cause.** [#26839](https://gitlab.haskell.org/ghc/ghc/-/issues/26839)
  and related work:
  - `tcPluginStop` is split into `tcPluginPostTc` and `tcPluginShutdown`,
    and the same for defaulting plugins;
  - `typecheckModule`, `hscTypecheckRename` and two other functions take an
    extra argument, and `tcRnModule` takes a `TcRnModuleOptions` record;
  - `withTcPlugins`, `withHoleFitPlugins` and `withDefaultingPlugins` become
    `withTcMPlugins`;
  - `RewriterSet` is renamed `CoHoleSet`, and unique tags become the
    `UniqueTag` type. These two appear only in the migration guide.

  head.hackage carries patches for ghc-typelits-natnormalise,
  ghc-typelits-knownnat, ghc-typelits-extra, ghc-tcplugins-extra,
  liquidhaskell-boot, ghcide and hiedb. Not all of them need to be about
  these changes.
- **Mitigation.** BF: CPP on `MIN_VERSION_ghc(10,0,0)`.
- **Report.** Outside the report.
- **Precedent.** [A1](ghc-internals.md#a1)–[A3](ghc-internals.md#a3).

### F19

**The GHC syntax tree changes.**

- **Root cause.** Several changes reach `ghc-lib-parser` and the tools built
  on it (hlint, ormolu, fourmolu, HLS):
  - `HsTyLit` is replaced by `HsLit` with new `HsNatural` and `HsDouble`
    constructors ([#26862](https://gitlab.haskell.org/ghc/ghc/-/issues/26862));
  - `HsMultilineString` is merged into `HsString`
    ([#26860](https://gitlab.haskell.org/ghc/ghc/-/issues/26860));
  - `TopLevelFlag`, `RuleName`, `OverlapMode` and the foreign-call types
    move to new modules, and `OverlapMode`, `CCallTarget`, `CType` and
    `Header` gain extension points;
  - the `ModLocation` pattern synonym is removed
    ([#24932](https://gitlab.haskell.org/ghc/ghc/-/issues/24932));
  - `SourceError` carries a `SourceErrorContext`
    ([#26387](https://gitlab.haskell.org/ghc/ghc/-/issues/26387)).
- **Mitigation.** BF.
- **Report.** Outside the report.
- **Precedent.** [A8](ghc-internals.md#a8).

### F20

**`template-haskell` 2.25 and the move of `Q`.**

- **Root cause.** The Template Haskell AST does not change: no constructor
  of the AST types in `GHC.Internal.TH.Syntax` or `template-haskell` differs
  between 9.14.1 and 10.0. Two smaller things remain:
  - `Q` moves from `GHC.Internal.TH.Syntax` to `GHC.Internal.TH.Monad`.
    `Language.Haskell.TH.Syntax` still exports it, so only code that imports
    `ghc-internal` directly breaks.
  - `template-haskell` goes from 2.24 to 2.25 with only additions
    (`defaultQuasiQuoter`, `namedDefaultQuasiQuoter`,
    `addDependentDirectory`). Packages with an upper bound below 2.25 still
    need a release or a Hackage revision.
- **Mitigation.** FC: import `Q` from `template-haskell`. Bounds need
  maintainers.
- **Report.** Outside the report.
- **Precedent.** [A4](ghc-internals.md#a4)–[A7](ghc-internals.md#a7) changed
  the AST. This release does not, which matches lesson 3's advice. The bounds
  problem is [E6](ecosystem.md#e6).

## Tooling

### F21

**`-fbyte-code` no longer produces object code.**

- **Root cause.** Bytecode objects ([commit `6bd8155c`](https://gitlab.haskell.org/ghc/ghc/-/commit/6bd8155c99))
  make `-fbyte-code` select only the bytecode backend.
  - A library with `{-# OPTIONS_GHC -fbyte-code #-}` in a module gets no
    object code for it, and fails to link.
  - The migration guide names `lens` as a library that used the pragma, to
    work around unboxed tuples in GHCi before GHC 9.2.
  - The release notes do not mention the change.
- **Mitigation.** FC: remove the pragma.
- **Report.** Outside the report.
- **Precedent.** Lesson 7: a breaking change that is missing from the
  release notes.

### F22

**GHC's output, package database and bindists change.**

- **Root cause.** Several changes reach tools and build setups rather than
  source code:
  - `-fhide-source-paths` is on by default at verbosity 1
    ([#25345](https://gitlab.haskell.org/ghc/ghc/-/issues/25345)), and
    "Compilation had errors" loses its `<no location info>: error:` prefix.
    Tools that parse GHC's output will see different text.
  - The package database format gains `extra-libraries-static`
    ([#26434](https://gitlab.haskell.org/ghc/ghc/-/issues/26434)).
  - GHC reads `lib/targets/default.target`, and entries are removed from
    `lib/settings` ([#24212](https://gitlab.haskell.org/ghc/ghc/-/issues/24212)).
  - `iserv` is removed. The external interpreter is built on demand
    ([#24731](https://gitlab.haskell.org/ghc/ghc/-/issues/24731)), which
    affects setups that pass `-pgmi`.
  - `-jsem` moves to protocol version 2 (semaphore-compat-2.0.1,
    [#25087](https://gitlab.haskell.org/ghc/ghc/-/issues/25087)), so it
    needs a matching cabal-install.
  - Bindists for Debian 9 and 10 and Ubuntu 18.04 and 20.04 are dropped
    ([#25876](https://gitlab.haskell.org/ghc/ghc/-/issues/25876)), and
    building GHC needs GHC 9.10 or later.
- **Mitigation.** Partial.
- **Report.** Outside the report.
- **Precedent.** [T2](tooling.md#t2).

## Against the lessons

Read against [Lessons learned](lessons.md), GHC 10.0 repeats some patterns
and avoids others.

- **Lesson 2, breaking changes outside the proposal process.** F2 and F3 are
  bug fixes that reject programs, with no warning period. F8 changes a
  default with a known history of soundness bugs.
- **Lesson 3, Template Haskell.** The TH AST does not change (F20). The GHC
  API changes a lot (F18, F19).
- **Lesson 4, added exports.** Five modules gain names (F9–F11). Proposal
  #652 (import shadowing) would make them safe, but there is no sign of it
  on the 10.0 branch.
- **Lesson 5, warnings.** F6 and F7 break `-Werror` builds, and F7 comes
  first in a minor release.
- **Lesson 6, warning periods.** F12 removes modules with no deprecation in
  9.14.1. F13–F15 change behaviour with no warning, which no warning
  could cover anyway.
- **Lesson 7, release notes.** F7 is in neither the release notes nor the
  migration guide. F21 and the renames in F18 are only in the migration
  guide. F1, F13 and F14 are only in the release notes. The guide puts
  `thenA` in the wrong module (F10).
- **Lesson 8, editions.** F1 repeats the GHC 9.2 pattern. Cabal's
  `Haskell98` fallback protects packages, but not code built another way.
- **Lesson 10, minor releases.** F16 brings three of these library versions
  to 9.14.2.

## Changes not counted

These changes are in 10.0 but are unlikely to break code. They should be
watched:

- `Type` and `Constraint` become distinct types. Type family instances that
  used to conflict are now accepted.
- Closed type families generate extra functional dependencies
  ([#23162](https://gitlab.haskell.org/ghc/ghc/-/issues/23162)), and
  typechecker plugins run during pattern-match checking
  ([#26395](https://gitlab.haskell.org/ghc/ghc/-/issues/26395)). Both should
  remove false warnings rather than add new ones.
- Non-pointer constructor fields are laid out by size, and enumerations
  unpack to `Word8#` or wider. Code that reads closures through `ghc-heap`
  or by hand sees a different layout.
- The non-threaded RTS uses a new `poll` I/O manager by default (except on
  macOS), and the signal-based ticker is gone.
- `-O2` now runs LLVM at `-O3`.

## Open items

- None of the cases has a witness program. Witnesses should be compiled with
  GHC 9.14.1 and 10.0.1-alpha1 or later, starting with F1, F2, F7, F9, F10
  and F13.
- F7: check that a `Generic`-default `NFData` instance with a function field
  warns in the user's module.
- F8: measure compile time and check for crashes on a large codebase with
  and without `-fno-polymorphic-specialisation`.
- F18: read the head.hackage patches to find which change each one is for.
- When a 10.0 breakage inventory opens on Tilapia or Discourse, compare it
  with this chapter, and move confirmed cases into the catalog.
