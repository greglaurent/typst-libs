#import "content/plate.typ": content

// image() resolves paths relative to THIS renderer, which sits at the project root —
// so a path like "assets/…" from content just works. Styling comes from l.figure.
#let render(l) = (l.figure)(image(content.src, width: 55%), content.caption)
