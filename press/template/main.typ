#import "@local/press:0.1.0": document
#import "section-one.typ" as section-one
#import "section-two.typ" as section-two
#import "plate.typ" as plate

// Your formatter `l`. Swap this stub for a real one (e.g. cascade) exposing the same surface:
// l.page(body), l.markup(body), and the components your renderers call (l.heading-1, l.figure, …).
#let l = (
  page: body => { set page(paper: "us-letter", numbering: "1"); body },
  markup: body => body,
  heading-1: body => heading(level: 1, body),
  figure: (img, caption) => figure(img, caption: caption),
)

// The spine: order your sections. Add or remove matched pairs freely — any structure.
#let body = {
  section-one.render(l)
  pagebreak()
  section-two.render(l)
  plate.render(l)
}

#document(l, body)
