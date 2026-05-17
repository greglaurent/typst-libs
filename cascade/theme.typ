// Theme — semantic color tokens.
//
// Tokens:
//   fg, fg-muted, fg-subtle   — text by emphasis
//   bg, bg-subtle             — page + callout background
//   accent                    — primary accent (links, etc.)
//   rule                      — divider stroke color
//   link, code-bg, code-fg    — auto-derived from accent / bg-subtle / fg
//   quote-rule, quote-bg      — auto-derived from fg-muted / none
//
// `presets.light` is the curated palette; `presets.dark` is derived from light
// by flipping HSL lightness on every color. Both presets are overridable via:
//   theme.make(..theme.presets.light, accent: red)   // tweak light
//   theme.make(..theme.presets.dark,  bg:     red)   // tweak dark
// Or build from scratch with theme.make(fg: ..., bg: ..., ...).
//
// For a fully custom light theme with auto-derived dark, use `derive-dark(palette)`
// to flip the lightness yourself, then pass to make().

#let _flip-lightness(c) = {
  let parts = color.hsl(c).components()
  color.hsl(parts.at(0), parts.at(1), 100% - parts.at(2))
}

#let derive-dark(palette) = {
  let r = (:)
  for (k, v) in palette {
    r.insert(k, if type(v) == color { _flip-lightness(v) } else { v })
  }
  r
}

#let _or-fallback(v, fb) = if v == auto { fb } else { v }

#let make(
  fg:         none,
  fg-muted:   none,
  fg-subtle:  none,
  bg:         none,
  bg-subtle:  none,
  accent:     none,
  rule:       none,
  link:       auto,
  code-bg:    auto,
  code-fg:    auto,
  quote-rule: auto,
  quote-bg:   auto,
) = (
  fg: fg,
  fg-muted: fg-muted,
  fg-subtle: fg-subtle,
  bg: bg,
  bg-subtle: bg-subtle,
  accent: accent,
  rule: rule,
  link:       _or-fallback(link, accent),
  code-bg:    _or-fallback(code-bg, bg-subtle),
  code-fg:    _or-fallback(code-fg, fg),
  quote-rule: _or-fallback(quote-rule, fg-muted),
  quote-bg:   _or-fallback(quote-bg, none),
)

// Book-typography light palette. Alt bg: #FAFAF7 (newsprint). Alt accent: #8B2F2A (oxblood).
#let _light-palette = (
  fg:        rgb("#1A1A1A"),  // 16.64:1 on bg, AAA
  fg-muted:  rgb("#525250"),  //  7.49:1, AAA
  fg-subtle: rgb("#6C6C69"),  //  5.04:1, AA
  bg:        rgb("#F8F7F2"),
  bg-subtle: rgb("#F0EEE7"),
  accent:    rgb("#1F3A5F"),  // 10.98:1, AAA
  rule:      rgb("#8E8E8A"),
)

#let presets = (
  light: make(.._light-palette),
  dark:  make(..derive-dark(_light-palette)),
)
