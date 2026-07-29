// Cascade — typography system for Typst.
//
// Composition (named callable components + `page`/`markup` show rules) built on top of the cascade
// foundation — the generated `foundation.typ`, projected from one spec. Typical usage:
//
//   #import "@local/cascade:0.1.0": layout
//   #let l = layout.make()
//   #show: l.page
//   #show: l.markup
//   = Heading
//   Body with *bold* and _italic_ and `code`.
//
// Or reach the foundation primitives directly to design your own components with it:
//
//   #import "@local/cascade:0.1.0": foundation
//   #let s = foundation.resolve((base: 12pt))
//   #text(size: foundation.size(s, 4), ...)[Display]
//
// Modules:
//   layout     — named callable components (headings, body, lists, quotes, …) + `page`/`markup`
//                show rules. Top-level entry point.
//   theme      — semantic colour tokens with light/dark presets.
//   foundation — the GENERATED typographic foundation: an overridable config → computed primitives
//                (size / tracking / leading / rhythm). Regenerate with `just gen-foundation`; never
//                edit by hand — it is projected from the cascade-typeset spec.

#import "layout.typ"
#import "theme.typ"
#import "foundation.typ"
