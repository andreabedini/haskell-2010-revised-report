/// Typesetting terminal symbols in the grammar
#let terminal(x) = {
  text(fill: eastern, $mono(#x)$)
}

/// Typesetting nonterminal symbols in the gramma
#let nonterminal(x) = {
  link(label(x))[#text(fill: maroon, $italic(#x)$)]
}

#let nonterminaldef(x) = {
  [$italic(#x)$#raw("")#label(x)]
}

/// A box used in defining the meaning of syntactic entities by translation.
#let translation-box(x) = context{
  if target() == "paged" {
    // Code for PDF output
    box(
      stroke: black,
      width: 1fr,
      inset: 10pt,
      [*Translation:* #x]
    )
  } else {
    // Code for HTML output
    html.elem("div", attrs: (class: "translation-box"))[
      *Translation:* #x
    ]
  }
}

/// Whether open-issue annotations are shown.  Pass `--input issues=hide` to
/// typst to leave them out of the output.
#let show-issues = sys.inputs.at("issues", default: "show") != "hide"

/// A box recording an open issue in the specification: a place where the
/// report is vague, inconsistent, or disagrees with implementations.
#let issue-box(title, x) = context {
  if not show-issues {
    none
  } else if target() == "paged" {
    // Code for PDF output
    block(
      stroke: (paint: orange.darken(30%), thickness: 1pt, dash: "dashed"),
      width: 100%,
      inset: 10pt,
      [*Open issue: #title*\ #x]
    )
  } else {
    // Code for HTML output
    html.elem("div", attrs: (class: "issue-box"))[
      *Open issue: #title*\ #x
    ]
  }
}

#let monomorphism-box(x) = context {
  if target() == "paged" {
    // Code for PDF output
    box(
      stroke: black,
      width: 1fr,
      inset: 10pt,
      [*The monomorphism restriction*\ #x]
    )
  } else {
    // Code for HTML output
    html.elem("div", attrs: (class: "monomorphism-box"))[
      *The monomorphism restriction*\ #x
    ]
  }
}

#let center-box(body) = context {
  if target() == "paged" {
     // Code for PDF output
     align(center)[#body]
  } else {
    // Code for HTML output
     html.elem("div", attrs: (style: "text-align: center;", class: "center-box"))[#body]
  }
}

// See https://github.com/typst/typst/issues/8509
#let safeoverline(body) = context {
  if target() == "paged" {
    // Code for PDF output
    math.overline(body)
  } else {
    // Code for HTML output
    html.elem("mover", attrs: (accent: "true"))[
      #body
      #html.elem("mo", "_")
    ]
  }
}