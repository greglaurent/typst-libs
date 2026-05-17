#import "layout.typ" as rl

// Landscape, narrow margins → maximize horizontal room for side-by-side scales.
#set page(paper: "us-letter", margin: 0.4in, flipped: true)
#set text(size: 12pt)

#let scales = (
  "classical",
  "tetratonic",
  "minor-third",
  "major-third",
  "tritonic",
  "golden-ditonic",
  "golden-ratio",
)

#let sample(name) = {
  let l = rl.make(scale: name, measure: 35)
  let h1-size = (l.scale.size)(4)

  layout(avail => {
    // Measure raw text (not the component) — inline text measurement is
    // unconstrained by column width, giving the true natural width.
    let nat = measure(text(size: h1-size, weight: 700, font: "Libertinus Serif")[Heading 1])
    let factor = calc.min(1.0, avail.width / nat.width)

    let samples = block(breakable: true)[
      #(l.heading-1)[Heading 1]
      #(l.heading-2)[Heading 2]
      #(l.heading-3)[Heading 3]
      #(l.heading-4)[Heading 4]
      #(l.text-5)[Text 5 (subhead)]
      #(l.text-4)[Text 4 (subhead)]
      #(l.text-3)[Body — quick brown fox.]
      #(l.text-2)[Text 2 (small)]
      #(l.text-1)[Text 1 (caption)]
    ]

    // Label stays at full size; only the type samples scale proportionally.
    block(breakable: true)[
      #text(size: 10pt, weight: 700, font: "Libertinus Serif", fill: rgb("#0050a8"))[#name]
      #v(0.4em)
      #if factor < 1.0 {
        scale(x: factor * 100%, y: factor * 100%, reflow: true, samples)
      } else {
        samples
      }
    ]
  })
}

= Typographic Scale Comparison

#v(0.5em)

All samples use the same 11pt body, same font (Libertinus Serif), same theme.
The only difference between columns is the `scale:` parameter. Heading
sizes derive from `f₀ × r^(i/n)` per Mortensen's formula.

#v(1em)

#let row-size = 4
#let rows = range(0, calc.ceil(scales.len() / row-size)).map(i => scales.slice(i * row-size, calc.min(
  (i + 1) * row-size,
  scales.len(),
)))

#for (i, row) in rows.enumerate() {
  if i > 0 { pagebreak() }
  grid(
    columns: (1fr,) * row.len(),
    column-gutter: 1.5em,
    ..row.map(sample),
  )
}
