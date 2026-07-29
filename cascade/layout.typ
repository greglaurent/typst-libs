// Layout — named callable components composed from the cascade foundation + a theme.
//
// This module owns COMPOSITION, not typography. Every size / tracking / word-space / line box comes
// from the cascade foundation (`foundation.typ`, projected from the one spec); layout only decides
// which document roles exist, their steps and spacing, and how native Typst elements bind to them.
//
// Each component belongs to a category (`body`, `heading`, or `code`) — the foundation font role it
// reads. Override at three layers, low → high precedence:
//   1. Built-in component defaults (`_build-specs` below)
//   2. Per-component overrides at make time:  overrides: (heading-1: (...))
//   3. Per-call named arguments:              heading-1(weight: 800)[...]
//
// Meta-override keys — `step`, `size` — trigger recomputation of size / tracking / word-space / line
// box from the foundation. Any override value of `auto` is filtered out before merging (treated as
// "use the default that would otherwise apply"). Partial override dicts compose cleanly.
//
// Usage:
//   #let l = layout.make()                                  // foundation defaults
//   #let (heading-1, text-3, link, emphasis, strong, code, code-block, quote, figure-caption,
//         list, enum, figure) = l
//   #show: l.page
//   #show: l.markup
//   = Heading
//   Body with *bold* and _italic_ and `code`.
//
// Configure the foundation through make() — these pass straight to `foundation.resolve`:
//   #let l = layout.make(base: 12pt, measure: 72, scale: "golden-ratio")
//
// Swap a typeface (metrics deep-merge from the foundation default for that role):
//   #let l = layout.make(fonts: (heading: "Inter"))              // family only
//   #let l = layout.make(fonts: (body: (family: "EB Garamond", xh: 0.48)))  // family + measured metric
//   #let l = layout.make(font: "Charter")                        // one family across every role

#import "foundation.typ" as cascade
#import "theme.typ"
#import "utils.typ"

// Consumer-side sugar: modular-scale preset names → the foundation's (ratio, n). The foundation
// itself only knows ratio/n; these are convenience labels. `auto` means "the foundation default".
#let _scale-presets = (
  classical:      (ratio: 2, n: 5),
  golden-ratio:   (ratio: 1.6180339887498949, n: 1),
  golden-ditonic: (ratio: 1.6180339887498949, n: 2),
  tritonic:       (ratio: 2, n: 3),
  tetratonic:     (ratio: 2, n: 4),
  major-third:    (ratio: 1.25, n: 1),
  minor-third:    (ratio: 1.2, n: 1),
)

// ─── Component registry ────────────────────────────────────────────────────────
// Each entry: step | none, category (foundation font role), default param dict, render fn. Spacing
// (`above`/`below`) is drawn from the foundation's rhythm via `space(s, tok)` — one line = "baseline",
// grid multiples = "0"/"p1"…"p6"/"n1".

#let _build-specs(t, s) = (
  text-1:         (step: -2,   category: "body",    defaults: (fill: t.fg-muted),                        render: utils.render-text),
  text-2:         (step: -1,   category: "body",    defaults: (fill: t.fg),                              render: utils.render-text),
  text-3:         (step: 0,    category: "body",    defaults: (fill: t.fg),                              render: utils.render-text),
  text-4:         (step: 1,    category: "body",    defaults: (fill: t.fg),                              render: utils.render-text),
  text-5:         (step: 2,    category: "body",    defaults: (fill: t.fg),                              render: utils.render-text),
  heading-1:      (step: 4,    category: "heading", defaults: (weight: 700, fill: t.fg, above: cascade.space(s, "p4"), below: cascade.space(s, "p2")), render: utils.render-text),
  heading-2:      (step: 3,    category: "heading", defaults: (weight: 600, fill: t.fg, above: cascade.space(s, "p3"), below: cascade.space(s, "p1")), render: utils.render-text),
  heading-3:      (step: 2,    category: "heading", defaults: (weight: 600, fill: t.fg, above: cascade.space(s, "p2"), below: cascade.space(s, "0")),  render: utils.render-text),
  heading-4:      (step: 1,    category: "heading", defaults: (weight: 600, fill: t.fg, above: cascade.space(s, "p1"), below: cascade.space(s, "0")),  render: utils.render-text),
  link:           (step: none, category: "body",    defaults: (fill: t.link),                            render: utils.render-link),
  emphasis:       (step: none, category: "body",    defaults: (style: "italic", fill: t.fg),             render: utils.render-text),
  strong:         (step: none, category: "body",    defaults: (weight: 700, fill: t.fg),                 render: utils.render-text),
  code:           (step: none, category: "code",    defaults: (fill: t.code-fg),                         render: utils.render-text),
  code-block:     (step: 0,    category: "code",    defaults: (
                                  fill: t.code-fg,
                                  block-fill: t.code-bg,
                                  block-inset: 1em,
                                  block-radius: 4pt,
                                ),                                                                       render: utils.render-code-block),
  quote:          (step: 0,    category: "body",    defaults: (style: "italic", fill: t.fg, block-inset: (left: 2em), block-fill: t.quote-bg), render: utils.render-quote),
  figure-caption: (step: -2,   category: "body",    defaults: (style: "italic", fill: t.fg-muted),       render: utils.render-figure-caption),
  list:           (step: 0,    category: "body",    defaults: (fill: t.fg),                              render: utils.render-list),
  enum:           (step: 0,    category: "body",    defaults: (fill: t.fg),                              render: utils.render-enum),
  figure:         (step: none, category: "body",    defaults: (:),                                       render: utils.render-figure),
  divider:        (step: none, category: "body",    defaults: (stroke: 0.5pt + t.rule, length: 100%),    render: utils.render-divider),
  footnote-entry: (step: -2,   category: "body",    defaults: (fill: t.fg-muted),                        render: utils.render-text),
)

// ─── Defaults ─────────────────────────────────────────────────────────────────

#let _default-page = (
  paper: "us-letter",
  margin: 1in,
  numbering: none,
)

// ─── Public API ────────────────────────────────────────────────────────────────
// `base`/`measure`/`scale`/`size-min`/`font`/`fonts` default to `auto` — i.e. defer to the
// foundation's own defaults; only what you set is passed to `foundation.resolve`.

#let make(
  theme: theme.presets.light,
  theme-overrides: (:),
  scale: auto,
  base: auto,
  measure: auto,
  size-min: auto,
  justify: false,
  font: auto,
  fonts: (:),
  page: (:),
  overrides: (:),
) = {
  let theme = theme + theme-overrides

  // ── build the foundation-config overrides from the make() params ──
  let user = (:)
  if base != auto { user.insert("base", base) }
  if measure != auto { user.insert("measure", measure) }
  if size-min != auto { user.insert("size-min", size-min) }
  // scale: a preset name → (ratio, n), or a dict carrying ratio/n directly. `auto` → foundation default.
  if scale != auto {
    let sc = if type(scale) == str { _scale-presets.at(scale) } else { scale }
    if "ratio" in sc { user.insert("ratio", sc.ratio) }
    if "n" in sc { user.insert("n", sc.n) }
  }

  // fonts: `font:` sets one family across every role; `fonts.<role>` overrides per role (family and/or
  // measured metrics). A bare family (string/tuple) is normalised to `(family: (…,))`. Whatever lands
  // here is deep-merged onto the foundation's measured defaults by `resolve`, so a family-only override
  // keeps that role's optical metrics.
  let _norm-font = cfg => {
    if type(cfg) == str { (family: (cfg,)) }
    else if type(cfg) == array { (family: cfg) }
    else if type(cfg) == dictionary and "family" in cfg and type(cfg.family) == str { (..cfg, family: (cfg.family,)) }
    else { cfg }
  }
  let user-fonts = (:)
  if font != auto {
    let fam = if type(font) == array { font } else { (font,) }
    for role in ("body", "heading", "code") { user-fonts.insert(role, (family: fam)) }
  }
  for (role, cfg) in fonts {
    user-fonts.insert(role, user-fonts.at(role, default: (:)) + _norm-font(cfg))
  }
  if user-fonts.len() > 0 { user.insert("fonts", user-fonts) }

  // the ONE resolved foundation config — every component reads its primitives from `s`.
  let s = cascade.resolve(user)

  let specs = _build-specs(theme, s)
  let merged-page = _default-page + (fill: theme.bg) + page
  let body-font = s.fonts.at("body")

  // ── components: each reads the foundation over `s` at its role + step ──
  let result = (:)
  for (name, spec) in specs {
    let cat-state = (s: s, role: spec.category)
    // The role's family becomes a text-param default; component/per-call overrides win over it.
    let cat-defaults = (font: s.fonts.at(spec.category).family) + spec.defaults
    let merged-spec = (step: spec.step, defaults: cat-defaults, render: spec.render)
    result.insert(name, utils.make-component(cat-state, merged-spec, overrides.at(name, default: (:))))
  }

  // ── page rule — page settings + default text font/fill from the body role ──
  let page-rule = body => {
    set std.page(..merged-page)
    set text(font: body-font.family, fill: theme.fg)
    body
  }
  result.insert("page", page-rule)

  // ── markup rule — native Typst elements → our components; body defaults = text-3 (body, step 0) ──
  // Vertical rhythm is the foundation's metric-independent line box: the per-line height is carried by
  // the text's top/bottom edge (set below and per component), and paragraphs advance on the baseline.
  let bf = body-font
  let markup-rule = body => {
    set text(
      font: bf.family,
      size: cascade.size(s, 0),
      tracking: cascade.tracking(s, bf, 0),
      spacing: 100% + cascade.word-space(s, bf, 0),
      top-edge: cascade.top-edge(s, bf, 0),
      bottom-edge: cascade.bottom-edge(s, bf, 0),
      fill: theme.fg,
    )
    set par(leading: 0pt, justify: justify, spacing: cascade.baseline(s))
    set std.footnote.entry(
      separator: line(length: 30%, stroke: 0.5pt + theme.rule),
      clearance: 1em,
      gap: 0.5em,
      indent: 1em,
    )

    // ── show rules: native Typst elements → our components ──
    show std.heading.where(level: 1): it => (result.heading-1)(it.body)
    show std.heading.where(level: 2): it => (result.heading-2)(it.body)
    show std.heading.where(level: 3): it => (result.heading-3)(it.body)
    show std.heading.where(level: 4): it => (result.heading-4)(it.body)
    show std.strong: it => (result.strong)(it.body)
    show std.emph: it => (result.emphasis)(it.body)
    // `link` styling — break recursion by detecting an already-underlined body. First pass wraps in
    // underline + colored text + re-emits link to preserve click semantics; second pass passes through.
    show std.link: it => if it.body.func() == underline {
      it
    } else {
      link(it.dest, underline(
        stroke: 0.5pt + theme.link,
        text(fill: theme.link, it.body),
      ))
    }
    show std.raw.where(block: false): it => (result.code)(it)
    show std.raw.where(block: true): it => (result.code-block)(it)
    show std.list: it => (result.list)(it)
    show std.enum: it => (result.enum)(it)
    show std.quote: it => (result.quote)(attribution: it.attribution, it.body)
    show std.figure.caption: it => (result.figure-caption)(it.body)
    show std.footnote.entry: it => (result.footnote-entry)(it)
    // `figure` itself isn't bound — our figure component re-emits a figure element, which would
    // recurse. Use `#figure(...)` (the component) explicitly.

    body
  }
  result.insert("markup", markup-rule)

  result.insert("theme", theme)
  result.insert("spec", s)   // the resolved foundation config — introspect / feed the primitives directly

  result
}
