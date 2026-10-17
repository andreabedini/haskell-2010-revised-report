# Observations

Patterns in the catalog that matter for a revision of the report. Part of the
[GHC upgrade breakage catalog](README.md), which explains the sources and the
classification.

These patterns matter for a revision of the report.

**Adding an export breaks code.** B1, B5, B6, K2, K3 and K6 all add a name
to a module. Under §5.5.2 the import itself is legal, but every unqualified
use of the name becomes ambiguous. This includes uses of a module's own
top-level definitions, as in the `sin` example in §5.5.2. So the PVP's rule
that additions are non-breaking holds only for code that imports with lists
or qualifies its imports. K1 is the same problem in the other direction.
A revision could let local definitions shadow imported names, or make an
added export a non-breaking change for unqualified imports in some other
way.

**Most breakage is in diagnostics.** W1–W10 and B4 break only `-Werror`
builds, or appear where warnings are on by default. The report says nothing
about warnings. Several cases (L2, W2, W9) show the same path: GHC first
warns, then turns the warning on by default, and later rejects or plans to
reject the program. In three cases (W5, W8 and the long-distance part of
W1), the new warning is right by the report's semantics and the old
silence was a bug.

**`Haskell2010` mode protects some code, but not all of it.**
- Because `Haskell2010` implies `DeepSubsumption`, L1 did not reach modules
  compiled as Haskell 2010 from GHC 9.2.4 on. GHC's default language moved
  to `GHC2021` in 9.2, so modules that do not name a language are not
  protected.
- L5 goes the other way: it reaches only `Haskell2010` modules, because
  `GHC2021` includes `FlexibleContexts`.
- L6 is the one case where GHC rejects Haskell 2010 code that the report
  allows. L8 is a case where GHC moved closer to the report.

**Boot libraries tie library churn to compiler upgrades.** K1–K6, and E1, E3
and E4 indirectly, are library changes that a GHC upgrade forces through
boot libraries or upper bounds.

**GHC's API and Template Haskell are a stability boundary of their own.**
A1–A8 do not touch the language, but they break tools.
