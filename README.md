# typst-libs

Collection of [Typst](https://typst.app) libraries.

## Libraries

- **[cascade](cascade/)** — typography system: named callable components + `page`/`markup` show rules and a light/dark theme, composed on the **cascade foundation** (`cascade/foundation.typ`) — the typographic scale, optical profile, and vertical rhythm projected from the cascade-typeset spec. Regenerate the foundation with `just gen-foundation`; never edit it by hand.

## Local install

```
just link cascade   # link one library
just link all       # link every subdir that contains a typst.toml
```

Symlinks the library into Typst's `@local` namespace so `#import "@local/cascade:0.1.0": ...` resolves to the working tree. Reads name + version from `<dir>/typst.toml`. `just unlink cascade` removes it.
