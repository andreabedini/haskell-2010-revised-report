# Haskell 2010 revised report in Ott

An experiment in formalising parts of the
[Haskell 2010 revised report](https://github.com/haskellfoundation/haskell-2010-revised-report)
with [Ott](https://github.com/ott-lang/ott), and typesetting the result in the
report's own format, Typst.

## Contents

- `ott/expressions.ott`: Chapter 3. Abstract syntax of expressions, patterns,
  qualifiers, case alternatives with guards, statements and bindings, with the
  precedence of the concrete grammar given as Ott `parsing` priorities. The
  translation identities are axioms of a judgement `e1 === e2`, with side
  conditions such as `x notin fv(e)` or `v fresh` as premises. They cover the
  "Translation" boxes of §3.2–3.16 (literals, lambda, operators, sections,
  conditionals, lists, parentheses, arithmetic sequences, list comprehensions,
  `let`, `do`, field labels, type signatures) and the formal
  semantics of `case` in Figures 3.1–3.3 (rules (a)–(v), as `case_a` …
  `case_v`). Every rule has exactly one parse
  (`ott -picky_multiple_parses true`).
- `doc/expressions.src.typ`: excerpts of Chapter 3 that use the generated
  definitions. `[[ ... ]]` quotations are parsed by Ott as Haskell and replaced
  with Typst math.

## Building

You need an Ott with the Typst backend, quoted terminals (`'in'`, which would
otherwise be the integer literal `i` with suffix `n`) and nested dot forms (used by field
selection and update, §3.15, for `p_1_1 .. p_1_k1 ; .. ; p_n_1 .. p_n_kn`),
currently on the `typst` work in
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

## Differences from the report

- Ott dot forms cannot express nested ellipses such as
  `case v of { p1 match1 ; _ -> ... case v of { pn matchn ; _ -> e } ... }`.
  Rules (b), (c), (g) and (s) are therefore restated as one-step identities
  that unfold to the report's nested form:
  - (b) is `case_b`, which peels off one alternative, and `case_b_last`, which
    adds the final `_ -> error "No match"`. `case_b_true` is the remark that
    `True` is substituted for missing guards.
  - (c) is `case_c`, and `case_c_next` unfolds the guarded right-hand sides one
    at a time.
  - (g) matches the sub-patterns with pattern guards
    `() | p1 <- x1, ..., pn <- xn`, which (s) and (t) turn into the report's
    nested cases, left to right.
  - (s) peels off one guard.
- The report's `pick` is a formula, `e1 ... ek = pick (K, bs, d)`. The update
  needs a different default for each component, written `picks` in the source
  and typeset as `pick`; Ott cannot otherwise tell a single default from a list
  of one.
- For field selection, the report says that `C1 ... Cn` are "all the
  constructors of the datatype containing a field labeled with `f`", and that
  `ei` is `undefined` when `Ci` has no field `f`. This is read as all the
  constructors of that datatype (`datacons (f)`); otherwise the `undefined`
  case could not arise.
- Side conditions are formulas rather than prose: `fresh` for "a new variable",
  `{x1, ..., xn} = vars(p)`, `fieldpats(K, f, p)` for the patterns of rule (n),
  and `wildcards(K)` for those of rule (o). The arities in rules (p)–(r) are the
  lengths of the dot forms.
- Declarations always have braces, so the report's `let p = e1 in e0` is written
  `let { p = e1 } in e0`.
- Prelude names such as `negate`, `True` and `concatMap` are lexemes of the
  variable and constructor metavariables, not distinguished constants. `ok` is
  one too, with an explicit `ok fresh` premise.
- `e @@ e1 ... en` is an iterated application, typeset as juxtaposition. The
  invisible `@@` keeps it from overlapping with `e1 e2`.

## Not covered yet

- The full declaration syntax and its translation to pattern bindings
  (§4.4.3). `decl` has only function and pattern bindings, and the type
  signatures that §3.16 needs.
- Types and contexts, which appear only as the placeholder `T`.
- Layout and fixity resolution (Chapter 10). The grammar here is abstract.
