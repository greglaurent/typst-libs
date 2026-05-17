// Vertical rhythm — derives a baseline grid and spacing scale from scale + font + measure.
//
// The grid is not an independently-designed thing; it falls out of the typography
// decisions already made in scale.typ and font.typ. Body baseline distance is the
// product of body size and leading-ratio, rounded up to a multiple of the grid unit.
// All spacing tokens derive as multiples of that unit.
//
// Derivation chain:
//   body-size       = scale.size(body-step)
//   leading-ratio   = font.leading-ratio(body-size, measure: measure)
//   raw-baseline    = body-size · leading-ratio
//   baseline        = ceil(raw-baseline / grid-unit) · grid-unit
//   atomic-divisor  = baseline / grid-unit                    (derived; informational)
//
// Following Tim Brown's "Flexible Typesetting" framing, snap is opt-in per call rather
// than an enforced lattice — the grid is a derived spacing source, not a strict snap target.
// Use `snap(value)` for spacing alignment and `snap(value, multiple: baseline)` for strict
// baseline-snap on line-heights when you want it.

#import "scale.typ"
#import "font.typ"

#let make(
  scale: scale.presets.classical,
  font: font.presets.sans-text,
  measure: 65,
  body-step: 0,
  grid-unit: 4pt,
) = {
  let body-size = (scale.size)(body-step)
  let body-leading-ratio = (font.leading-ratio)(body-size, measure: measure)
  let raw-baseline = body-size * body-leading-ratio
  let n = calc.ceil(raw-baseline / grid-unit)
  let baseline = n * grid-unit

  let snap = (value, multiple: grid-unit) => {
    calc.round(value / multiple) * multiple
  }

  // Naming mirrors scale.typ: n/base/p, base = 1× unit.
  // Multipliers (0.5, 1, 2, 3, 4, 6, 8, 12) are practical spacing multipliers,
  // not a geometric progression. They match the Apple/Material/Carbon tradition.
  let spacing = (
    n1:   grid-unit * 0.5,
    base: grid-unit * 1,
    p1:   grid-unit * 2,
    p2:   grid-unit * 3,
    p3:   grid-unit * 4,
    p4:   grid-unit * 6,
    p5:   grid-unit * 8,
    p6:   grid-unit * 12,
  )

  (
    unit: grid-unit,
    baseline: baseline,
    spacing: spacing,
    snap: snap,
    params: (
      grid-unit: grid-unit,
      body-size: body-size,
      body-leading-ratio: body-leading-ratio,
      body-baseline: baseline,
      atomic-divisor: n,
    ),
  )
}
