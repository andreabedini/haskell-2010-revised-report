# Other boot libraries

Cases caused by a change to a library that ships with GHC, so that upgrading
GHC forces it. Part of the [GHC upgrade breakage catalog](README.md), which
explains the sources and the classification.

## K1

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

## K2

**`deepseq` exports `Unit`.** Reported by Tilapia 9.8.4.

- **Root cause.** deepseq-1.5.1.0 added `newtype Unit` (a monoid built on
  `seq`), and GHC 9.8.3 picked it up. An unqualified
  `import Control.DeepSeq` in GHC's own `GHC.Unit.Types` made `Unit`
  ambiguous ([#25411](https://gitlab.haskell.org/ghc/ghc/-/issues/25411)),
  so GHC 9.10.1 could not be built with 9.8.3. Adding an export is a minor
  change under the PVP.
- **Mitigation.** FC: explicit or qualified imports.
- **Report.** §5.5.2.

## K3

**`Data.Text` exports `show`.** Reported by Tilapia 9.12.

- **Root cause.** text-2.1.2 ([PR #608](https://github.com/haskell/text/pull/608),
  closing [#183](https://github.com/haskell/text/issues/183)), bundled with
  GHC 9.10.2 and 9.12. The name was chosen because `Data.Text` is meant to
  be imported qualified. A clash with `Prelude.show` was raised as an
  objection in 2017.
- **Mitigation.** FC: qualified import.
- **Report.** §5.5.2.

## K4

**`Cabal`'s `readGenericPackageDescription` changes type.** Reported by
Tilapia 9.12.

- **Root cause.** [haskell/cabal#9718](https://github.com/haskell/cabal/pull/9718),
  Cabal 3.14, which GHC 9.12 ships. The aim is to make the library
  independent of the working directory, so builds can run in parallel in
  one process. Paths become `SymbolicPath`s.
- **Mitigation.** BF: CPP on `MIN_VERSION_Cabal(3,14,0)`.

## K5

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

## K6

**`time` hides internal modules and adds pattern synonyms.** Reported by
Discourse 9.14.

- **Root cause.** time-1.15, shipped with GHC 9.14
  ([thread](https://discourse.haskell.org/t/breaking-changes-in-time-1-15-ghc-9-14/13711)).
  The hidden modules broke `timezone-series`. The new pattern synonyms clash
  with local definitions.
- **Mitigation.** Partial.
- **Report.** §5.5.2.
