# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A [Typst](https://typst.app) + [Touying](https://touying-typ.github.io/) presentation —
"SpatialOmics.jl: Using the geo, image, and data stacks to analyze spatial transcriptomics data,"
a talk for JuliaCon 2026. `main.typ` is the entire deck (title, agenda, sections, content slides,
thank-you). Previously this repo was a Slidev deck; it was rewritten to Typst to match
[`template_presentation`](https://github.com/BonhamLab/template_presentation), the lab's Typst talk
template — see that repo for the theme's design rationale.

## Structure

- `main.typ` — the whole deck. Slides come from Touying's heading-driven auto-slicing: a `=`
  heading starts a new section slide (via `bonham-theme`'s `new-section-slide`), a `==` heading
  starts a new content slide, and content between headings becomes that slide's body. Most content
  slides here wrap their body in an explicit `#slide(...)[...]` anyway (for `align:`, `#pause`
  reveals, or multi-column `#grid`s), with the heading above providing the title.
- `assets/theme/bonham-theme.typ` — **a local copy** of the lab's Touying theme, not a submodule.
  If lab-wide branding changes in `template_presentation`, re-copy this file from there; don't
  diverge it for this talk specifically (talk-specific tweaks belong in `main.typ`, e.g. the
  `framed`/`code-card` helpers defined at its top).
- `assets/general/` — git submodule ([`assets_lab_general`](https://github.com/BonhamLab/assets_lab_general))
  providing `contact_info_slide`, `thank-you-slide`, the lab logo, and headshots used on the
  closing slides. Run `git submodule update --init --recursive` after cloning.
- `images/` — this talk's figures, referenced directly as `image("images/foo.png")` from `main.typ`
  (Typst resolves paths relative to `--root`, which CI and the commands below set to the repo root).

## Dark mode

The deck runs the whole talk in `bonham-theme`'s dark "terminal" palette (not just the default
light "paper" one) — `main.typ`'s `bonham-theme.with(...)` call passes `bonham-dark.*` into the
theme's light-slot arguments (`bg`, `surface`, `text-color`, ...) and `bonham-light.*` into its
dark-slot arguments (`dark-bg`, `dark-surface`, ...). This is a swap done entirely from `main.typ`,
not a change to `bonham-theme.typ` itself — the theme has no built-in whole-deck dark toggle (see
its own repo's README). One side effect: `#focus-slide[..]` renders in the *light* palette instead
of dark, since it always pulls from the "dark-slot" arguments — that's fine, it's still the one
deliberate change-of-register slide, just inverted to match this deck's default (currently unused
in this deck, but available).

## Images against a dark background

Plots/screenshots that carry their own (usually white) background aren't re-exported — they're
wrapped in the `framed()` helper defined near the top of `main.typ` (thin `bonham-dark.border`
box, clipped, small radius) so they read as a card instead of a bare white rectangle. SVG diagrams
that are already transparent/dark-compatible (the `txn-*.svg` cell/tissue figures) are used
unwrapped. Image sizes (`width:`/`height:`) are tuned per context, not defaulted — full
single-column figures run 55–75%, figures sharing a column with text/code 75–92% of that column.
When adding a new image slide, check it visually (compile + render a PNG) rather than guessing a
size.

## Boilerplate helpers

Three helpers near the top of `main.typ` collapse the patterns that used to repeat across most
slides:

- `bullets(size: 19pt)[...]` — a top-aligned content slide with its body text size set via the
  theme's own `slide(..., setting: ...)` hook. Use for any slide whose body is just bullets (or
  bullets plus a small figure), replacing `#slide(align: top)[#set text(Npt) ...]`.
- `img-slide(path, width: 65%)` — a single centered `framed()` image, full slide. Only for slides
  that are *just* the image — anything with a caption, second image, or grid layout stays as an
  explicit `#slide[...]`.
- `credit(body, size: 0.65em)` — the small centered mono/muted attribution or source-link line
  under a figure or code panel.

Slides with a real 2-column `#grid`, paired `#uncover("N-")` reveals, or mixed image+code
composition keep their explicit `#slide(...)[#grid(...)]` form — `credit()` still applies to their
caption line, but `bullets()`/`img-slide()` don't fit that shape.

## Code blocks (codly)

Code is styled by [codly](https://typst.app/universe/package/codly), configured once via
`config-common(preamble: {codly(...)})` in the `bonham-theme.with(...)` call (codly's per-page
state has to be restored before each slide is drawn, which `preamble` handles — see
[touying's codly integration doc](https://touying-typ.github.io/docs/integration/codly)). Fenced
` ```julia ` blocks need no manual wrapper — codly draws the card, border, and language badge
itself. `codly-languages` doesn't ship a Julia entry, so one is registered by hand in the
`codly(...)` call with Julia's brand purple; the `lang-fill`/`lang-stroke` overrides there are
needed because codly's default badge fill (`color.lighten(80%)`) is nearly illegible against this
theme's light-on-dark text.

The "JuliaData for analysis, tabular export" slide's snippet evolves in one stage (a data preview,
then constructing the dataset from it) — that's a single `#touying-raw(lang: "julia",
```...```)` block with a `// pause` comment marker between the stages, instead of stacking two
separate raw blocks with `#pause` between them — `#pause` doesn't work inside a plain `raw` block,
which is what `touying-raw` is for.

## No embedded video

The original Slidev deck autoplayed `images/roi_select.mp4` (a screen recording) on the
"interactive visualization" slide. Typst/PDF can't embed video playback, and the recording itself
is a screen-capture of an editor/REPL (not a clean demo shot), so that slide was rewritten as a
bullet summary with a `[ live demo ]` cue instead of a static frame grab. `images/roi_select.mp4`
and `images/roi_view.png` (a clean Makie screenshot of the same ROI feature) still exist;
`roi_view.png` is used later on the "Julia abstractions for convenience and joy" slide.

## Reveals

Click-by-click reveals (the Slidev deck's `v-clicks`) are done with Touying's `#pause` between list
items, and `#uncover("N-")[...]` for content that should appear after a specific pause (see the
"But... that's a lot of data" slide).

## Commands

- `typst compile --root . main.typ presentation.pdf` — build the PDF
- `typst watch --root . main.typ presentation.pdf` — rebuild on save while editing
- `typst compile --root . --format png --pages 1 main.typ title-slide.png` — regenerate the title-slide preview

Requires IBM Plex Sans/Serif/Mono installed system-wide (Arch: `pacman -S ttf-ibm-plex`).

## Deployment

`.github/workflows/preview.yml` builds a PDF + title-slide PNG on every push/PR and comments the
artifact link on PRs. `.github/workflows/release.yml` does the same plus a full source archive,
triggered by creating a GitHub release.
