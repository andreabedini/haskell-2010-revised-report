# Haskell 2010 revised report in Ott

An experiment in formalising parts of the
Haskell 2010 revised report with [Ott](https://github.com/ott-lang/ott), and
typesetting the result in the report's own format, Typst.

The report includes the generated rules from `ott/expressions.typ` and
`ott/layout.typ` at the top of this repository. Run
`make regenerate-ott OTT=/path/to/ott` there after changing the files here.

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
  `case_v`). The translations of function and pattern bindings (§4.4.3) are
  axioms of a judgement `ds1 equiv ds2` on sequences of declarations, typeset
  with `≡` so that it is not confused with the `=` of a binding. Every rule
  has exactly one parse (`ott -picky_multiple_parses true`).
- `ott/layout.ott`: Chapter 10, §10.3. The layout algorithm `L` as identities
  `L ts ms === ts'` with side conditions. The report's equations are tried in
  order; here each one states the conditions under which it applies, so
  exactly one applies to a stream and a stack of contexts, except at the end
  of the input in an explicit context (Note 6). Equations that the report
  writes once are split for the empty and the non-empty context stack.
  `parse-error(t)` (Note 5) is a premise, not defined further.
- `ott/style.ott`: the Typst style of the rules, shared by the other files and
  passed to Ott first. Besides the default rule display, `show-name: false`
  gives a centred equation and `cells: true` the cells of a table row, as used
  for the table of `L`.
- `doc/report.src.typ`: the parts of the report that are formalised, in the
  report's order (Chapter 3, §4.1.2, §4.2.1, §4.4.3 and §10.3), with every
  generated rule, and a closing section on what is not formalised.
  `[[ ... ]]` quotations are parsed by Ott as Haskell and replaced with
  Typst math.

The file also covers the syntax of types (§4.1.2), with the identities for
function, tuple, list and parenthesised types as axioms of a judgement
`t1 === t2`, and the translation of strictness flags in `data` declarations
(§4.2.1), with contexts (§4.1.3) and constructors.

## Building

You need an Ott with the Typst backend, shifted indices in dot forms
(`e_n-1`, used by §4.2.1), quoted terminals (`'in'`, which would
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
- `layout.typ`, `layout.pdf`: the same for the layout algorithm
- `report.pdf`: the document, from `doc/report.src.typ`

`haskott.json` lists the same two specifications for the language server
of haskott (`haskott lsp`), so
that an editor checks, navigates and renames each `.ott` file together with
the files it is built with, and renames in `doc/report.src.typ` too.

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
- A binding has a right-hand side `rhs` (`= e`, or guards `| gs = e`), while a
  case alternative has a `match` (`-> e`, or `| gs -> e`). The report calls
  both `match`; the translation of function bindings relates them with the
  premise `match = arrows (rhs)`.
- The translation of pattern bindings, and the shorthand
  `= e where decls ≡ | True = e where decls`, are stated for right-hand sides
  with a `where`, as in the report; one without is the same as one with
  `where { }`.
- The strictness flag translation (§4.2.1) states the left-nested application
  `(((K op1 x1) op2 x2) ...) opn xn` as a recurrence, `e_0 := K` and
  `e_i := (e_i-1 opi xi)`, since Ott dot forms cannot nest parentheses; the
  premise `op = apply (s)` chooses `$` or `$!`.
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

## Observations on the report

Writing the conditions of the layout algorithm explicitly shows two things
in §10.3:

- Note 1 says that `L` fails when a nested context is not indented further
  than the enclosing one (`n <= m` for `{n}`). The equation of Note 2,
  `L ({n} : ts) ms = { : } : L (<n> : ts) ms`, applies in exactly that case,
  so `L` inserts empty braces instead, and the error only shows up later as a
  parse error.
- The paragraph after the notes says "Note 1 implements the feature that
  layout processing can be stopped prematurely by a parse error". That is
  Note 5.

## Not covered yet

- The full declaration syntax. `decl` has only function and pattern bindings
  (§4.4.3) and type signatures; infix function bindings such as
  ``x `plus` y = e`` are not covered.
- The rest of the declaration syntax (classes, instances, `newtype`, `type`,
  record fields in `data`), and kinds.
- Layout and fixity resolution (Chapter 10). The grammar here is abstract.
