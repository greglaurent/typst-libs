#import "title.typ" as title
#import "essay.typ" as essay
#import "points.typ" as points
#import "plate.typ" as plate

#let render(l) = {
  title.render(l)
  pagebreak()
  essay.render(l)
  plate.render(l)
  points.render(l)
}
