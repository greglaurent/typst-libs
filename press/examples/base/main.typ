#import "@local/press:0.1.0": document
#import "formatter.typ": make
#import "composition.typ" as composition
#import "header.typ" as header
#import "footer.typ" as footer

#document(
  formatter: make,
  config: (base: 10.5pt, paper: "a5"),
  compose: composition.render,
  header: header.render,
  footer: footer.render,
)
