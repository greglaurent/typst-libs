#import "@local/press:0.1.0": document
#import "title.typ" as title
#import "essay.typ" as essay
#import "points.typ" as points
#import "plate.typ" as plate

// The formatter `l`. press depends on NONE of this — swap it for cascade later and
// every section re-renders unchanged. It exposes l.page / l.markup and the components
// the renderers call (heading-1, heading-2, lead, body, rule).
#let l = (
  page: body => {
    set page(paper: "a5", margin: (x: 1.9cm, y: 2.1cm), numbering: none)
    set text(size: 10.5pt)
    set par(justify: true, leading: 0.72em, spacing: 1.1em)
    body
  },
  markup: body => body,
  heading-1: it => block(below: 0.5em, text(size: 20pt, weight: "bold", it)),
  heading-2: it => block(above: 1.4em, below: 0.5em, text(size: 13pt, weight: "bold", it)),
  lead: it => block(below: 1.2em, text(size: 12pt, style: "italic", fill: luma(90), it)),
  body: it => it,
  rule: () => block(above: 0.2em, below: 0.7em, line(length: 100%, stroke: 0.4pt + luma(160))),
  figure: (img, caption) => block(above: 1.3em, below: 1.3em, align(center, {
    img
    v(0.5em)
    text(size: 8.5pt, style: "italic", fill: luma(110), caption)
  })),
)

// header/footer are section renderers (l, page) => content, shown on every page by
// `document`. `page` is the page element, so counter(page) queries the number.
#let running-header(l, page) = {
  if counter(page).get().first() > 1 {
    set text(size: 8pt, style: "italic", fill: luma(120))
    align(right, [On the Composition of Documents])
  }
}
#let page-footer(l, page) = {
  set text(size: 8pt, fill: luma(120))
  align(center, [#counter(page).get().first() / #counter(page).final().first()])
}

// The spine: order the sections. Add or remove matched pairs freely — any structure.
#let body = {
  title.render(l)
  pagebreak()
  essay.render(l)
  plate.render(l)
  points.render(l)
}

#document(l, body, header: running-header, footer: page-footer)
