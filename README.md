# typst-libs

Collection of [Typst](https://typst.app) libraries.

## Libraries

- **[cascade](cascade/)** — typography system: typographic scale, optical font profile, vertical rhythm, theme, and named callable components.

## Local install

```
just link cascade   # link one library
just link all       # link every subdir that contains a typst.toml
```

Symlinks the library into Typst's `@local` namespace so `#import "@local/cascade:0.1.0": ...` resolves to the working tree. Reads name + version from `<dir>/typst.toml`. `just unlink cascade` removes it.
