// cascade — GENERATED Typst LIBRARY (a customizable typographic foundation for print).
//
// NOTHING is baked: `_defaults` holds the overridable primitives and every typographic value is a
// Typst `calc` expression computed from the resolved spec — override the config and the whole system
// recomputes at compile time. The token-function bodies are PROJECTED from the one spec via cascade's
// formula layer (the same source the CSS renderer projects), so they cannot drift.
//
// Usage:
//   #import "cascade.typ": cascade
//   #show: cascade.with(base: 13pt, measure: 73, fonts: (body: ("Charter",)))
//   = A heading
//   Body with *bold*, _italic_, `code`, and a footnote.#footnote[…]
// CLI overrides: `typst compile doc.typ --input base=13pt --input measure=73`  (DEFAULTS < CLI < document)

// ── DEFAULTS: the overridable primitives (from the spec) ──────────────────────────
#let _defaults = (
  base: 11pt,
  ratio: 1.618033988749895, n: 2,
  measure: 73, avg-advance: 0.4735,
  size-min: 9pt, rhythm-ratio: 0.5,
  leading: (min: 1.1, max: 1.45),
  tracking: (tighten-max: 0.02, loosen-max: 0.04, tighten-ratio: 0.13),
  word-space-k: 0.04, code-scale: 0.9,
  page: (paper: "us-letter", margin: auto),
  spacing-factors: ("n1": 0.5, "0": 1, "p1": 2, "p2": 3, "p3": 4, "p4": 6, "p5": 8, "p6": 12),
  fonts: (body: (family: ("Inter",), x-height: 0.546, leading-base: 1.3, tracking-k: 0.078, word-space: 0.26), heading: (family: ("Lora",), x-height: 0.5, leading-base: 1.2, tracking-k: 0.078, word-space: 0.28), code: (family: ("IBM Plex Mono",), x-height: 0.516, leading-base: 1.35, tracking-k: 0, word-space: 0)),
)

// ── baked palette (light) — print colour is medium-specialized, not a config knob (yet) ──
#let _theme = (
  fg: rgb("#171717"), fg-muted: rgb("#59544C"), fg-subtle: rgb("#7A746A"),
  bg: rgb("#F6F2E9"), rule: rgb("#C4BDB0"), link: rgb("#7A2E28"),
  code-fg: rgb("#171717"), code-bg: rgb("#EFE9DC"),
  quote-rule: rgb("#C9A5A0"), quote-bg: none,
)

// ── recursive deep-merge (Typst's `+` is shallow — a partial `fonts:(body:…)` would wipe siblings) ──
#let _deep-merge(base, over) = {
  let out = base
  for (k, v) in over {
    out.insert(k, if type(v) == dictionary and type(base.at(k, default: none)) == dictionary {
      _deep-merge(base.at(k), v)
    } else { v })
  }
  out
}

// ── sys.inputs (CLI `--input …`) — values are strings, cast per key. DEFAULTS < CLI < document. ──
#let _parse-inputs() = {
  let o = (:)
  let i = sys.inputs
  if "base" in i { o.base = eval(i.base) }
  if "measure" in i { o.measure = int(i.measure) }
  if "ratio" in i { o.ratio = float(i.ratio) }
  o
}
#let _resolve(user) = _deep-merge(_deep-merge(_defaults, _parse-inputs()), user)

// ── TOKEN FUNCTIONS: projected from formula::* via TypstCalc, computed over the resolved spec ──
#let _ln-ratio(s) = calc.ln(s.ratio)
#let _factor(s, step) = calc.pow(s.ratio, step / s.n)
#let _size(s, step) = calc.max(s.base * _factor(s, step), s.size-min)
#let _code-size(s, step) = _size(s, step) * (s.fonts.body.x-height / s.fonts.code.x-height) * s.code-scale
#let _lead0(s, f) = f.leading-base + (s.measure - 65) * 0.006 - (f.x-height - 0.5) * 0.8
#let _leading(s, f, step) = calc.clamp(_lead0(s, f) - 0.1 * (step / s.n) * _ln-ratio(s), s.leading.min, s.leading.max)
#let _tracking(s, f, step) = { let k = if step > 0 { f.tracking-k * s.tracking.tighten-ratio } else { f.tracking-k }; (calc.clamp(-1 * k * (step / s.n) * _ln-ratio(s), -1 * s.tracking.tighten-max, s.tracking.loosen-max)) * 1em }
#let _word-space(s, f, step) = (f.word-space - s.word-space-k * (step / s.n) * _ln-ratio(s)) * 1em
#let _baseline(s) = s.base * _leading(s, s.fonts.body, 0)
#let _unit(s) = _baseline(s) * s.rhythm-ratio
#let _measure-width(s) = s.measure * s.avg-advance * s.base
#let _te(s, f, step) = ((_leading(s, f, step) + 1) / 2 - 0.25) * 1em
#let _be(s, f, step) = (-1 * ((_leading(s, f, step) - 1) / 2 + 0.25)) * 1em

// ── ROLE STRUCTURE: step / font-role / weight / style / spacing — the document model, projected ──
#let _roles = (
  body: (step: 0, font: "body", below: "baseline"),
  heading-1: (step: 4, font: "heading", weight: 700, above: "p4", below: "p2"),
  heading-2: (step: 3, font: "heading", weight: 600, above: "p3", below: "p1"),
  heading-3: (step: 2, font: "heading", weight: 600, above: "p2", below: "0"),
  heading-4: (step: 1, font: "heading", weight: 600, above: "p1", below: "0"),
  text-1: (step: -2, font: "body"),
  text-2: (step: -1, font: "body"),
  text-3: (step: 0, font: "body"),
  text-4: (step: 1, font: "body"),
  text-5: (step: 2, font: "body"),
  strong: (font: "body", weight: 700),
  emphasis: (font: "body", style: "italic"),
  small: (step: -1, font: "body"),
  link: (font: "body"),
  quote: (font: "body", style: "italic", above: "baseline", below: "baseline"),
  code: (font: "code"),
  code-block: (font: "code", below: "baseline"),
  list: (font: "body", below: "baseline"),
  figure: (font: "body", above: "p4", below: "p4"),
  caption: (step: -2, font: "body", style: "italic"),
  footnotes: (step: -2, font: "body"),
  sidenote: (step: -2, font: "body"),
  marginnote: (step: -2, font: "body"),
  divider: (font: "body", above: "p4", below: "p4"),
)

// ── application helpers ───────────────────────────────────────────────────────────
#let _font(s, name) = s.fonts.at(name)
// a spacing token id → a length: "baseline" = one line, else a rhythm multiple.
#let _space(s, tok) = if tok == "baseline" { _baseline(s) } else { _unit(s) * s.spacing-factors.at(tok) }
// Page margin. An explicit `margin` (length/dict) is used as-is — normal print margins. `margin: auto`
// CENTRES the reading measure: the horizontal margin is (paper width − measure width)/2, with a 1in
// vertical margin. Auto needs the paper's width; common papers are tabled (else it falls back to
// us-letter, or just set an explicit margin for an untabled paper).
#let _paper-widths = (
  "us-letter": 8.5in, "us-legal": 8.5in, "a3": 297mm, "a4": 210mm, "a5": 148mm, "a6": 105mm,
  "b4": 250mm, "b5": 176mm, "iso-b5": 176mm, "presentation-16-9": 297mm, "presentation-4-3": 280mm,
)
#let _page-margin(s) = {
  let m = s.page.margin
  if m == auto {
    let w = _paper-widths.at(s.page.paper, default: 8.5in)
    (x: (w - _measure-width(s)) / 2, y: 1in)
  } else { m }
}
// apply a SIZED role's text: size / tracking / word-space / line-box edges (+ weight/style). A role
// with no `step` (a block container like quote/code-block) reads at the body size (step 0); `size`
// overrides it (code passes its x-height-matched size).
#let _apply(s, r, body, font: auto, fill: auto, size: auto) = {
  let f = if font == auto { _font(s, r.font) } else { font }
  let step = r.at("step", default: 0)
  let args = (
    font: f.family, size: if size == auto { _size(s, step) } else { size },
    tracking: _tracking(s, f, step), spacing: 100% + _word-space(s, f, step),
    top-edge: _te(s, f, step), bottom-edge: _be(s, f, step),
    fill: if fill == auto { _theme.fg } else { fill },
  )
  if "weight" in r { args.insert("weight", r.weight) }
  if "style" in r { args.insert("style", r.style) }
  text(..args, body)
}
// a block-flow role (heading / code-block / quote): the applied text wrapped in margins.
#let _sized-block(s, r, body, font: auto, fill: auto) = block(
  above: if "above" in r { _space(s, r.above) } else { auto },
  below: if "below" in r { _space(s, r.below) } else { auto },
  { set par(leading: 0pt); _apply(s, r, body, font: font, fill: fill) },
)

// ── PUBLIC PRIMITIVE API ────────────────────────────────────────────────────────
// The live, overridable typographic primitives — for consumers that bring their OWN document
// composition (their own components / show rules) and design WITH the foundation instead of through
// `cascade()`. Call `resolve(user)` once to get the config `s`, then the primitives compute over it;
// override the config and they recompute. Internals stay `_`-prefixed (some collide with common
// parameter names like `font`/`size`); THESE names are the published contract. A font role is a plain
// `s.fonts.at("body")` lookup. Import them directly:
//   #import "cascade.typ": resolve, size, leading, tracking, word-space, baseline, unit, space
#let resolve = _resolve
#let size = _size
#let code-size = _code-size
#let leading = _leading
#let tracking = _tracking
#let word-space = _word-space
#let baseline = _baseline
#let unit = _unit
#let space = _space
#let measure-width = _measure-width
#let top-edge = _te
#let bottom-edge = _be

// the resolved spec, published so the exported helpers below can read it via `context`.
#let _spec = state("cascade-spec", _defaults)

// ── the front door: resolve the config, bind native elements to the computed tokens ──────────────
#let cascade(..named, body) = {
  let s = _resolve(named.named())
  _spec.update(s)
  let b = _font(s, "body")

  // page — the paper + margin come from the config: `margin: auto` centres the measure on any paper,
  // an explicit margin gives normal print margins (see `_page-margin`).
  set page(paper: s.page.paper, margin: _page-margin(s), fill: _theme.bg)
  // body defaults (the `body` role, step 0).
  set text(font: b.family, size: _size(s, 0), tracking: _tracking(s, b, 0),
           spacing: 100% + _word-space(s, b, 0), top-edge: _te(s, b, 0), bottom-edge: _be(s, b, 0),
           fill: _theme.fg)
  set par(leading: 0pt, spacing: _baseline(s), justify: false)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt + _theme.rule),
                     clearance: 1em, gap: 0.5em, indent: 1em)

  // headings — block role, heading family, own leading + margins.
  show heading: it => _sized-block(s, _roles.at("heading-" + str(it.level)), it.body)
  // inline decorations — apply ONLY the decoration, INHERIT size/leading/tracking from context.
  show strong: set text(weight: _roles.strong.weight)
  show emph: set text(style: _roles.emphasis.style)
  show link: it => if it.body.func() == underline { it } else {
    link(it.dest, underline(stroke: 0.5pt + _theme.link, offset: 0.15em, text(fill: _theme.link, it.body)))
  }
  // inline code — a tinted pill hugging the glyphs (font's own edges, not the tall line box). Size is
  // the x-height match as a RELATIVE em factor (print analogue of CSS font-size-adjust), so it scales
  // with the surrounding context; mono is untracked (kt 0).
  show raw.where(block: false): it => box(
    fill: _theme.code-bg, inset: (x: 0.34em), outset: (y: 0.12em), radius: 2.25pt,
    text(font: _font(s, "code").family, size: (s.fonts.body.x-height / s.fonts.code.x-height) * s.code-scale * 1em,
         fill: _theme.code-fg, it.text),
  )
  // code block — a tinted block at the x-height-matched code size, never hyphenated or justified.
  show raw.where(block: true): it => block(
    fill: _theme.code-bg, inset: 1em, radius: 4pt, width: 100%, breakable: true, below: _baseline(s),
    { set par(leading: 0pt, justify: false); set text(hyphenate: false)
      _apply(s, _roles.at("code-block"), it.text, font: _font(s, "code"), fill: _theme.code-fg,
             size: _code-size(s, 0)) },
  )
  // quote — vertical padding (p1) + 2em sides + a left rule; upright right-aligned attribution.
  show quote: it => block(
    inset: (x: 2em, y: _space(s, "p1")), stroke: (left: 2.25pt + _theme.quote-rule),
    fill: _theme.quote-bg, below: _baseline(s),
    { set par(leading: 0pt, spacing: _baseline(s)); _apply(s, _roles.quote, it.body)
      if it.attribution != none { parbreak(); align(right, _apply(s, _roles.quote, [— #it.attribution])) } },
  )
  show std.figure.caption: it => align(center, _apply(s, _roles.caption, it.body))
  show footnote.entry: it => _apply(s, _roles.footnotes, it, fill: _theme.fg-subtle)

  body
}

// ── exported helpers: design WITH the foundation. They read the resolved spec via `context`, so the
// roles that have no native Typst element (the scale spans, notes, divider) are still computed, not
// baked. Import alongside `cascade`: `#import "cascade.typ": cascade, text-3, sidenote, hr`.
#let scale(step, body) = context _apply(_spec.get(), (step: step, font: "body"), body)
#let text-1(body) = scale(-2, body)
#let text-2(body) = scale(-1, body)
#let text-3(body) = scale(0, body)
#let text-4(body) = scale(1, body)
#let text-5(body) = scale(2, body)
// Notes: print has one place for a note — the foot. Side/margin notes degrade to footnotes here.
#let sidenote(body) = footnote(body)
#let marginnote(body) = footnote(body)
// A horizontal rule on the rhythm grid.
#let hr() = context {
  let s = _spec.get()
  block(above: _space(s, "p4"), below: _space(s, "p4"), line(length: 100%, stroke: 0.5pt + _theme.rule))
}