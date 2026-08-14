# SpatialOmics.jl

Using the geo, image, and data stacks to analyze spatial transcriptomics data

JuliaCon 2026 · Mainz, Germany

A [Typst](https://typst.app) + [Touying](https://touying-typ.github.io/) presentation, built on the
[Bonham Lab talk template](https://github.com/BonhamLab/template_presentation).

## Usage

- Instantiate the `assets/general` submodule: `git submodule update --init --recursive`
- Compile: `typst compile --root . main.typ presentation.pdf`
- Watch while editing: `typst watch --root . main.typ presentation.pdf`

**Fonts:** requires IBM Plex Sans/Serif/Mono installed system-wide (Arch: `pacman -S ttf-ibm-plex`).
CI already handles this — see `.github/workflows/*.yml`.

## Theme

`assets/theme/bonham-theme.typ` is the lab's Touying theme (see the template repo for the full
rationale). This deck runs it in its dark "terminal" palette for the whole talk — `main.typ` swaps
the theme's light/dark color arguments so `#focus-slide[..]` becomes the one deliberate light
"paper" moment instead of the reverse.

## Images

`images/` holds this talk's figures, referenced directly from `main.typ` (e.g. `image("images/foo.png")`).

## Deployment

To trigger the release GitHub Action (compiles the PDF + title-slide preview and attaches them to
a GitHub release), create a release.
