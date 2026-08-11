# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A [Slidev](https://sli.dev) presentation — Markdown-driven slide decks that render as a Vue app. This is the **Bonham Lab** talk template: `slides.md` is the lab-branded starter (title, agenda, section divider, content, thank-you) meant to be cloned and filled in for talks/meetings. It also doubles as a reference for the three standard content-slide layouts (full image / full bullets / two-column), an animated bit-by-bit figure reveal, and citations with an auto-generated bibliography — copy patterns from the later slides rather than starting from scratch, then delete what you don't need.

Branding/theming/infra (fonts, colors, the logo, the footer, citation components, the UnoCSS/Vite glue) is **not** in this repo — it lives in [`@bonhamlab/slidev-template`](https://code.bonhamlab.bio/Templates/slidev-addon-bonhamlab), a Slidev addon package this repo depends on (see `package.json`, and `slides.md`'s `addons:` frontmatter). This repo only holds what's actually specific to a given talk. **If you're touching branding, colors, the logo, the footer component, or the citation components, you almost certainly want that other repo, not this one.** Clone it alongside this one if you need to make branding changes.

## Commands

- `npm run dev` — start the Slidev dev server on `slides.md` (opens browser at `localhost:3030`)
- `npm run build` — build `slides.md` to `dist/`
- `npm run export` — export the deck to PDF/PNG/PPTX (uses `playwright-chromium`)

There is no lint or test script — this repo has no linter/test suite configured.

Dependencies are installed with `bun install` (there's a `bun.lock`); `npm run <script>` still works regardless, since it just runs the `package.json` script. The `@bonhamlab/slidev-template` dependency is a **git dependency** (no npm registry — see its own `package.json`/`README.md`), pinned to a tag (`#vX.Y.Z`). To pick up a branding update, bump that tag in this repo's `package.json` and reinstall.

## Structure

- Slides are separated by `---`; each slide can carry its own YAML frontmatter block (layout, transition, class, etc.) directly above the separator. The very first frontmatter block doubles as both deck-wide headmatter *and* slide 1's own frontmatter — don't split it into two blocks, or slide 1 becomes blank.
- `global-bottom.vue` — a thin wrapper: imports this talk's `footer-info.ts` and renders `@bonhamlab/slidev-template`'s `<FooterBar>` with it. The actual footer markup/logic (and its load-bearing `z-50`, see that package's `CLAUDE.md`) lives in the package, not here — this file should stay a couple of lines.
- `footer-info.ts` — the presenter/date/year/venue placeholders shown in the footer and on the title slide. Edit this one file to update both.
- `public/fonts/`, `public/favicon.png` — **this repo's own copy** of the lab's fonts/favicon, not inherited from the addon package. Slidev's addon/theme mechanism doesn't reliably serve an addon's `public/` folder at a stable URL (see `@bonhamlab/slidev-template`'s `CLAUDE.md` for the empirical finding), so every talk repo keeps its own copy — re-copy these from the package repo (or another talk repo) if they're ever missing or out of date.
- `public/biblio/refs.bib` — this talk's bibliography (see "Citations & bibliography" below).

## Every root-level deck must live at the project root

Slidev resolves a deck's "root" (where it looks for `style.css`, `uno.config.ts`, `vite.config.ts`, `components/`, `public/`, etc.) as **the directory containing the entry file you pass to `slidev`** — not the shell's cwd, not the true repo root. If you run `slidev pages/some-deck.md`, that deck's root becomes `pages/`, and it silently loses every customization this repo (and the `@bonhamlab/slidev-template` addon it depends on) provides — fonts, colors, the citation-engine Vite fix, everything. **If you add another standalone deck to this repo, put it at the project root, not in a subdirectory.**

## Branding / theming

Lives entirely in [`@bonhamlab/slidev-template`](https://code.bonhamlab.bio/Templates/slidev-addon-bonhamlab) (`style.css`, `uno.config.ts`, `setup/shiki.ts`, the design-token CSS vars, dark-mode handling via `html.dark`). This repo just depends on it via `addons:` in `slides.md`'s frontmatter and `package.json`. See that package's own `CLAUDE.md` for the implementation details and gotchas (z-50 footer, `useSlideContext()` trap, citation Vite-shim rationale, `<ProseCite>` design, the public-asset-sharing limitation). To change lab-wide branding, edit that repo, tag a new version, and bump the dependency here — don't try to override it from this repo.

## Images

Two conventions, depending on how the image is referenced:

- **`images/<topic>/`** (project root, alongside `slides.md`) — for images referenced directly in slide markdown, e.g. `<img src="./images/example/foo.png">`. Vue's SFC compiler turns any `<img src="...">` in slide content into a real module import, so the path must be resolvable at build time relative to the *deck's own file* (`./` from a root-level deck) — a `/public`-style absolute path here fails (see below).
- **`public/images/<topic>/`** — only for images resolved at *runtime* via a plain string, not compiled as part of a Vue template: the `layout: image` frontmatter's `image:` key, or a `background:` frontmatter value. These use `/images/...` (leading slash) and are resolved against `BASE_URL` at runtime, not imported.

Mixing these up produces two different failure modes: a `<img src="/images/...">` (public, absolute) inside markdown body content fails to even *dev-serve* (Vite tries and fails to resolve it as a JS import); a relative `./images/...` path used from the wrong directory (e.g. after moving a deck file) fails only at `slidev build` time, not `slidev export`/`dev` — always re-run `npm run build` after moving image references, not just the dev server, to catch this.

`public/fonts/`, `public/favicon.png`, and `public/biblio/*.bib` are also public-folder assets, for the same "resolved at runtime, not imported" reason (CSS `url()`, frontmatter `favicon:` key, and `fetch()` calls respectively).

## Citations & bibliography

[`slidev-addon-citations`](https://github.com/aeudes/slidev-addon-citations) (citation-js/citeproc under the hood) provides BibTeX-based citations and an auto-generated bibliography — see `slides.md`'s "Figure & Citation Examples" section for working examples of every piece below.

- `slides.md`'s headmatter has `addons: [slidev-addon-citations, "@bonhamlab/slidev-template"]` and a `biblio:` config block (`filename: refs.bib`, `template: apa`). `.bib`/`.json` input files go in `public/biblio/`.
- **Cite with `<ProseCite bref="bibtexKey" />`** — component provided by `@bonhamlab/slidev-template`, not this repo — renders an automatic "Author et al. (Year)" narrative citation with no manual text and no hardcoded year/author to keep in sync. See that package's `CLAUDE.md` for how it works (it reuses the citations addon's own `citation_state` so the same reference also counts toward the auto-generated bibliography) — don't register a citation with both `<ProseCite>` and `<Cite>` for the same key.
- The addon's own `<Cite>` component still exists (used internally, and available if you want a different rendering) but its default marker/footnote is hidden deck-wide (`.biblio_ref`/`.biblio_tooltips`/`.biblio_foot`, styled in `@bonhamlab/slidev-template`'s `style.css`, plus `footnotes: none` in `biblio:` config) since `<ProseCite>` is the intended way to cite something on a slide.
- Render the full auto-generated bibliography with `<BiblioList />` or `layout: biblio` — it only lists what's actually cited in the deck unless `show_full_bib` is set.
- `.citation-caption` (defined in `@bonhamlab/slidev-template`'s `style.css`, used by `<ProseCite>`) is the shared class for bottom-of-slide attributions, including ones with no real citation (e.g. "Bonham Lab, unpublished" — just wrap the text in a plain `<div class="citation-caption">`).
- The citation-engine Vite fix (`@citation-js/core`'s static `node-fetch` import breaking client bundling) lives in `@bonhamlab/slidev-template`'s `vite.config.ts`/`shims/`, not this repo — if citation-related upgrades break again with an "does not provide an export named 'default'" or "has been externalized for browser compatibility" error, that's where to look.
- If `<ProseCite>`/`<Cite>` throws an `Icon '<xy>/<z>' not found` error right after adding/changing `addons:` in `slides.md`: that's a **stale dev server**, not a real bug — Slidev resolves `addons:` once at server boot and doesn't hot-reload it. Restart `npm run dev`.

## Footer & running header info

`global-bottom.vue` is a thin per-talk wrapper — it imports `footer-info.ts` and renders `@bonhamlab/slidev-template`'s `<FooterBar>` with it. Edit `footer-info.ts` (not `global-bottom.vue`) to change presenter/date/venue for a talk; the title slide reads the same file via its own `<script setup>` block (see `slides.md`) so there's one source of truth. The footer's actual markup, the `z-50` gotcha, and the `useSlideContext()` trap all live in the package — see its `CLAUDE.md` if you need to touch that.

## Table of contents

`<Toc minDepth="1" maxDepth="1" />` (used on the Agenda slide) shows only level-1 headings that aren't marked `hideInToc`. The per-layout default (`layout: section` → shown, everything else → hidden) is set by `@bonhamlab/slidev-template`'s `setup/preparser.ts` — this repo doesn't need its own. A slide only needs an explicit `hideInToc:` if it wants to *override* that default (e.g. a `layout: section` slide you don't want in the Toc for some reason).

## Deployment

Both `netlify.toml` and `vercel.json` are configured for static hosting of the built `dist/` output, with SPA-style catch-all rewrites to `index.html` (client-side routing between slides).
