#import "scale.typ"

// Per-typeface optical profile: tracking, leading, and word-space as size-dependent functions.
//
// Compose with style/scale.typ — scale provides sizes, font provides spacing rules.
//
// Tracking (Ahrens & Mugikura 2014):
//   tracking_em = k-tracking · ln(optical-size / size), clamped to |tracking| ≤ tracking-clamp.
//
// Leading (Bringhurst §2.2, Dyson on measure, Larson on comfort range):
//   leading_ratio = leading-base
//                 + (measure - 65) · 0.006        // Dyson: ±0.06 per 10ch
//                 - (x-height - 0.50) · 0.8       // tall x-heights need looser leading
//                 - 0.10 · ln(size / optical-size) // tighter at display sizes
//   leading = (leading_ratio - 1) · size          // Typst's leading is the gap between lines
//
// Word space (Bringhurst §2.1.4–5, Tracy on letter-relative spacing):
//   word_space_em = base-word-space + k-word-space · ln(optical-size / size)
//   Inverse-with-size: caption text wants relatively more word space than display.
//
// All per-typeface parameters fully characterize what typography manuals teach as
// judgment calls. Override per font when you have the data.

#let make(
  optical-size: 12pt,
  x-height: 0.50,
  k-tracking: 0.030,
  leading-base: 1.45,
  tracking-clamp: 0.04,
  base-word-space: 0.28,
  k-word-space: 0.04,
) = {
  let tracking = s => {
    let raw = k-tracking * calc.ln(optical-size / s)
    let val = if tracking-clamp == none { raw } else {
      calc.max(-tracking-clamp, calc.min(tracking-clamp, raw))
    }
    val * 1em
  }
  let leading-ratio = (s, measure: 65) => {
    let m = if measure == none { 0 } else { (measure - 65) * 0.006 }
    let x = -(x-height - 0.50) * 0.8
    let z = -0.10 * calc.ln(s / optical-size)
    leading-base + m + x + z
  }
  let leading = (s, measure: 65) => {
    (leading-ratio(s, measure: measure) - 1.0) * s
  }
  let word-space = s => {
    (base-word-space + k-word-space * calc.ln(optical-size / s)) * 1em
  }
  (
    tracking: tracking,
    leading: leading,
    leading-ratio: leading-ratio,
    word-space: word-space,
    params: (
      optical-size: optical-size,
      x-height: x-height,
      k-tracking: k-tracking,
      leading-base: leading-base,
      tracking-clamp: tracking-clamp,
      base-word-space: base-word-space,
      k-word-space: k-word-space,
    ),
  )
}

#let presets = (
  sans-ui:    make(optical-size: 14pt, x-height: 0.53, k-tracking: 0.035, leading-base: 1.45, base-word-space: 0.25),
  sans-text:  make(optical-size: 12pt, x-height: 0.53, k-tracking: 0.030, leading-base: 1.45, base-word-space: 0.28),
  serif-text: make(optical-size: 11pt, x-height: 0.49, k-tracking: 0.022, leading-base: 1.35, base-word-space: 0.33),
  sf-pro:     make(optical-size: 12pt, x-height: 0.53, k-tracking: 0.045, leading-base: 1.45, base-word-space: 0.25),
)

// Bundles — family + scale + optical profile, packaged as a single config
// per typographic style. Use as defaults in layout.make's `fonts:` parameter.
//
// Family names are Typst-bundled fonts (Libertinus Serif and DejaVu Sans Mono are
// both shipped with the Typst binary). Typst does not bundle a sans-serif family,
// so `sans` uses Libertinus Serif as a placeholder family with sans-text optical
// formulas; override `family:` when you have an actual sans typeface installed.
#let bundles = (
  sans: (
    family:  "Libertinus Serif",  // placeholder; user supplies real sans family
    scale:   scale.presets.classical,
    profile: presets.sans-text,
  ),
  serif: (
    family:  "Libertinus Serif",
    scale:   scale.presets.classical,
    profile: presets.serif-text,
  ),
  mono: (
    family:  "DejaVu Sans Mono",
    scale:   scale.presets.classical,
    profile: presets.sans-text,
  ),
)
