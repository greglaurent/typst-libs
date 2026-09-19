// Accept an imported Cascade Typst module; never import a package version here.
// Bind its source once: cascade-formatter.with(source).
#let cascade-formatter(source, config) = {
  assert(type(source) == module, message: "press: Cascade source must be an imported module")
  assert(type(config) == dictionary, message: "press: Cascade config must be a dictionary")
  let exports = dictionary(source)
  for name in ("cascade", "text-4", "hr") {
    assert(type(exports.at(name, default: none)) == function,
      message: "press: Cascade export must provide " + name)
  }
  // Preserve the exported component/primitives API, including per-call arguments.
  // Private implementation details are not part of l's interface.
  let l = (:)
  for (name, value) in exports {
    if not name.starts-with("_") { l.insert(name, value) }
  }
  l + (
    page: source.cascade.with(..config),
    markup: body => body,
    body: body => body,
    lead: body => block(source.text-4(body)),
    rule: source.hr,
    figure: (img, caption) => std.figure(img, caption: caption),
  )
}
