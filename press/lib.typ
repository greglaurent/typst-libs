// press — a generic document template & framework for Typst.
//
// A document is a set of SECTIONS. Each section is a matched pair, bound by a shared name:
//
//   content/<x>.typ   the content (data)       #let content = …            (a dict or a block)
//   <x>.typ           the renderer             #import "content/<x>.typ": content
//                                              #let render(l) = …  (arrange it through `l`)
//
// The renderer finds its own content by the matching name; `main.typ` orders the sections and
// frames them. press knows nothing about what the sections ARE — any pairs, any order, any
// structure. Formatting is supplied through `l` — a formatter such as cascade — which press
// never names or depends on; the two meet only at that parameter.

// document — frame an ordered `body` of rendered sections into the finished document, using
// formatter `l`. `header`/`footer` are section renderers `(l, page) => content`, shown on every
// page. The page itself — paper, margins, numbering, fill — comes entirely from `l`; press sets
// nothing static.
#let document(l, body, header: none, footer: none) = {
  (l.page)({
    if header != none { set page(header: context { header(l, page) }) }
    if footer != none { set page(footer: context { footer(l, page) }) }
    (l.markup)(body)
  })
}
