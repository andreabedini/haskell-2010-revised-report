# Ecosystem

Cases caused by a change in a third-party library that coincided with an
upgrade, often because the old version did not build on the new GHC. Part of
the [GHC upgrade breakage catalog](README.md), which explains the sources and
the classification.

## E1

**`aeson` 2 makes `Object` a `KeyMap`.** Reported by Ellis.

- **Root cause.** Hash flooding ([aeson #864](https://github.com/haskell/aeson/issues/864),
  [HSEC-2023-0001](https://osv.dev/vulnerability/HSEC-2023-0001)).
  aeson-2.0.0.0 made the map type abstract, and 2.0.1.0 switched to an
  ordered map. aeson-1.5.6.0 caps `template-haskell < 2.18`, so it cannot
  build on GHC 9.2 or later, and the GHC upgrade forced the move.
- **Mitigation.** Partial: aeson 2 supports GHC 8.10. Ellis's compat-layer
  PR ([#932](https://github.com/haskell/aeson/pull/932)) was not merged.

## E2

**`xlsx` introduces `RowIndex`, `ColumnIndex` and `wsState`.** Reported by
Ellis as `xls`.

- **Root cause.** xlsx-1.1.0 ([#148](https://github.com/qrilka/xlsx/issues/148),
  [PR #161](https://github.com/qrilka/xlsx/pull/161),
  [PR #158](https://github.com/qrilka/xlsx/pull/158)) added the newtypes to
  stop row and column mix-ups and to reject indices below 1. It is not
  related to GHC.
- **Mitigation.** FC: xlsx-1.1.0 supports GHC 8.10.

## E3

**`flatparse` renames its API.** Reported by Ellis.

- **Root cause.** flatparse-0.4.0.0 ([PR #36](https://github.com/AndrasKovacs/flatparse/pull/36))
  bundled renames such as `anyCharASCII` → `anyAsciiChar` with the port to
  GHC 9.4. The port was needed because of the `Word64#` change (B3,
  [#25](https://github.com/AndrasKovacs/flatparse/issues/25)). There is no
  changelog.
- **Mitigation.** FC: flatparse-0.4 supports GHC 8.10.

## E4

**`constraints-extras` turns `Has` into a class.** Reported by Ellis.

- **Root cause.** constraints-extras-0.4.0.0
  ([PR #35](https://github.com/obsidiansystems/constraints-extras/pull/35)).
  The aims were better type errors and allowing `QuantifiedConstraints`,
  which a type family cannot return. 0.3 caps `base < 4.18`, so GHC 9.6
  forces 0.4.
- **Mitigation.** FC: 0.4 supports old `base`.

## E5

**`genSingletons` stops working.** Reported by Ellis.

- **Root cause.** Not confirmed. Likely causes:
  - singletons 3.0 split into `singletons-th` and `singletons-base`.
  - Each `singletons-th` major version supports exactly one GHC.
  - Generated code needs more extensions (`StandaloneKindSignatures`,
    `NoCUSKs`, `NoStarIsType`).
- **Mitigation.** BF: Ellis's team wrote the generated code by hand.

## E6

**Many upstream packages are broken early in a release cycle.** Reported by
Unpublished (9.6 → 9.8).

- **Root cause.** The combined effect of B4, B5, A4 and the other 9.8 changes
  in the [migration guide](https://gitlab.haskell.org/ghc/ghc/-/wikis/migration/9.8),
  plus upper bounds that lag behind releases.
