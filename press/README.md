# press

A generic document **template + framework** for Typst. It composes a document from modular
sections and knows nothing about what those sections are — any pairs, any order, any structure.
Formatting is a separate concern, supplied through `l` (a formatter such as cascade); press
never names or depends on it.

## The convention

A document is a set of **sections**. Each section is a matched pair, bound by a shared name:

```
content/<x>.typ   the content — data          #let content = …          (a dict or a block)
<x>.typ           the renderer — arrangement   #import "content/<x>.typ": content
                                               #let render(l) = …   (arrange it through l)
```

The renderer finds its own content by the matching name. `main.typ` orders the sections and
frames them. Nothing is hand-wired: the matched names declare the pairing, so a document only
ever adds a `content/<x>` + `<x>` pair and lists it in `main`.

## Assets

Images and other binary resources live in a standard **`assets/`** folder at the project root.
Content stays pure data — it holds the *path string* (`src: "assets/logo.svg"`), and the
renderer turns it into an image: `#let render(l) = (l.figure)(image(content.src), content.caption)`.
Because `image()` resolves paths relative to the file that calls it, and renderers sit at the
project root, an `assets/…` path just works. The scaffold ships an `assets/` folder and a `plate`
section that demonstrates it.

## `main.typ`

```typ
#import "@local/press:0.1.0": document
#import "section-one.typ" as section-one
#import "section-two.typ" as section-two

#let l = …    // your formatter — cascade or any layer exposing l.page / l.markup / components

#let body = {
  section-one.render(l)
  pagebreak()
  section-two.render(l)
}

#document(l, body)
```

Add or remove matched pairs to get any structure — a paper with no title page simply has no
such pair; a book with twelve custom sections has twelve pairs.

## API

### `document(l, body, header: none, footer: none)`

Frame an ordered `body` of rendered sections into the finished document, using formatter `l`.
`header`/`footer` are section renderers `(l, page) => content`, shown on every page. Paper,
margins, numbering and fill all come from `l`; press sets nothing static.

## Scaffold

`typst init @local/press <name>` copies the `template/` structure — `content/`, matched section
renderers, an `assets/` folder, and a `main.typ` — as a starting point. Swap the stub `l` in
`main.typ` for your formatter.
