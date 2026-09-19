#!/usr/bin/env python3
"""Compile behavior checks in an isolated local package root; never relink packages."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
IMPORT = '#import "@local/press:0.1.0": document, cascade-formatter\n'
IDENTITY = '(page: b => b, markup: b => b)'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cascade", default="", help="generated cascade.typ to include in integration checks")
    args = parser.parse_args()
    if not shutil.which("typst"):
        parser.error("typst must be on PATH")
    cascade = Path(args.cascade).resolve() if args.cascade else None
    if cascade is not None and not cascade.is_file():
        parser.error(f"Cascade export does not exist: {cascade}")

    with tempfile.TemporaryDirectory(prefix="press-check-") as directory:
        work = Path(directory)
        packages = work / "packages"
        package = packages / "local" / "press" / "0.1.0"
        package.parent.mkdir(parents=True)
        shutil.copytree(ROOT / "press", package)
        # All imports, including example @local imports, use this candidate tree.
        # Package cache is isolated too; no installation or global links are changed.
        flags = ["--package-path", str(packages), "--package-cache-path", str(work / "cache")]
        count = 0

        def invoke(name, source, error=None, query=False, root=None):
            nonlocal count
            path = work / (name + ".typ")
            path.write_text(IMPORT + source)
            cmd = ["typst", "query" if query else "compile", *flags]
            if root is not None:
                cmd += ["--root", str(root)]
            cmd += [str(path)]
            cmd += ["metadata", "--field", "value"] if query else [str(work / (name + ".pdf"))]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
            if error:
                assert result.returncode != 0 and error in result.stderr, (name, result.stdout, result.stderr)
            else:
                assert result.returncode == 0, (name, result.stdout, result.stderr)
                assert not result.stderr, (name, result.stderr)
            count += 1
            print(f"PASS {name}")
            return json.loads(result.stdout) if query and not error else None

        def example(relative):
            nonlocal count
            result = subprocess.run(
                ["typst", "compile", *flags, "--root", str(package),
                 str(package / relative), str(work / "example.pdf")],
                capture_output=True, text=True, timeout=60,
            )
            assert result.returncode == 0 and not result.stderr, (relative, result.stderr)
            count += 1
            print(f"PASS {relative}")

        values = invoke("composition-and-scope", r'''#let make(config) = (
  page: body => { set page(paper: "a5"); set text(size: config.base); body },
  markup: body => { set text(size: config.base + 2pt); body },
  marker: config.marker,
  label: body => text(size: config.base, body),
)
#let running(l, p) = (l.label)(context {
  assert(text.size == 13pt)
  assert(l.marker == "shared")
  assert(counter(p).get().first() >= 1)
  [Page #counter(p).display()]
})
#document(formatter: make, config: (base: 13pt, marker: "shared"),
  compose: l => {
    assert(l.marker == "shared")
    context { assert(text.size == 15pt); assert(page.width == 148mm) }
    metadata("first")
    [First]
    pagebreak()
    metadata("second")
    [Second]
  }, header: running, footer: running)
''', query=True)
        assert values == ["first", "second"], values

        invoke("empty-and-nested-composition", r'''#let section(l) = [Nested]
#let group(l) = { section(l); section(l) }
#document(formatter: config => (page: b => b, markup: b => b), compose: group)
#document(formatter: config => (page: b => b, markup: b => b), compose: l => [])
''')
        for field in ("header", "footer"):
            source = f'''#let make(config) = (
  page: b => {{ set page({field}: context panic("original-{field}")); b }},
  markup: b => b,
)
#document(formatter: make, compose: l => [Body]{{override}})
'''
            invoke(f"preserve-{field}", source.replace("{override}", ""), error=f"original-{field}")
            invoke(f"replace-{field}", source.replace("{override}", f", {field}: (l, p) => [Replacement]"))
            invoke(f"execute-{field}",
                   f'#document(formatter: c => {IDENTITY}, compose: l => [Body], '
                   f'{field}: (l, p) => panic("callback-{field}"))',
                   error=f"callback-{field}")

        bad = [
            ("missing-factory", "compose: l => []", "formatter must be a function"),
            ("invalid-config", f"formatter: c => {IDENTITY}, config: 1, compose: l => []", "config must be a dictionary"),
            ("missing-compose", f"formatter: c => {IDENTITY}", "compose must be a function"),
            ("invalid-result", "formatter: c => [], compose: l => []", "formatter must return a dictionary"),
            ("missing-page", "formatter: c => (markup: b => b), compose: l => []", "formatter must provide a page function"),
            ("invalid-markup", "formatter: c => (page: b => b, markup: 1), compose: l => []", "formatter must provide a markup function"),
            ("invalid-header", f"formatter: c => {IDENTITY}, compose: l => [], header: 1", "header must be none or a function"),
            ("invalid-footer", f"formatter: c => {IDENTITY}, compose: l => [], footer: 1", "footer must be none or a function"),
        ]
        for name, arguments, error in bad:
            invoke(name, "#document(" + arguments + ")", error="press: " + error)
        invoke("invalid-cascade-source", "#cascade-formatter((:), (:))", error="Cascade source must be an imported module")
        (work / "incomplete.typ").write_text("#let cascade(body) = body")
        invoke("incomplete-cascade-export", '#import "incomplete.typ" as c\n#cascade-formatter(c, (:))', error="Cascade export must provide text-4")

        example("template/main.typ")
        example("examples/base/main.typ")
        if cascade is not None:
            target = packages / "local" / "cascade" / "2.0.0"
            target.mkdir(parents=True)
            shutil.copyfile(cascade, target / "cascade.typ")
            (target / "typst.toml").write_text('[package]\nname = "cascade"\nversion = "2.0.0"\nentrypoint = "cascade.typ"\n')
            values = invoke("cascade-config-components-and-running-matter", r'''#import "@local/cascade:2.0.0" as c
#let run(base) = document(
  formatter: cascade-formatter.with(c),
  config: (base: base, page: (paper: "a5", margin: 15mm)),
  compose: l => {
    context { assert(text.size == base); assert(page.width == 148mm) }
    (l.text-3)[#context metadata(text.size) Body component]
    (l.span)(size: 19pt)[#context { assert(calc.abs(text.size - 19pt) < 0.001pt); metadata("override") } Override]
    (l.heading-1)[Heading]
    (l.lead)[Lead]
    (l.rule)()
    (l.figure)(rect(width: 10pt, height: 10pt), [Caption])
    pagebreak()
    [Second page]
  },
  header: (l, p) => (l.text-3)[#context { assert(text.size == base); counter(p).display() }],
  footer: (l, p) => (l.text-3)[#context { assert(text.size == base); counter(p).display() }],
)
#run(16pt)
#pagebreak()
#run(24pt)
''', query=True)
            assert values == ["16pt", "override", "24pt", "override"], values
            example("examples/cascade/main.typ")
        else:
            print("SKIP Cascade integration: supply --cascade /path/to/cascade.typ")
        print(f"{count} checks passed")


if __name__ == "__main__":
    main()
