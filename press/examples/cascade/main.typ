// Same content, renderers, composition, header and footer as the base example.
// Compile with examples/ as the root to permit the shared renderer imports.
#import "@local/press:0.1.0": document, cascade-formatter
#import "@local/cascade:2.0.0" as typography
#import "../base/composition.typ" as composition
#import "../base/header.typ" as header
#import "../base/footer.typ" as footer

#document(
  formatter: cascade-formatter.with(typography),
  config: (base: 12pt, measure: 65, page: (paper: "a5", margin: 18mm)),
  compose: composition.render,
  header: header.render,
  footer: footer.render,
)
