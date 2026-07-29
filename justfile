# Typst libraries — development helpers.

# Default recipe: list available recipes.
default:
    @just --list

# Regenerate cascade/foundation.typ from the cascade-typeset renderer — the authoritative source of
# the typographic foundation (one spec, projected to Typst). Run after the spec changes.
# `cascade/foundation.typ` is GENERATED: never hand-edit it, edit the spec and regenerate.
#   just gen-foundation                       # assumes ../cascade-typeset
#   just gen-foundation ~/src/cascade-typeset # explicit path
gen-foundation cascade-typeset="../cascade-typeset":
    #!/usr/bin/env bash
    set -euo pipefail
    src="{{ cascade-typeset }}"
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    ( cd "$src" && cargo run -q -p cascade-cli -- build --target typst --out "$tmp/dist" )
    cp "$tmp/dist/cascade.typ" cascade/foundation.typ
    echo "Regenerated cascade/foundation.typ from $src"

# Symlink a library directory into Typst's local-package namespace so
# `#import "@local/<name>:<version>": ...` resolves to the working tree.
# Reads name + version from <dir>/typst.toml. Idempotent.
#   just link                  # link every subdir containing typst.toml
#   just link all              # same as above (explicit)
#   just link cascade          # link one
link dir="all":
    #!/usr/bin/env bash
    set -euo pipefail
    link_one() {
        local d="$1"
        read -r name version < <(awk -F'[ "=]+' '/^name *=/{n=$2} /^version *=/{v=$2} END{print n" "v}' "$d/typst.toml")
        local target="$HOME/.local/share/typst/packages/local/$name/$version"
        mkdir -p "$(dirname "$target")"
        ln -snf "$PWD/$d" "$target"
        echo "Linked $PWD/$d → $target"
    }
    if [[ "{{ dir }}" == "all" ]]; then
        shopt -s nullglob
        for f in */typst.toml; do
            link_one "$(dirname "$f")"
        done
    else
        link_one "{{ dir }}"
    fi

# Remove the symlink installed by `just link <dir>`. Safe if absent.
#   just unlink cascade
unlink dir:
    #!/usr/bin/env bash
    set -euo pipefail
    read -r name version < <(awk -F'[ "=]+' '/^name *=/{n=$2} /^version *=/{v=$2} END{print n" "v}' "{{ dir }}/typst.toml")
    target="$HOME/.local/share/typst/packages/local/$name/$version"
    if [[ -L "$target" ]]; then
        rm "$target"
        echo "Removed $target"
    else
        echo "No symlink at $target"
    fi
