#import "content/points.typ": content

#let render(l) = {
  (l.heading-2)[#content.heading]
  (l.rule)()
  list(..content.items)
}
