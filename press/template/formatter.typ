// A document-local formatter factory. Replace it with another factory, or use
// cascade-formatter.with(your-imported-cascade-module).
#let make(config) = {
  let settings = (paper: "us-letter", base: 11pt) + config
  (
    page: body => {
      set page(paper: settings.paper, numbering: "1")
      set text(size: settings.base)
      body
    },
    markup: body => body,
    heading-1: body => heading(level: 1, body),
    figure: (img, caption) => figure(img, caption: caption),
  )
}
