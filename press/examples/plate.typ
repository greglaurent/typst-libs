#import "content/plate.typ": content

// image() resolves relative to THIS renderer (project root), so "assets/…" just works.
// The figure's styling comes entirely from l.
#let render(l) = (l.figure)(image(content.src, width: 45%), content.caption)
