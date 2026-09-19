# typst-libs

Collection of [Typst](https://typst.app) libraries.

- **[Press](press/)** — functional document composition, with a convention pairing
  content files and their presentation. Formatting is supplied as a configurable dependency.

## Local install

```sh
just link press
```

Links `press/` into Typst's local package directory so
`#import "@local/press:0.1.0": document` uses the working tree.
`just link all` links every package in this repository; `just unlink press`
removes the link. These commands change local package links, not Git state.
The flake also provides a Home Manager module for live checkout links.

Cascade is a separate project. Press's optional adapter accepts an imported
Cascade Typst export; it does not install or pin Cascade.

## Checks

With Typst and Python 3 available, `just check` runs the generic contract checks,
scaffold and base example. To also check Cascade configuration, components and
the Cascade example, supply an exported `cascade.typ`:

```sh
just check ../cascade-typography/dist/typst/cascade.typ
```

Checks use an isolated temporary package directory and do not change installed
packages or overwrite example PDFs. See [Press's documentation](press/README.md)
for usage, configuration boundaries and migration from the previous API.
