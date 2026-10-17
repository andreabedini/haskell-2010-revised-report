# GHC extensions

Notes on GHC's language extensions, as input to future revisions of the
report.

- [About interactions between GHC extensions](interactions.md) discusses how
  extensions relate to each other and what that means for standardisation.
- [GHC extensions relative to Haskell 2010](reference.md) classifies every
  extension supported by GHC 9.12.2 as conservative or not, and lists
  implications and language sets.
- [`witnesses/`](witnesses) holds the programs behind the classification,
  and [`check-witnesses.sh`](check-witnesses.sh) checks them against GHC.
