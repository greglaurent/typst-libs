#import "content/section-one.typ": content

// Arrange this section's content through the formatter `l`. This layout is YOUR design;
// press dictates none of it. `l` supplies the components (headings, text, rules, …).
#let render(l) = {
  (l.heading-1)[#content.heading]
  content.body
}
