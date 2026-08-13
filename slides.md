---
theme: seriph
title: SpatialOmics.jl
info: |
  ## SpatialOmics.jl - Using the geo, image, and data stacks to analyze spatial transcriptomics data
  JuliaCon 2026
colorSchema: auto
favicon: /favicon.png
fonts:
  sans: 'IBM Plex Sans'
  serif: 'IBM Plex Serif'
  mono: 'IBM Plex Mono'
  provider: none
themeConfig:
  primary: '#002E6D'
duration: 20min
layout: intro
class: text-center
addons:
  - "@bonhamlab/slidev-template"
  - slidev-addon-citations
biblio:
  filename: refs.bib
  template: apa
  footnotes: none
---

<!-- Title slide: swap logo size, talk title, presenter, and date for your own talk.
Presenter/date/venue text comes from footer-info.ts (shared with global-bottom.vue's
running footer) — edit that one file to update both. -->

<script setup lang="ts">
import { footerInfo } from './footer-info'
</script>

<LabLogo size="7rem" class="mx-auto mb-8" />

# SpatialOmics.jl

## Using the geo, image, and data stacks to analyze spatial transcriptomics data

<div class="mt-8 font-mono text-sm text-ink-muted">
{{ footerInfo.author }} · {{ footerInfo.date }}
</div>

---

# Agenda

<Toc minDepth="1" maxDepth="1" />

---

layout: section
---

# Background - What is transcriptomics?

---

# The "central dogma" of molecular biology

<img src="./images/central-dogma.jpg" class="max-h-[40vh] mx-auto" />

<!-- --- -->
<!---->
<!-- # qPCR measures small numbers of transcripts in bulk -->
<!---->
<!-- <div class="flex justify-center items-center gap-4"> -->
<!-- <img src="./images/qPCR-1.png" class="max-h-[20vh] bg-white" /> -->
<!-- <v-click> -->
<!-- <img src="./images/qPCR-2.jpg" class="max-h-[20vh]" /> -->
<!-- </v-click> -->
<!-- </div> -->
---

# Cell behavior = genes + transcription + organization

<div class="flex justify-center items-center gap-4">
<div class="flex flex-col gap-4">
<img src="./images/txn-genes.svg" class="max-h-[10vh]" />
<img src="./images/txn-cells.svg" class="max-h-[10vh]" />
</div>
<img src="./images/txn-tissues.svg" class="max-h-[20vh]" />
</div>

---

# Bulk RNAseq assembles transcripts, divorced from cell context

<div class="flex justify-center items-center gap-4">
<img src="./images/txn-tissues.svg" class="max-h-[20vh]" />
<div class="i-carbon-arrow-right text-primary text-6xl" />
<img src="./images/txn-bulk.svg" class="max-h-[20vh]" />
</div>

---

# Single cell RNAseq can measure expression in each cell individually

<div class="flex justify-center items-center gap-4">
<img src="./images/txn-tissues.svg" class="max-h-[20vh]" />
<div class="i-carbon-arrow-right text-primary text-6xl" />
<img src="./images/txn-sc.svg" class="max-h-[20vh] mx-auto" />
</div>

---

# Spatial transcriptomics measures expression in tissue section at high resolution

<img src="./images/cosmx.jpg" class="max-h-[20vh] mx-auto" />

---

layout: section
---

# Spatial 'Omics platforms and their limitations

---

# FISH - the original spatial transcriptomics

<img src="./images/fish-probes.jpg" class="max-h-[20vh] mx-auto" />

---

# Sequencing-based platforms (eg 10x Visium)

<img src="./images/visumhdf.jpg" class="max-h-[20vh] mx-auto" />
---

# Probe-based (eg 10x Xenium, Nanostring CosMx)

<img src="./images/cosmx.jpg" class="max-h-[20vh] mx-auto" />

---

# SpatialData Standard

<img src="./images/spatialdata_elements.webp" class="max-h-[20vh] mx-auto" />
<img src="./images/spatialdata_horizontal.webp" class="max-h-[5vh]" />

<div class="citation-caption">https://spatialdata.sciverse.org</div>

---

# But... that's a lot of data

<div class="flex items-start gap-8">

<img src="./images/ln-images.png" class="max-h-[25vh]" />
<v-click>
<img src="./images/ln-fovs.png" class="max-h-[25vh]" />
</v-click>

</div>
---
layout: section
---

# SpaitalOmics.jl

Wrapping packages across the Julia ecosystem

---

# Design principles

<v-clicks>

- SpatialData compliant storage (`Zarr.jl`)
- Generic, usable with every company's platform
- Entry and exit at every stage of analysis (JuliaData, `Arrow.jl`, `CSV.jl`, `DataFrames.jl`, etc)
- Visualization-forward (`Makie.jl` recipes for every step)
- Reproducible, flexible, extensible

</v-clicks>

---

# JuliaGeo provides coordinate transformations and spatial analyses

<div class="flex items-start gap-8">

```julia {|4-5|9|10|13}
using SpatialOmics
import SpatialOmics as SO

fov1 = SpatialPoints((; x_px = ..., y_px = ..., target = ...);
    x=:x_px, y=:y_px, gene=:target, coord_system="fov1_px")

# scale px→µm, then place FOV at its stage offset in global frame
fov1_to_global = SO.compose(
    SO.scaling(0.2, 0.2, "fov1_px", "fov1_um"),
    SO.translation(0.0, 0.0, "fov1_um", "global_um")
)

fov1_global = apply(fov1_to_global, fov1)
```

<img src="./images/coords.png" class="max-h-[21vh]" />

</div>

---

# JuliaImages, JuliaGeo, and Makie for working with visualization

<video src="./images/roi_select.mp4" class="max-h-[24vh] mx-auto" controls autoplay loop muted />

---

# JuliaData for analysis, tabular export

```julia
julia> first(df_raw, 3)
3×4 DataFrame
 Row │ x      y      z      gene
     │ Int64  Int64  Int64  String7
─────┼──────────────────────────────
   1 │  1776   2597      3  Ccl21a
   2 │  2141   2181      3  Lyve1
   3 │  2661   2653      9  Ccl21a
```

<v-click>

```julia
ds = SpatialDataset()
ds["transcripts_raw"] = SpatialPoints(df_raw;
    gene = :gene,
    features = (; z = df_raw.z,),
    coord_system="global_px"
)
```

</v-click>

---

# Julia abstractions for convenience and joy

<div class="flex justify-center items-center gap-4">

```julia
roi = shapes(ds, "overview_roi")

sub = view(points(ds), roi) # or points(ds)[roi]
```

<img src="./images/roi_view.png" class="max-h-[25vh] mx-auto" />
</div>

---

# Future directions

<v-clicks>

- Integration with `SingleCellProjections.jl`
- More spatial-aware machine learning and data analysis (eg clustering, cell-type assignment)
- Lots and lots of tutorials and comparisons with existing tools (I've probably re-invented some wheels)
- Better interactive layers (Makie selection can be slow, esp over ssh)

</v-clicks>

---

layout: center
class: text-center
---

<LabLogo size="5rem" class="mx-auto mb-6" />

# Thank you

<div class="text-ink-muted">

Questions? Reach out — [bonhamlab.bio](https://bonhamlab.bio) · <dev@bonham.ch>

</div>
