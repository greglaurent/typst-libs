#let make(config) = {
  let settings = (base: 10.5pt, paper: "a5") + config
  (
    page: body => {
      set page(paper: settings.paper, margin: (x: 1.9cm, y: 2.1cm), numbering: none)
      set text(size: settings.base)
      set par(justify: true, leading: 0.72em, spacing: 1.1em)
      body
    },
    markup: body => body,
    heading-1: it => block(below: 0.5em, text(size: 20pt, weight: "bold", it)),
    heading-2: it => block(above: 1.4em, below: 0.5em, text(size: 13pt, weight: "bold", it)),
    lead: it => block(below: 1.2em, text(size: 12pt, style: "italic", fill: luma(90), it)),
    body: it => it,
    caption: it => text(size: 8.5pt, style: "italic", fill: luma(120), it),
    rule: () => block(above: 0.2em, below: 0.7em, line(length: 100%, stroke: 0.4pt + luma(160))),
    figure: (img, caption) => block(above: 1.3em, below: 1.3em, align(center, {
      img
      v(0.5em)
      text(size: 8.5pt, style: "italic", fill: luma(110), caption)
    })),
  )
}
