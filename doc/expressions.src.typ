// Excerpts of Chapter 3 of the Haskell 2010 revised report, with the
// translation identities generated from ott/expressions.ott.
//
// This is input to `ott -typst_filter`: every double-bracket quotation is parsed as
// Haskell syntax by Ott and replaced by Typst math.  Compile the
// filtered build/expressions.doc.typ, not this file.

#import "expressions.typ": *

#let translation-box(x) = box(stroke: black, width: 1fr, inset: 10pt, [*Translation:* #x])

== Conditionals

A _conditional expression_ has the form $[[if e1 then e2 else e3]]$ and
returns the value of $e_2$ if the value of $e_1$ is `True`, $e_3$ if
$e_1$ is `False`, and $bot$ otherwise.

#translation-box[
  The following identity holds:
  #ottdruleif()
  where `True` and `False` are the two nullary constructors from the type
  `Bool`, as defined in the Prelude.
]

== Sections

_Sections_ are written as $[[(op e)]]$ or $[[(e op)]]$, where $italic("op")$
is a binary operator and $e$ is an expression.

#translation-box[
  The following identities hold:
  #ottdrulerightXXsection()
  #ottdruleleftXXsection()
]

== List Comprehensions

A _list comprehension_ has the form $[[ [e | q1, q2] ]]$, where the
$q_i$ are qualifiers.

#translation-box[
  List comprehensions satisfy these identities, which may be used as a
  translation into the kernel:
  #ottdrulecompXXtrue()
  #ottdrulecompXXone()
  #ottdrulecompXXguard()
  #ottdrulecompXXgen()
  #ottdrulecompXXlet()
]

== Do Expressions

A _do expression_ such as $[[do { p <- e ; stmts }]]$ provides a more
conventional syntax for monadic programming.

#translation-box[
  Do expressions satisfy these identities, which may be used as a
  translation into the kernel, after eliminating empty _stmts_:
  #ottdruledoXXlast()
  #ottdruledoXXexp()
  #ottdruledoXXbind()
  #ottdruledoXXlet()
  The ellipsis `"..."` stands for a compiler-generated error message,
  passed to `fail`; the functions `>>`, `>>=` and `fail` are operations
  in the class `Monad`, as defined in the Prelude.
]

== Formal Semantics of Pattern Matching

#figure(caption: [Semantics of Case Expressions, Part 3], block(width: 100%)[
  #ottdrulecaseXXs()
  #ottdrulecaseXXt()
  #ottdrulecaseXXu()
  #ottdrulecaseXXv()
])
