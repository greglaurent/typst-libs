#import "content/title.typ": content

// Arrange this section through the formatter `l`. The layout is this file's design;
// press dictates none of it, and `l` supplies every visual primitive.
#let render(l) = {
  v(2.5cm)
  (l.heading-1)[#content.title]
  (l.lead)[#content.subtitle]
  content.author
  linebreak()
  content.date
}
