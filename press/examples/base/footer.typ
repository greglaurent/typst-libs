// No content file is necessary for presentation derived from page context.
#let render(l, page) = align(center, (l.caption)([
  #counter(page).get().first() / #counter(page).final().first()
]))
