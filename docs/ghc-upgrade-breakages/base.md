# `base`

Cases caused by a change to the API of `base` (or `ghc-prim`) visible to
ordinary programs. Part of the [GHC upgrade breakage catalog](README.md),
which explains the sources and the classification.

## B1

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

## B2

**The `MonadFail (ST s)` instance is removed.** Reported by Ellis.

- **Root cause.** [CLC proposal #33](https://github.com/haskell/core-libraries-committee/issues/33),
  base-4.17, GHC 9.4.1 (not 9.6). An instance whose `fail` is `error` goes
  against the MonadFail proposal.
- **Mitigation.** FC: use `error`, and bind refutable patterns through `case`.
- **Report.** §6.3.6 puts `fail` in `Monad`, and §3.14 calls it when a
  pattern fails in `do`. GHC moved `fail` into `MonadFail` (GHC 8.8). `ST` is
  not in the report.

## B3

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

## B4

**`head` and `tail` warn as partial.** Reported by Tilapia 9.8 and
Unpublished (9.6 → 9.8).

- **Root cause.** [CLC proposal #87](https://github.com/haskell/core-libraries-committee/issues/87)
  with the warning categories of [CLC #114](https://github.com/haskell/core-libraries-committee/issues/114)
  and GHC proposal #541. Shipped in base-4.19, GHC 9.8.1
  ([migration guide](https://github.com/haskell/core-libraries-committee/blob/main/guides/warning-for-head-and-tail.md)).
  base-4.23 extends the warning to `init` and `last`
  ([F6](ghc-10.0.md#f6)).
- **Mitigation.** FC: `-Wno-x-partial -Wno-unrecognised-warning-flags`, or
  rewrite the code.
- **Report.** §9.1 defines `head` and `tail` as partial functions. Haskell
  2010 has no pragma for attaching a warning to an entity.

## B5

**`Data.Functor` exports `unzip`.** Reported by Tilapia 9.8 and Unpublished
(9.6 → 9.8).

- **Root cause.** [CLC proposal #88](https://github.com/haskell/core-libraries-committee/issues/88),
  base-4.19, GHC 9.8.1. An unqualified `import Data.Functor` makes `unzip`
  ambiguous with `Prelude.unzip`.
- **Mitigation.** FC: import `Data.Functor` with an import list, or qualified.
- **Report.** §5.5.2. `Data.Functor` is not in the Haskell 2010 libraries.

## B6

**`Prelude` exports `foldl'`.** Reported by Tilapia 9.10.

- **Root cause.** [CLC proposal #167](https://github.com/haskell/core-libraries-committee/issues/167),
  base-4.20, GHC 9.10.1 ([migration guide](https://discourse.haskell.org/t/prelude-foldl-migration-guide/6950)).
  The aim was to steer newcomers away from the space leaks of `foldl`.
- **Mitigation.** FC: `import Prelude hiding (Foldable(..))` plus
  `import Data.Foldable (Foldable(..))`.
- **Report.** §5.5.2 and §5.6.2, as for B1. The Haskell 2010 Prelude exports
  `foldl` and not `foldl'`. The libraries report puts `foldl'` in
  `Data.List`.

## B7

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

## B8

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

## B9

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
