# Press

Press organizes a Typst document through functions. Content and its presentation
live in separate files; composition selects and orders renderers. A configurable
formatter supplies typography without prescribing a document structure.

## Content and presentation

```text
main.typ              supplies formatting and composes the document
poem.typ              arranges and styles the poem through l
header.typ            presents running matter
content/
  poem.typ            poem title and verse
  header.typ          shared metadata
assets/               images and other resources
```

Matching names are a convention, not automatic discovery. `poem.typ` explicitly
imports `content/poem.typ` and exports `render(l)`. Content can be a dictionary or
Typst content, including meaningful emphasis, footnotes and verse breaks. The
renderer owns arrangement, alignment and document-specific spacing, using `l`
for typography.

Renderers may combine multiple content sources: the example title reads both its
own content and shared metadata. They may also produce content from context,
like a page-number footer, without a matching content file. Shared content does
not need duplication. Nested folders and reusable compositions are ordinary
Typst modules; Press neither discovers nor restricts them.

For assets, content can store a path string and the renderer call
`image(content.src)`. Relative paths resolve from the file calling `image`, so
`assets/logo.svg` assumes a renderer at the document root. A nested renderer
must use a suitable relative path or a project-root path such as `/assets/logo.svg`.
Set Typst's `--root` to the shared document root when importing sibling folders.

## Compose a document

```typ
#import "@local/press:0.1.0": document
#import "formatter.typ": make
#import "poem.typ" as poem
#import "header.typ" as header

#document(
  formatter: make,
  config: (base: 12pt),
  compose: l => {
    poem.render(l)
    // Select other renderers and page breaks here.
  },
  header: header.render,
)
```

`formatter(config)` returns a dictionary `l`. Press calls the factory once per
`document` invocation and passes that same dictionary to `compose(l)` and optional
`header(l, page)` / `footer(l, page)` callbacks. These return Typst content.

The only required formatter members are `page(body)` and `markup(body)`.
Sections establish their own component requirements, such as `heading-1` or
`text-3`. Extend a formatter by returning a dictionary with additional functions.
Press checks the factory and wrapper contract; Typst reports missing components
where a renderer uses them.

`page` wraps the complete document. Inside it, Press attaches optional running
matter and applies `markup` to the composed body. Header/footer callbacks execute
in page context. Typst determines inherited page styles during layout, so running
matter should use explicit `l` components for its typography. Press passes only
the composed body to `markup`. Omitted callbacks preserve the formatter's own
running matter. Supplied callbacks replace the corresponding header/footer and
can choose when to return content. `page` is Typst's page element, suitable for
`counter(page).get()` or `.final()`.

## Configure Cascade through Press

```typ
#import "@local/press:0.1.0": document, cascade-formatter
#import "@local/cascade:2.0.0" as typography
#import "poem.typ" as poem

#document(
  formatter: cascade-formatter.with(typography),
  config: (
    base: 12pt,
    measure: 85,
    page: (paper: "us-letter", margin: 1in),
  ),
  compose: l => poem.render(l),
)
```

You may instead import a generated file: `#import "cascade.typ" as typography`.
Pass the module, not just its `cascade` function. The adapter imports no Cascade
package itself. It targets the Cascade 2.0 export API with its callable components.

The adapter passes configuration unchanged as named arguments to `cascade` and
preserves its public exports on `l`, including `heading-1` through `heading-4`,
`text-1` through `text-5`, `span`, `scale`, `caption`, and primitives such as
`resolve` and `space`. Components retain their per-call arguments. Contextual
components read the resolved Cascade configuration inside the page wrapper;
primitive functions still take an explicit resolved spec, as in Cascade's API.

The adapter adds these composition conveniences:

| Member | Implementation |
| --- | --- |
| `page` | Cascade's configured document wrapper |
| `markup`, `body` | Return content unchanged |
| `lead` | Cascade's `text-4` in a block |
| `rule` | Cascade's `hr` |
| `figure(img, caption)` | Native Typst figure, styled by Cascade |

The original `hr` and other public exports remain available. Components named
`heading-1`, etc. retain Cascade's behavior; use native `heading` when you need
native heading semantics such as outlines and numbering.

Configuration options and precedence belong to Cascade: exported defaults, then
supported CLI inputs, then this document's config. Current Cascade exports accept
`theme: "monochrome"` or a partial palette dictionary such as
`theme: (fg: black, bg: white)`. Footnotes default to the body foreground;
`footnotes: (fill: black, rule: black)` overrides their text and separator colors.
These options pass through Press unchanged; regenerate older Cascade exports
to enable them. The page wrapper currently applies paper and margins rather than
every Typst page option. Passing an unsupported key does not add that capability. To add
page numbering or another document-specific behavior, extend the factory:

```typ
#let make(config) = {
  let l = cascade-formatter(typography, config)
  l + (page: body => (l.page)({ set page(numbering: "1"); body }),)
}
```

## Scaffold and examples

`typst init @local/press:0.1.0 my-document` copies a working scaffold with a small
`formatter.typ`, content/presentation pairs and an asset. Replace the factory in
`main.typ` to use Cascade or another formatter. No particular title page, section
names, content schema or order is required.

`examples/base` and `examples/cascade` share content, renderers, composition and
running matter. Only the factory and its configuration differ. From `examples/`:

```sh
typst compile --root . base/main.typ base/press-example.pdf
typst compile --root . cascade/main.typ cascade/cascade.pdf
```

The Cascade example requires the separately installed `@local/cascade:2.0.0`.
The repository checks can instead use a supplied export in an isolated package
root; they test configuration propagation, per-call components, running matter,
composition order, invalid contracts and both examples.

## Migrating the unreleased API

The previous `document(l, body, ...)` call becomes:

```typ
#document(
  formatter: config => l,
  compose: l => body,
  // Existing header/footer functions can be passed unchanged.
)
```

For configurable documents, move formatter construction into the factory and
section calls into `compose`, so both use the supplied configuration. Existing
content and renderer files keep their convention and `render(l)` interface.
The package remains at unreleased version 0.1.0.
