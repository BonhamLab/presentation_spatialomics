#import "@preview/touying:0.7.4": *
#import "assets/theme/bonham-theme.typ": *
#import "@preview/cetz:0.4.2"
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#import "assets/general/slides.typ": thank-you-slide, contact_info_slide

#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true)
)

// Thin on-theme border for photos/screenshots/plots sitting on the dark bg,
// same treatment as the site's card/portrait borders (see README).
#let framed(path, width: 100%) = box(
  stroke: 0.75pt + bonham-dark.border,
  radius: 3pt,
  clip: true,
  image(path, width: width),
)

// Bulleted content slide with a body text size (replaces repeating
// `#slide(align: top)[#set text(Npt) ...]`) — uses the theme's own
// `setting:` hook instead of a manual `#set` inside the body.
#let bullets(size: 19pt, body) = slide(align: top, setting: b => {
  set text(size)
  b
})[#body]

// Single centered framed image, full slide.
#let img-slide(path, width: 65%) = slide[#align(center)[#framed(path, width: width)]]

// Small mono/muted attribution or source-link line under a figure or code panel.
#let credit(body, size: 0.65em) = align(center)[#text(
  font: font-mono, size: size, fill: bonham-dark.text-muted,
)[#body]]

// Big arrow used between "before -> after" diagram pairs.
#let flow-arrow = text(size: 2.5em, fill: bonham-dark.primary)[→]

#show: codly-init.with()

#show: bonham-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  // Whole-deck dark "terminal" palette; focus-slide flips to the light
  // "paper" palette instead, as the deliberate change-of-register slide.
  bg: bonham-dark.bg,
  surface: bonham-dark.surface,
  border: bonham-dark.border,
  text-color: bonham-dark.text,
  text-muted: bonham-dark.text-muted,
  primary: bonham-dark.primary,
  accent: bonham-dark.accent,
  secondary: bonham-dark.secondary,
  dark-bg: bonham-light.bg,
  dark-surface: bonham-light.surface,
  dark-border: bonham-light.border,
  dark-text: bonham-light.text,
  dark-text-muted: bonham-light.text-muted,
  dark-primary: bonham-light.primary,
  dark-accent: bonham-light.accent,
  dark-secondary: bonham-light.secondary,
  // codly's per-page state must be restored before each slide is drawn,
  // hence configuring it via `preamble` rather than a top-level `#codly(...)`.
  config-common(preamble: {
    codly(
      languages: codly-languages + (
        julia: (name: "Julia", color: rgb("#9558B2")),
      ),
      fill: bonham-dark.surface,
      stroke: 0.75pt + bonham-dark.border,
      radius: 4pt,
      zebra-fill: none,
      number-format: none,
      lang-fill: lang => lang.color,
      lang-stroke: none,
    )
  }),
  config-info(
    title: [SpatialOmics.jl],
    subtitle: [Using the geo, image, and data stacks to analyze spatial transcriptomics data],
    author: [Kevin Bonham, PhD],
    date: datetime(year: 2026, month: 8, day: 13),
    institution: [JuliaCon 2026],
    logo: image("assets/general/lab-logo-banner.png", width: 8em),
  ),
)

#title-slide()

#outline-slide(title: [Agenda], level: 1, numbered: (false,))

= What is Transcriptomics?

== The "central dogma" of molecular biology

#img-slide("images/central-dogma.jpg", width: 65%)

== Cell behavior = genes + transcription + organization

#slide[
  #align(center)[
    #grid(
      columns: (auto, auto),
      column-gutter: 2em,
      align: horizon,
      grid(
        rows: (auto, auto),
        row-gutter: 1.2em,
        image("images/txn-genes.svg", height: 5.5em),
        image("images/txn-cells.svg", height: 5.5em),
      ),
      image("images/txn-tissues.svg", height: 11em),
    )
  ]
]

== Bulk RNA-seq assembles transcripts, divorced from cell context

#slide[
  #align(center)[
    #grid(
      columns: (auto, auto, auto),
      column-gutter: 2em,
      align: horizon,
      image("images/txn-tissues.svg", height: 11em),
      flow-arrow,
      image("images/txn-bulk.svg", height: 11em),
    )
  ]
]

== Single-cell RNA-seq measures expression in each cell individually

#slide[
  #align(center)[
    #grid(
      columns: (auto, auto, auto),
      column-gutter: 2em,
      align: horizon,
      image("images/txn-tissues.svg", height: 11em),
      flow-arrow,
      image("images/txn-sc.svg", height: 11em),
    )
  ]
]

== Spatial transcriptomics measures expression in tissue, at high resolution

#img-slide("images/cosmx.jpg", width: 65%)

= Spatial 'Omics Platforms and Their Limitations

== FISH --- the original spatial transcriptomics

#img-slide("images/fish-probes.jpg", width: 55%)

== Sequencing-based platforms (e.g. 10x Visium)

#img-slide("images/visumhdf.jpg", width: 65%)

== Probe-based platforms (e.g. 10x Xenium, NanoString CosMx)

#img-slide("images/cosmx.jpg", width: 65%)

== The SpatialData standard

#slide[
  #align(center)[#framed("images/spatialdata_elements.webp", width: 59%)]
  #v(0.5em)
  #align(left)[#image("images/spatialdata_horizontal.webp", height: 2.4em)]
  #v(0.4em)
  #credit[
    https://spatialdata.sciverse.org
  ]
]

== But... that's a lot of data

#slide(align: top)[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    align(center)[#framed("images/ln-images.png", width: 67%)],
    align(center)[#uncover("2-")[#framed("images/ln-fovs.png", width: 75%)]],
  )
]

= SpatialOmics.jl

== Design principles

#bullets(size: 19pt)[
  - SpatialData-compliant storage (`Zarr.jl`)
  #pause
  - Generic --- usable with every company's platform
  #pause
  - Entry and exit at every stage of analysis (JuliaData: `Arrow.jl`, `CSV.jl`, `DataFrames.jl`, etc.)
  #pause
  - Visualization-forward (`Makie.jl` recipes for every step)
  #pause
  - Reproducible, flexible, extensible
]

== JuliaGeo provides coordinate transformations and spatial analyses

#slide[
  #set text(13pt)
  #grid(
    columns: (3fr, 2fr),
    column-gutter: 1.5em,
    [
      ```julia
      using SpatialOmics
      import SpatialOmics as SO

      fov1 = SpatialPoints((; x_px = ..., y_px = ..., target = ...);
          x=:x_px, y=:y_px, gene=:target, coord_system="fov1_px")

      # scale px→µm, then place FOV at its stage offset in the
      # global frame
      fov1_to_global = SO.compose(
          SO.scaling(0.2, 0.2, "fov1_px", "fov1_um"),
          SO.translation(0.0, 0.0, "fov1_um", "global_um")
      )

      fov1_global = apply(fov1_to_global, fov1)
      ```
    ],
    align(center)[#framed("images/coords.png", width: 92%)],
  )
]

== Interactive visualization with JuliaImages, JuliaGeo, and Makie

#bullets(size: 19pt)[
  - Explore whole-slide imagery and transcript layers together in a single `Makie` scene
  - Draw polygon / rectangle ROIs directly on the image using `JuliaGeo` selection tools
  - Every view --- pan, zoom, ROI --- stays linked to the same underlying coordinate system
  #v(2em)
  #credit(size: 0.8em)[\[ live demo \]]
]

== JuliaData for analysis, tabular export

#bullets(size: 14pt)[
  #touying-raw(lang: "julia", ```
  julia> first(df_raw, 3)
  3×4 DataFrame
   Row │ x      y      z      gene
       │ Int64  Int64  Int64  String7
  ─────┼──────────────────────────────
     1 │  1776   2597      3  Ccl21a
     2 │  2141   2181      3  Lyve1
     3 │  2661   2653      9  Ccl21a
  // pause
  ds = SpatialDataset()
  ds["transcripts_raw"] = SpatialPoints(df_raw;
      gene = :gene,
      features = (; z = df_raw.z,),
      coord_system = "global_px"
  )
  ```)
]

== Julia abstractions for convenience and joy

#slide[
  #set text(14pt)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    align(horizon)[
      ```julia
      roi = shapes(ds, "overview_roi")

      sub = view(points(ds), roi) # or points(ds)[roi]
      ```
    ],
    align(center)[#framed("images/roi_view.png", width: 82%)],
  )
]

== Future directions

#bullets(size: 19pt)[
  - Integration with `SingleCellProjections.jl`
  #pause
  - More spatial-aware machine learning and data analysis (e.g. clustering, cell-type assignment)
  #pause
  - Lots and lots of tutorials and comparisons with existing tools (I've probably reinvented some wheels)
  #pause
  - Better interactive layers --- Makie selection can be slow, especially over SSH
]

#contact_info_slide

#thank-you-slide(slidesurl: "https://github.com/BonhamLab/presentation_spatialomics")
