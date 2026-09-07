// The cascade example — the SAME sections as ../base, rendered through cascade instead of a
// hand-rolled formatter. Only `l` differs: press composes, cascade styles. That's press's whole
// thesis, demonstrated by swapping one value.
//
// The sections live in ../base (they resolve their own content/ and assets/), so compile from the
// examples/ dir with the shared root:
//   typst compile --root . cascade/main.typ cascade/out.pdf
#import "@local/press:0.1.0": document
#import "@local/cascade:2.0.0": cascade
#import "../base/title.typ" as title
#import "../base/essay.typ" as essay
#import "../base/points.typ" as points
#import "../base/plate.typ" as plate

// The cascade formatter `l`: map press's component names onto native Typst elements, and let
// cascade's show-rule (as l.page) supply ALL the typography. Compare with the hand-rolled `l` in
// ../base/main.typ — same section renderers, a different `l`, a different look.
#let l = (
  page: cascade,                                   // the show-rule is body → styled; press calls (l.page)(body)
  markup: body => body,
  heading-1: it => heading(level: 1, it),          // cascade's `show heading` styles it
  heading-2: it => heading(level: 2, it),
  lead: it => emph(it),                            // press's "lead" → emphasis; cascade styles emph
  body: it => it,                                  // cascade styles par
  rule: () => line(length: 100%, stroke: 0.4pt + luma(160)),
  figure: (img, caption) => figure(img, caption: caption),   // cascade styles the caption
)

// header/footer: the same (l, page) renderers as ../base — cascade styles the text.
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

// The same spine as ../base/main.typ — identical sections, only `l` changed.
#let body = {
  title.render(l)
  pagebreak()
  essay.render(l)
  plate.render(l)
  points.render(l)
}

#document(l, body, header: running-header, footer: page-footer)
