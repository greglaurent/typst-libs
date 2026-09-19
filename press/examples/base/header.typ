#import "content/title.typ": content
#import "content/header.typ": content as metadata

#let render(l, page) = {
  if counter(page).get().first() > 1 {
    align(right, (l.caption)([#content.title — #metadata.author]))
  }
}
