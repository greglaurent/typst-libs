#import "@local/press:0.1.0": document
#import "formatter.typ": make
#import "section-one.typ" as section-one
#import "section-two.typ" as section-two
#import "plate.typ" as plate

// Each renderer imports its content. Here we select and order the presentation.
#document(
  formatter: make,
  config: (paper: "us-letter", base: 11pt),
  compose: l => {
    section-one.render(l)
    pagebreak()
    section-two.render(l)
    plate.render(l)
  },
)
