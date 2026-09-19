// Press composes documents. Content and its presentation are paired by convention;
// renderers explicitly import their sources and compose(l) explicitly orders them.
// Typography comes from a supplied factory: formatter(config) -> dictionary.
#import "adapters/cascade.typ": cascade-formatter

#let document(formatter: none, config: (:), compose: none, header: none, footer: none) = {
  assert(type(formatter) == function, message: "press: formatter must be a function taking config")
  assert(type(config) == dictionary, message: "press: config must be a dictionary")
  assert(type(compose) == function, message: "press: compose must be a function taking l")
  assert(header == none or type(header) == function, message: "press: header must be none or a function taking (l, page)")
  assert(footer == none or type(footer) == function, message: "press: footer must be none or a function taking (l, page)")
  let l = formatter(config)
  assert(type(l) == dictionary, message: "press: formatter must return a dictionary")
  for name in ("page", "markup") {
    assert(type(l.at(name, default: none)) == function,
      message: "press: formatter must provide a " + name + " function")
  }
  let running = (:)
  if header != none { running.insert("header", context { header(l, page) }) }
  if footer != none { running.insert("footer", context { footer(l, page) }) }
  (l.page)({
    // Set rules inside an if block would expire before the body is emitted.
    set page(..running)
    (l.markup)(compose(l))
  })
}
