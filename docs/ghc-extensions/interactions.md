# About interactions between GHC extensions

GHC supports well over a hundred language extensions. A future Haskell
report has to decide which of them to standardise, and it cannot take them
one at a time. Some extensions are useless without others. Some are fine on
their own but need new theory when combined. A few change what existing
programs mean. This page looks at how to organise the extensions by those
relations, and what the organisation tells a report.

The facts this discussion relies on (which extensions are conservative,
which imply which, what the language sets contain) are listed in the
[reference](reference.md).

## Three relations, three graphs

"How extensions relate" covers at least three different relations. Each
gives a different graph, and they answer different questions.

### Implication

GHC records that turning on one extension turns on others: `GADTs` implies
`GADTSyntax` and `MonoLocalBinds`, `TypeFamilies` implies `MonoLocalBinds`,
`KindSignatures` and `ExplicitNamespaces`, and so on (see
[Implications](reference.md#implications)). This graph is a DAG, not a tree:
`TypeFamilies` alone has three children, and `ExplicitForAll` has five
parents.

The implication graph is easy to extract, but it says little. It records
which flags GHC turns on, not why. The interesting edges are those where an
interaction was turned into an implication. `GADTs` and `TypeFamilies`
imply `MonoLocalBinds` because generalising local bindings works badly with
local type equalities (Vytiniotis, Peyton Jones and Schrijvers 2010). That
edge records a design decision, not a dependency, and it makes both
extensions non-conservative.

### Layering

A second relation says that one extension can only be specified on top of
another. `FunctionalDependencies` needs `MultiParamTypeClasses`.
`TypeFamilyDependencies` needs `TypeFamilies`. `QuantifiedConstraints` needs
the class system. `DataKinds` and `PolyKinds` need a richer kind system.
This is also a partial order, and it mostly agrees with the implication
graph, but the two are not the same. Layering tells a report the order in
which to introduce extensions.

### Interaction

The relation that matters most for a report is interaction. Two extensions
interact when each is fine alone, but specifying both needs something that
neither needs alone. Several of these are well known:

| Interaction | What it required |
|---|---|
| `FunctionalDependencies` with `GADTs` | Evidence for functional dependencies in the typed core language (Karachalias and Schrijvers 2017). |
| `FunctionalDependencies` with liberal coverage | Without the new evidence, GHC accepts instances that violate the dependency (Karachalias and Schrijvers 2017, section 2.2). |
| `GeneralizedNewtypeDeriving` with `TypeFamilies` | The combination was unsound. Roles fixed it (Weirich et al. 2011; Breitner et al. 2014). |
| `GADTs` with `TypeFamilies` | Type inference with local assumptions, OutsideIn(X), at the cost of principal types (Vytiniotis et al. 2011). |
| `ScopedTypeVariables` with class declarations | The class variable scopes over default methods, which changes how their signatures are read ([witness](witnesses/ScopedTypeVariables.hs)). |
| `RebindableSyntax` with every desugared construct | `do`, literals, `if` and arithmetic sequences refer to whatever names are in scope ([witness](witnesses/RebindableSyntax.hs)). |
| `DuplicateRecordFields` with type inference | Field resolution became type-directed. GHC 9.12 warns that the type-directed part will be removed. |

Some interactions only appear when three or more extensions are combined,
for example GADTs, type families and functional dependencies together. The
interaction structure is therefore a hypergraph, not a graph. In practice it
is easier to draw as clusters of extensions with the expensive edges marked.

## Clusters

Most interactions stay inside a few clusters:

- **Syntax only**: `LambdaCase`, `TupleSections`, `BlockArguments`,
  `MultiWayIf`, `NumericUnderscores`, `ImportQualifiedPost`, `EmptyCase`,
  and similar. Each is a parser change plus a translation. They are nearly
  isolated, and a report could standardise each one on its own.
- **Class system**: `MultiParamTypeClasses`, `FlexibleInstances`,
  `FlexibleContexts`, `FunctionalDependencies`, `UndecidableInstances`,
  overlapping instances, `QuantifiedConstraints`, `ConstraintKinds`.
- **Type level**: `TypeFamilies`, `GADTs`, `DataKinds`, `PolyKinds`,
  `RankNTypes`, `ImpredicativeTypes`, `TypeApplications`,
  `ScopedTypeVariables`, existential quantification.
- **Deriving**: the `Derive*` extensions, `StandaloneDeriving`,
  `DerivingStrategies`, `DerivingVia`, and `GeneralizedNewtypeDeriving`,
  which brings in roles.
- **Records**: `DuplicateRecordFields`, `OverloadedRecordDot`,
  `NoFieldSelectors`, `NamedFieldPuns`, `RecordWildCards`.
- **Evaluation**: `BangPatterns`, `StrictData`, `Strict`, unlifted types.
- **Rebinding and literals**: `RebindableSyntax`, `OverloadedStrings`,
  `OverloadedLists`, `NegativeLiterals`, `NumDecimals`.

The expensive edges are the ones between clusters, such as roles between
deriving and type families, or evidence between the class system and
GADTs. The Haskell Prime effort stalled inside the class-system and
type-level clusters, choosing between functional dependencies and type
families.

## Conservativity

One property belongs to single extensions: whether the extension is
conservative. A conservative extension accepts every program that was
accepted without it, with the same meaning. The [reference](reference.md)
classifies every extension, each non-conservative one backed by a witness
program that GHC checks.

Most extensions are conservative. They add syntax that used to be a parse
error, or they relax a static check. The non-conservative ones fall into a
few families:

- **Stolen identifiers**: `Arrows`, `RecursiveDo`, `StaticPointers`,
  `PatternSynonyms` and `TransformListComp` make ordinary identifiers
  special.
- **Stolen lexical syntax**: `MagicHash`, `OverloadedLabels`,
  `ImplicitParams`, `QuasiQuotes`, `TemplateHaskellQuotes`,
  `UnboxedTuples`, `UnicodeSyntax`, `MultilineStrings`,
  `OverloadedRecordDot` and `ExtendedLiterals` read a sequence of
  characters as a new token where Haskell 2010 read several.
- **Changed literals**: `BinaryLiterals`, `HexFloatLiterals`,
  `NegativeLiterals`, `LexicalNegation` and `NumDecimals` give an existing
  sequence of characters a new numeric meaning.
- **New overloading**: `OverloadedStrings`, `OverloadedLists` and
  `MonadComprehensions` make types more polymorphic, so programs that relied
  on the old types become ambiguous.
- **Less generalisation**: `MonoLocalBinds`, and everything that implies
  it, rejects programs that need local bindings to be polymorphic.
  `ScopedTypeVariables` changes what a type variable in a signature refers
  to.
- **Changed defaulting**: `NoMonomorphismRestriction` and
  `ExtendedDefaultRules` change which type an ambiguous variable gets.
- **Changed desugaring**: `ApplicativeDo`, `PostfixOperators` and
  `RebindableSyntax` translate existing constructs differently.
- **Changed evaluation**: `Strict` and `StrictData`.

A non-conservative extension can interact with every program, so in any
drawing of the graph it deserves its own colour.

Two observations follow from the classification. First, the language sets
are not conservative. GHC2021 contains `ScopedTypeVariables`,
`NamedWildCards`, `PostfixOperators`, `BinaryLiterals` and
`HexFloatLiterals`, and GHC2024 adds `MonoLocalBinds`. Moving a code base to
a newer set is a language change, not just a relaxation.

Second, GHC has made some extensions conservative by changing its baseline.
In Haskell 2010 mode GHC already rejects `a !b = …`, `1_000` and `M.do`,
which the report accepts, so `BangPatterns`, `NumericUnderscores` and
`QualifiedDo` add nothing that conflicts with GHC's baseline (see
[deviations](reference.md#where-ghcs-haskell-2010-mode-departs-from-the-report)).
The revised report made the same move for `forall`, which it now reserves.
Each such case is a choice for the report: follow GHC and reserve the
syntax, or keep the 2010 reading.

## Computing interactions from a formal specification

With a formal specification such as the Ott formalisation of this report,
candidate interactions can be computed rather than collected by hand. Write
each extension as a delta: the grammar productions and rules it adds or
changes, and the judgments it touches. Two extensions can only interact if
their deltas touch the same nonterminal or judgment. The overlap of deltas
gives a safe over-approximation of the interaction graph.

Each candidate edge then needs a judgment by a person:

1. **Orthogonal**: the deltas compose without changes.
2. **Compositional**: the combination needs a combined rule, but the rule
   follows mechanically from the two deltas.
3. **Genuine**: the combination needs new theory, as functional
   dependencies with GADTs did.

This is the feature-interaction problem from software product lines,
applied to a language definition. Modular semantics, such as Modular SOS
(Mosses 2004), and modular proofs, such as Meta-Theory à la Carte (Delaware
et al. 2013), address the same problem from the other side.

## What this means for a report

The graph sorts the work of standardising extensions:

- A conservative extension with no edges can be standardised on its own.
- A cluster joined by genuine edges has to be standardised as a whole, or
  not at all.
- Each genuine edge is a proof obligation: an argument that the combined
  rules are sound, of the kind Karachalias and Schrijvers give for
  functional dependencies.
- A non-conservative extension cannot be added silently. It needs an
  explicit opt-in, or a new language version.

## References

- Joachim Breitner, Richard A. Eisenberg, Simon Peyton Jones and Stephanie
  Weirich. Safe zero-cost coercions for Haskell. ICFP 2014.
- Benjamin Delaware, Bruno C. d. S. Oliveira and Tom Schrijvers. Meta-theory
  à la carte. POPL 2013.
- Georgios Karachalias and Tom Schrijvers. Elaboration on functional
  dependencies: functional dependencies are dead, long live functional
  dependencies! Haskell Symposium 2017.
- Peter D. Mosses. Modular structural operational semantics. Journal of
  Logic and Algebraic Programming 60–61, 2004.
- Dimitrios Vytiniotis, Simon Peyton Jones and Tom Schrijvers. Let should
  not be generalised. TLDI 2010.
- Dimitrios Vytiniotis, Simon Peyton Jones, Tom Schrijvers and Martin
  Sulzmann. OutsideIn(X): modular type inference with local assumptions.
  Journal of Functional Programming 21(4–5), 2011.
- Stephanie Weirich, Dimitrios Vytiniotis, Simon Peyton Jones and Steve
  Zdancewic. Generative type abstraction and type-level computation. POPL
  2011.
