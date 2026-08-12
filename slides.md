---
theme: seriph
title: The State of BioJulia
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

<img src="./images/central-dogma.jpg" class="max-h-[30vh] mx-auto" />

---

# qPCR measures small numbers of transcripts in bulk

<img src="./images/qPCR-1.png" class="max-h-[20vh] mx-auto" />
<img src="./images/qPCR-2.jpg" class="max-h-[20vh] mx-auto" />
---

# Cell behavior = genes + transcription + organization

<img src="./images/txn-genes.svg" class="max-h-[20vh] mx-auto" />
<img src="./images/txn-cells.svg" class="max-h-[20vh] mx-auto" />
<img src="./images/txn-tissues.svg" class="max-h-[20vh] mx-auto" />

---

# Bulk RNAseq assembles transcripts, divorced from cell context

<img src="./images/txn-tissues.svg" class="max-h-[20vh] mx-auto" />
<img src="./images/txn-bulk.svg" class="max-h-[20vh] mx-auto" />


# Single cell RNAseq can measure expression in each cell individually

<img src="./images/txn-tissues.svg" class="max-h-[20vh] mx-auto" />
<img src="./images/txn-sc.svg" class="max-h-[20vh] mx-auto" />
---

# Spatial transcriptomics measures expression in tissue section at high resolution

<img src="./images/txn-tissues.svg" class="max-h-[20vh] mx-auto" />

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
layout: section
---

# SpaitalOmics.jl

Wrapping packages across the Julia ecosystem

---

# Design principles

<v-clicks>

- SpatialData compliant storage (`Zarr.jl`)
- Generic, entry and exit at every stage of analysis (JuliaData, `Arrow.jl`, `CSV.jl`, `DataFrames.jl`, etc)
- Visualization-forward (`Makie.jl` recipes for every step)
- Reproducible, flexible, extensible

</v-clicks>

---

# JuliaGeo provides coordinate transformations and spatial analyses

---

# JuliaImages, JuliaGeo, and Makie for working with visualization

---

# JuliaData for analysis, tabular export

---

# Julia abstractions for convenience and joy

---

# Future directions


<v-clicks>

- Integration with `SingleCellProjections.jl`
- More spatial-aware machine learning and data analysis (eg clustering, cell-type assignment)
- Lots and lots of tutorials and comparisons with existing tools

</v-clicks>

---
layout: center
class: text-center
---

<LabLogo size="5rem" class="mx-auto mb-6" />

# Thank you

<div class="text-ink-muted">

Questions? Reach out — [bonhamlab.bio](https://bonhamlab.bio) · dev@bonham.ch

</div>

