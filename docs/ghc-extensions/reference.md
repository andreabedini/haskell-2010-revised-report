# GHC extensions relative to Haskell 2010

This page lists every language extension supported by GHC 9.12.2. For each
one it says whether the extension is conservative over Haskell 2010, and
gives the evidence. It also lists the implications between extensions and
the language sets GHC defines. For a discussion of what these relations
mean, see [About interactions between GHC extensions](interactions.md).

## Conservativity

The baseline is GHC 9.12.2 with `-XHaskell2010`. Each extension is placed in
one class.

| Class | Meaning |
|---|---|
| **C** | Conservative. Every module that the baseline accepts is accepted with the extension and behaves the same. No witness is known. The evidence column gives the argument. |
| **R** | Rejects. A witness module that the baseline accepts is rejected with the extension. |
| **M** | Changes meaning. A witness module that the baseline accepts is also accepted with the extension, but behaves differently. |

Each extension is listed under the strongest class that has a witness. An
**R** extension may also have an undiscovered **M** witness.

Turning an extension on also turns on the extensions it implies (see
[Implications](#implications)). The class accounts for these, so `GADTs` is
**R** because it implies `MonoLocalBinds`.

The witnesses are in [`witnesses/`](witnesses). To check them against a
compiler, run:

```sh
./check-witnesses.sh            # uses ghc
GHC=ghc-9.14 ./check-witnesses.sh
```

All witnesses pass with GHC 9.12.2 and 9.14.1. With GHC 9.10.3 every
witness passes except `ExtendedDefaultRules`, which is **M** there (see
below). GHC 9.10 lacks some of the extensions, so its run is not a full
check.

The column "GHC20xx" shows whether an extension is in GHC2021 (`2021`) or
added by GHC2024 (`2024`). GHC2024 includes all of GHC2021.

### Extensions that GHC's Haskell 2010 mode leaves off

| Extension | Class | GHC20xx | Evidence |
|---|---|---|---|
| `AllowAmbiguousTypes` | C | | Relaxes the ambiguity check on signatures. |
| `AlternativeLayoutRule` | R | | [witness](witnesses/AlternativeLayoutRule.hs): no `parse-error(t)` rule. |
| `AlternativeLayoutRuleTransitional` | C | | Warns where the alternative rule would differ; accepts the witness above. |
| `ApplicativeDo` | M | | [witness](witnesses/ApplicativeDo.hs): `do` desugars to `<*>`. |
| `Arrows` | R | | [witness](witnesses/Arrows.hs): `proc` becomes reserved. |
| `AutoDeriveTypeable` | C | | Deprecated; has no effect since GHC 8.2. |
| `BangPatterns` | C | 2021 | GHC's baseline already rejects `a !b`; see [deviations](#where-ghcs-haskell-2010-mode-departs-from-the-report). |
| `BinaryLiterals` | M | 2021 | [witness](witnesses/BinaryLiterals.hs): `0b101` was `0 b101`. |
| `BlockArguments` | C | | New syntax that was a parse error. |
| `CApiFFI` | C | | New calling convention in foreign declarations. |
| `ConstrainedClassMethods` | C | 2021 | Relaxes a check on method contexts. |
| `ConstraintKinds` | C | 2021 | Relaxes checks on constraints. |
| `CPP` | R | | [witness](witnesses/CPP.hs): `cpp` joins lines ending in `\`. |
| `DataKinds` | C | 2024 | Adds promoted constructors to the type namespace. No witness found. |
| `DefaultSignatures` | C | | New syntax in class bodies. |
| `DeriveAnyClass` | C | | Accepts more `deriving` clauses; stock deriving keeps priority. No witness found. |
| `DeriveDataTypeable` | C | 2021 | Adds a derivable class. |
| `DeriveFoldable` | C | 2021 | Adds a derivable class. |
| `DeriveFunctor` | C | 2021 | Adds a derivable class. |
| `DeriveGeneric` | C | 2021 | Adds a derivable class. |
| `DeriveLift` | C | 2021 | Adds a derivable class. |
| `DeriveTraversable` | C | 2021 | Adds a derivable class. |
| `DerivingStrategies` | C | 2024 | New syntax in `deriving` clauses. |
| `DerivingVia` | C | | New syntax in `deriving` clauses. |
| `DisambiguateRecordFields` | C | 2024 | Resolves field names that would otherwise be ambiguous. |
| `DuplicateRecordFields` | C | | Accepts duplicate field names. No witness found for modules without duplicates. |
| `EmptyCase` | C | 2021 | New syntax that was a parse error. |
| `EmptyDataDeriving` | C | 2021 | Accepts `deriving` clauses on empty types. |
| `ExistentialQuantification` | C | 2021 | New syntax; `forall` is already reserved. |
| `ExplicitForAll` | C | 2021 | New syntax; `forall` is already reserved. |
| `ExplicitNamespaces` | C | 2024 | New syntax in import and export lists. |
| `ExtendedDefaultRules` | R | | [witness](witnesses/ExtendedDefaultRules.hs): with a `Num ()` instance GHC 9.12 and 9.14 reject the program as ambiguous; GHC 9.10 accepts it and prints `()` in place of `2`. |
| `ExtendedLiterals` | R | | [witness](witnesses/ExtendedLiterals.hs): `1#Int8` was `1 # Int8`. |
| `FlexibleContexts` | C | 2021 | Relaxes the head normal form check on contexts. |
| `FlexibleInstances` | C | 2021 | Relaxes the check on instance heads. |
| `FunctionalDependencies` | C | | New syntax in class heads. |
| `GADTs` | R | 2024 | Implies `MonoLocalBinds`; [witness](witnesses/MonoLocalBinds.hs). |
| `GADTSyntax` | C | 2021 | New syntax that was a parse error. |
| `GeneralizedNewtypeDeriving` | C | 2021 | Accepts more `deriving` clauses on newtypes. Where Haskell 2010 can already derive the class, the instances agree. No witness found. |
| `GHCForeignImportPrim` | C | | New calling convention in foreign imports. |
| `HexFloatLiterals` | M | 2021 | [witness](witnesses/HexFloatLiterals.hs): `0x1p4` was `0x1 p4`. |
| `ImplicitParams` | R | | [witness](witnesses/ImplicitParams.hs): `?x` was an operator section. |
| `ImportQualifiedPost` | C | 2021 | New syntax that was a parse error. |
| `ImpredicativeTypes` | C | | Relaxes instantiation. No witness found. |
| `IncoherentInstances` | C | | Affects only overlapping instances, which Haskell 2010 instance heads cannot form. |
| `InstanceSigs` | C | 2021 | New syntax in instance bodies. |
| `InterruptibleFFI` | C | | New safety keyword in foreign imports. |
| `KindSignatures` | C | 2021 | New syntax that was a parse error. |
| `LambdaCase` | C | 2024 | New syntax that was a parse error. |
| `LexicalNegation` | M | | [witness](witnesses/LexicalNegation.hs): `(- 1)` becomes a section. |
| `LiberalTypeSynonyms` | C | | Relaxes checks on type synonyms. |
| `LinearTypes` | R | | Implies `MonoLocalBinds`; [witness](witnesses/MonoLocalBinds.hs). |
| `MagicHash` | R | | [witness](witnesses/MagicHash.hs): `x#y` was `x # y`. |
| `MonadComprehensions` | R | | [witness](witnesses/MonadComprehensions.hs): the comprehension's monad becomes ambiguous. |
| `MonoLocalBinds` | R | 2024 | [witness](witnesses/MonoLocalBinds.hs): local bindings that mention enclosing variables are not generalised. |
| `MultilineStrings` | R | | [witness](witnesses/MultilineStrings.hs): `"""x"` was `"" "x"`. |
| `MultiParamTypeClasses` | C | 2021 | Relaxes the check on class heads. |
| `MultiWayIf` | C | | New syntax that was a parse error. |
| `NamedDefaults` | C | | New form of `default` declaration. No witness found. |
| `NamedFieldPuns` | C | 2021 | New syntax that was a parse error. |
| `NamedWildCards` | R | 2021 | [witness](witnesses/NamedWildCards.hs): `_a` in a type becomes a wildcard. |
| `NegativeLiterals` | M | | [witness](witnesses/NegativeLiterals.hs): `-1` becomes `fromInteger (-1)`. |
| `NondecreasingIndentation` | C | | Affects only a `do` block indented no further than its enclosing block, which the baseline reads as an empty `do`, always an error. |
| `NPlusKPatterns` | C | | The baseline rejects every `n+k` pattern. No witness found. |
| `NumDecimals` | M | | [witness](witnesses/NumDecimals.hs): `1e3` defaults to `Integer`. |
| `NumericUnderscores` | C | 2021 | GHC's baseline already rejects `1_000`; see [deviations](#where-ghcs-haskell-2010-mode-departs-from-the-report). |
| `OrPatterns` | C | | New syntax that was a parse error. |
| `OverlappingInstances` | C | | Deprecated. Affects only overlapping instances. |
| `OverloadedLabels` | R | | [witness](witnesses/OverloadedLabels.hs): `#x` was an operator section. |
| `OverloadedLists` | R | | [witness](witnesses/OverloadedLists.hs): list literals become ambiguous. |
| `OverloadedRecordDot` | R | | [witness](witnesses/OverloadedRecordDot.hs): `f.g` was composition. |
| `OverloadedRecordUpdate` | R | | [witness](witnesses/OverloadedRecordUpdate.hs): record update needs `RebindableSyntax`. |
| `OverloadedStrings` | R | | [witness](witnesses/OverloadedStrings.hs): string literals become ambiguous. |
| `PackageImports` | C | | New syntax that was a parse error. |
| `ParallelArrays` | C | | Implies `ParallelListComp`; the parallel-array syntax has been removed. |
| `ParallelListComp` | C | | New syntax that was a parse error. |
| `PartialTypeSignatures` | C | | Accepts wildcards in signatures, which the baseline rejects. |
| `PatternSynonyms` | R | | [witness](witnesses/PatternSynonyms.hs): `pattern` becomes reserved. |
| `PolyKinds` | C | 2021 | Generalises inferred kinds. No witness found. |
| `PostfixOperators` | M | 2021 | [witness](witnesses/PostfixOperators.hs): `(e op)` becomes `op e`, not `\y -> e op y`. |
| `QualifiedDo` | C | | GHC's baseline already rejects `M.do`; see [deviations](#where-ghcs-haskell-2010-mode-departs-from-the-report). |
| `QuantifiedConstraints` | C | | New syntax in contexts. |
| `QuasiQuotes` | R | | [witness](witnesses/QuasiQuotes.hs): `[x|` opens a quasi-quote. |
| `RankNTypes` | C | 2021 | New syntax; `forall` is already reserved. |
| `RebindableSyntax` | M | | [witness](witnesses/RebindableSyntax.hs): `do` uses the `>>` in scope. Also implies `NoImplicitPrelude`. |
| `RecordWildCards` | C | | New syntax that was a parse error. |
| `RecursiveDo` | R | | [witness](witnesses/RecursiveDo.hs): `mdo` becomes reserved. |
| `RelaxedLayout` | C | | Accepts an explicit `{` that is less indented than the enclosing layout block. |
| `RequiredTypeArguments` | C | | New syntax. No witness found. |
| `RoleAnnotations` | C | 2024 | New syntax that was a parse error. |
| `ScopedTypeVariables` | R | 2021 | [witness](witnesses/ScopedTypeVariables.hs): the class variable scopes over default methods. |
| `StandaloneDeriving` | C | 2021 | New syntax that was a parse error. |
| `StandaloneKindSignatures` | C | 2021 | New syntax; implies `NoCUSKs`, which is C. |
| `StaticPointers` | R | | [witness](witnesses/StaticPointers.hs): `static` becomes reserved. |
| `Strict` | M | | [witness](witnesses/Strict.hs): `let` bindings become strict. |
| `StrictData` | M | | [witness](witnesses/StrictData.hs): constructor fields become strict. |
| `TemplateHaskell` | R | | [witness](witnesses/TemplateHaskellQuotes.hs): `[e|` opens a quotation. |
| `TemplateHaskellQuotes` | R | | [witness](witnesses/TemplateHaskellQuotes.hs): `[e|` opens a quotation. |
| `TransformListComp` | R | | [witness](witnesses/TransformListComp.hs): `using`, `by` and `group` become special. |
| `TupleSections` | C | 2021 | New syntax that was a parse error. |
| `TypeAbstractions` | C | | New syntax. No witness found. |
| `TypeApplications` | C | 2021 | New syntax; `@` is reserved in expressions. |
| `TypeData` | C | | New syntax that was a parse error. |
| `TypeFamilies` | R | | Implies `MonoLocalBinds`; [witness](witnesses/MonoLocalBinds.hs). |
| `TypeFamilyDependencies` | R | | Implies `TypeFamilies`; [witness](witnesses/MonoLocalBinds.hs). |
| `TypeInType` | C | | Deprecated: `DataKinds`, `PolyKinds` and `KindSignatures`. |
| `TypeOperators` | C | 2021 | Relaxes the syntax of types. |
| `TypeSynonymInstances` | C | 2021 | Relaxes the check on instance heads. |
| `UnboxedSums` | R | | [witness](witnesses/UnboxedTuples.hs): `(#` opens an unboxed sum. |
| `UnboxedTuples` | R | | [witness](witnesses/UnboxedTuples.hs): `(#` opens an unboxed tuple. |
| `UndecidableInstances` | C | | Relaxes the termination checks on instances. |
| `UndecidableSuperClasses` | C | | Relaxes the check on superclasses. |
| `UnicodeSyntax` | R | | [witness](witnesses/UnicodeSyntax.hs): `→` was an ordinary operator. |
| `UnliftedDatatypes` | C | | New syntax in kinds. |
| `UnliftedFFITypes` | C | | Relaxes the check on foreign types. |
| `UnliftedNewtypes` | C | | Relaxes the check on newtypes. |
| `ViewPatterns` | C | | New syntax that was a parse error. |

Four of the **M** witnesses rely on unusual instances. `BinaryLiterals`,
`HexFloatLiterals` and `LexicalNegation` need a `Num` instance for functions
([`NumFunctions.hs`](witnesses/NumFunctions.hs)). `NegativeLiterals` needs a
`Num` instance whose `negate` disagrees with `fromInteger` on negative
numbers. Without such instances, the only witnesses known for these
extensions are programs they reject.

### Extensions that GHC's Haskell 2010 mode turns on

GHC's `-XHaskell2010` turns these on, so the flag that changes the baseline
is the `No` form.

| Flag | Class | Evidence |
|---|---|---|
| `NoCUSKs` | C | Affects only kind-polymorphic declarations, which the baseline does not infer. |
| `NoDatatypeContexts` | R | [witness](witnesses/NoDatatypeContexts.hs) |
| `NoDeepSubsumption` | C | Affects only higher-rank types. No witness found. A module that uses library functions with nested `forall`s may be affected. |
| `NoDoAndIfThenElse` | R | [witness](witnesses/NoDoAndIfThenElse.hs) |
| `NoEmptyDataDecls` | R | [witness](witnesses/NoEmptyDataDecls.hs) |
| `NoFieldSelectors` | R | [witness](witnesses/NoFieldSelectors.hs) |
| `NoForeignFunctionInterface` | R | [witness](witnesses/NoForeignFunctionInterface.hs) |
| `NoImplicitPrelude` | R | [witness](witnesses/NoImplicitPrelude.hs) |
| `NoListTuplePuns` | R | [witness](witnesses/NoListTuplePuns.hs) |
| `NoMonomorphismRestriction` | M | [witness](witnesses/NoMonomorphismRestriction.hs): defaulting differs. |
| `NoPatternGuards` | C | GHC 9.12 only warns about pattern guards. |
| `NoRelaxedPolyRec` | – | Cannot be turned off. |
| `NoStarIsType` | C | Kinds cannot be written in the baseline. |
| `NoTraditionalRecordSyntax` | R | [witness](witnesses/NoTraditionalRecordSyntax.hs) |

### Language sets and Safe Haskell

| Flag | Class | Evidence |
|---|---|---|
| `Haskell98` | R | Leaves out `EmptyDataDecls`; [witness](witnesses/NoEmptyDataDecls.hs). |
| `GHC2021` | R | Leaves out `DatatypeContexts`; [witness](witnesses/NoDatatypeContexts.hs). Also includes R and M extensions. |
| `GHC2024` | R | As `GHC2021`, and adds `MonoLocalBinds`. |
| `Safe` | R | [witness](witnesses/Safe.hs): rejects imports of unsafe modules. |
| `Trustworthy` | C | Only marks the module as trusted. |
| `Unsafe` | C | Only marks the module as unsafe. |

### Deprecated names

| Name | Stands for |
|---|---|
| `DoRec` | `RecursiveDo` |
| `GeneralisedNewtypeDeriving` | `GeneralizedNewtypeDeriving` |
| `NullaryTypeClasses` | `MultiParamTypeClasses` |
| `PatternSignatures` | `ScopedTypeVariables` |
| `PolymorphicComponents` | `RankNTypes` |
| `Rank2Types` | `RankNTypes` |
| `RecordPuns` | `NamedFieldPuns` |

## Where GHC's Haskell 2010 mode departs from the report

These witnesses are valid by the report, but GHC 9.12.2 rejects them under
`-XHaskell2010`. In most cases GHC reserves syntax for an extension even when
the extension is off, which makes that extension conservative over GHC's
baseline but not over the report. Four witnesses are different:
`StrictnessFlagSpace.hs`, `LazyPatternSpace.hs`, `AsPatternSpace.hs` and
`BangSection.hs`. GHC reads `!`, `~` and `@` according to the white space
around them (GHC proposal #229, since GHC 9.0), and no extension turns this
off. Each lists the extension closest to the syntax involved, to show that it
does not help.

| Witness | By the report | GHC 9.12.2 |
|---|---|---|
| [`BangPatterns.hs`](witnesses/BangPatterns.hs) | `a !b = …` defines the operator `!`. | Reads `!b` as a bang pattern and rejects it, with or without `BangPatterns`. |
| [`StrictnessFlagSpace.hs`](witnesses/StrictnessFlagSpace.hs) | `data T = MkT ! Int` and `{ f :: ! Int }` declare strict fields. | Reads `!` followed by a space as an infix operator and rejects both, with or without `BangPatterns` or `StrictData`. Writing `!Int` works. |
| [`LazyPatternSpace.hs`](witnesses/LazyPatternSpace.hs) | `f ~ (a, _) = 1` defines `f` with an irrefutable pattern. | Reads `~` surrounded by spaces as an infix operator, so the equation defines `(~)` and the signature for `f` has no binding. The same with `TypeOperators`. |
| [`AsPatternSpace.hs`](witnesses/AsPatternSpace.hs) | `g x @ (Just y) = y` defines `g` with an as-pattern. | Reads `@` surrounded by spaces as an infix operator and rejects the equation, with or without `TypeApplications`. |
| [`BangSection.hs`](witnesses/BangSection.hs) | `(!1)` is a right section of a user-defined `!`. | Reads `!1` as a bang pattern in an expression and rejects it, with or without `BangPatterns`. Writing `(! 1)` works. |
| [`NumericUnderscores.hs`](witnesses/NumericUnderscores.hs) | `1_000` is `1` applied to the variable `_000`. | Rejects it; with `NumericUnderscores` it is `1000`. |
| [`QualifiedDo.hs`](witnesses/QualifiedDo.hs) | `M.do` is the constructor `M` composed with a `do` block. | Rejects it; with `QualifiedDo` it is a qualified `do`. |
| [`LineDirective.hs`](witnesses/LineDirective.hs) | A line starting with `#` is ordinary code. | Reads it as a line directive, with or without `CPP`. |

GHC also rejects `forall` as a type variable. This matches the revised
report, which reserves `forall`.

## Implications

Turning on the extension in the first column turns the second one on, or
off where marked. Source: `impliedXFlags` in `compiler/GHC/Driver/Flags.hs`,
GHC 9.12.2.

| Extension | Implies |
|---|---|
| `AutoDeriveTypeable` | `DeriveDataTypeable` |
| `DeriveTraversable` | `DeriveFunctor`, `DeriveFoldable` |
| `DerivingVia` | `DerivingStrategies` |
| `DuplicateRecordFields` | `DisambiguateRecordFields` |
| `ExistentialQuantification` | `ExplicitForAll` |
| `FlexibleInstances` | `TypeSynonymInstances` |
| `FunctionalDependencies` | `MultiParamTypeClasses` |
| `GADTs` | `GADTSyntax`, `MonoLocalBinds` |
| `ImpredicativeTypes` | `RankNTypes` |
| `JavaScriptFFI` | `InterruptibleFFI` (JavaScript backend only) |
| `LiberalTypeSynonyms` | `ExplicitForAll` |
| `LinearTypes` | `MonoLocalBinds` |
| `MultiParamTypeClasses` | `ConstrainedClassMethods` |
| `ParallelArrays` | `ParallelListComp` |
| `PolyKinds` | `KindSignatures` |
| `QuantifiedConstraints` | `ExplicitForAll` |
| `RankNTypes` | `ExplicitForAll` |
| `RebindableSyntax` | turns off `ImplicitPrelude` |
| `RecordWildCards` | `DisambiguateRecordFields` |
| `ScopedTypeVariables` | `ExplicitForAll` |
| `StandaloneKindSignatures` | turns off `CUSKs` |
| `Strict` | `StrictData` |
| `TemplateHaskell` | `TemplateHaskellQuotes` |
| `TypeFamilies` | `MonoLocalBinds`, `KindSignatures`, `ExplicitNamespaces` |
| `TypeFamilyDependencies` | `TypeFamilies` |
| `TypeInType` | `DataKinds`, `PolyKinds`, `KindSignatures` |
| `TypeOperators` | `ExplicitNamespaces` |
| `UnboxedTuples` | `UnboxedSums` |
| `UnliftedDatatypes` | `DataKinds`, `StandaloneKindSignatures` |

## Language sets

Source: `languageExtensions` in `compiler/GHC/Driver/DynFlags.hs`, GHC 9.12.2.

| Set | Extensions |
|---|---|
| `Haskell98` | `ImplicitPrelude`, `StarIsType`, `CUSKs`, `MonomorphismRestriction`, `NPlusKPatterns`, `DatatypeContexts`, `TraditionalRecordSyntax`, `FieldSelectors`, `NondecreasingIndentation`, `DeepSubsumption`, `ListTuplePuns` |
| `Haskell2010` | `ImplicitPrelude`, `StarIsType`, `CUSKs`, `MonomorphismRestriction`, `DatatypeContexts`, `TraditionalRecordSyntax`, `EmptyDataDecls`, `ForeignFunctionInterface`, `PatternGuards`, `DoAndIfThenElse`, `FieldSelectors`, `RelaxedPolyRec`, `DeepSubsumption`, `ListTuplePuns` |
| `GHC2021` | `Haskell2010` without `CUSKs`, `DatatypeContexts` and `DeepSubsumption`, plus `BangPatterns`, `BinaryLiterals`, `ConstrainedClassMethods`, `ConstraintKinds`, `DeriveDataTypeable`, `DeriveFoldable`, `DeriveFunctor`, `DeriveGeneric`, `DeriveLift`, `DeriveTraversable`, `EmptyCase`, `EmptyDataDeriving`, `ExistentialQuantification`, `ExplicitForAll`, `FlexibleContexts`, `FlexibleInstances`, `GADTSyntax`, `GeneralizedNewtypeDeriving`, `HexFloatLiterals`, `ImportQualifiedPost`, `InstanceSigs`, `KindSignatures`, `MultiParamTypeClasses`, `NamedFieldPuns`, `NamedWildCards`, `NumericUnderscores`, `PolyKinds`, `PostfixOperators`, `RankNTypes`, `ScopedTypeVariables`, `StandaloneDeriving`, `StandaloneKindSignatures`, `TupleSections`, `TypeApplications`, `TypeOperators`, `TypeSynonymInstances` |
| `GHC2024` | `GHC2021` plus `DataKinds`, `DerivingStrategies`, `DisambiguateRecordFields`, `ExplicitNamespaces`, `GADTs`, `MonoLocalBinds`, `LambdaCase`, `RoleAnnotations` |
