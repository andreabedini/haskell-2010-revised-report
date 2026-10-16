# Haskell 2010 revised report in Ott

An experiment in formalising parts of the
[Haskell 2010 revised report](https://github.com/haskellfoundation/haskell-2010-revised-report)
with [Ott](https://github.com/ott-lang/ott), and typesetting the result in the
report's own format, Typst.

## Contents

- `ott/expressions.ott`: Chapter 3. Abstract syntax of expressions, patterns,
  qualifiers, statements and bindings, with the precedence of the concrete
  grammar given as Ott `parsing` priorities. The translation identities from the
  chapter's "Translation" boxes (§3.4–3.11) are axioms of a judgement
  `e1 == e2`, with side conditions such as `x notin fv(e)` as premises.
- `doc/expressions.src.typ`: excerpts of Chapter 3 that use the generated
  definitions. `[[ ... ]]` quotations are parsed by Ott as Haskell and replaced
  with Typst math.

## Building

You need an Ott with the Typst backend, currently on the `typst` work in
[andreabedini/ott](https://github.com/andreabedini/ott), and
[Typst](https://typst.app).

```sh
make OTT=/path/to/ott/bin/ott
```

This writes the following files to `build/`:

- `expressions.typ`: a Typst module with one definition per grammar rule and
  translation identity, for example `ottdruleif` or `ottgrammar`
- `expressions.pdf`: the whole formalisation
- `expressions.doc.pdf`: the Chapter 3 excerpts

## Not covered yet

- Guards, `where` clauses and the full declaration syntax. `decl` has only
  function and pattern bindings.
- The translations of `let`, `case`, `do` and labelled fields, and of literals.
- Types and contexts, which appear only as the placeholder `T`.
- Layout and fixity resolution (Chapter 10). The grammar here is abstract.
