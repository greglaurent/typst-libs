#import "content/title.typ": content
#import "content/header.typ": content as metadata

// Arrange this section through the formatter `l`. The layout is this file's design;
// press dictates none of it. A renderer can combine multiple content sources.
#let render(l) = {
  v(2.5cm)
  (l.heading-1)[#content.title]
  (l.lead)[#content.subtitle]
  metadata.author
  linebreak()
  metadata.date
}
