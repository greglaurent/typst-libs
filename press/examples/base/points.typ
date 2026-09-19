#import "content/points.typ": content

#let render(l) = block(breakable: false, {
  (l.heading-2)[#content.heading]
  (l.rule)()
  list(..content.items)
})
