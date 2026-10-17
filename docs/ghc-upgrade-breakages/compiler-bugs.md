# Compiler bugs

Cases caused by a compiler bug or regression. Part of the [GHC upgrade
breakage catalog](README.md), which explains the sources and the
classification.

## X1

**"The impossible happened" with existential types.** Reported by Ellis
(9.6).

- **Root cause.** Unidentified. The workaround (move an inner binding to top
  level and mark it `NOINLINE`) points to the optimiser, not the type
  checker. Candidates: `lookupIdSubst` panics on 9.4 and 9.6
  ([#25424](https://gitlab.haskell.org/ghc/ghc/-/issues/25424),
  [#25064](https://gitlab.haskell.org/ghc/ghc/-/issues/25064)).
- **Mitigation.** FC, as above.

## X2

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
