# Tooling

Cases caused by a change in a build tool or developer tool. Part of the [GHC
upgrade breakage catalog](README.md), which explains the sources and the
classification.

## T1

**`brittany` is unmaintained.** Reported by Ellis.

- **Root cause.** The last release supports GHC 9.0 only. ghc-exactprint was
  rewritten for GHC 9.2's in-tree annotations, and nobody ported brittany.
  The [README](https://github.com/lspitzner/brittany/commit/420eac889e337c1b30a239bf57ca6a9f9eb0790b)
  announced the end of maintenance in November 2022.
- **Mitigation.** FC: switch to ormolu or fourmolu.

## T2

**Hadrian does not build GHCi for cross-compilers.** Reported by Ellis.

- **Root cause.** GHC 9.6 removed the make build system
  ([announcement](https://www.haskell.org/ghc/blog/20220805-make-to-hadrian.html)).
  Hadrian builds a stage-1 cross compiler with no internal interpreter and
  ignores `finalStage = Stage2`
  ([#26289](https://gitlab.haskell.org/ghc/ghc/-/issues/26289)). Stage-2
  cross compilers landed on master in 2026
  ([!15231](https://gitlab.haskell.org/ghc/ghc/-/merge_requests/15231)).
