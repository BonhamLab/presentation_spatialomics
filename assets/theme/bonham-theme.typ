// Bonham Lab Touying theme — "Paper & Terminal"
//
// Ports the visual identity of lab.bonham.ch (astro-site) to slides: IBM
// Plex type system, a warm "lab notebook" palette for normal content, and a
// dark "terminal" palette reserved for `focus-slide`. Colors mirror
// bonhamlab-web/branding/design-tokens.json — keep the two in sync if the
// site palette changes. See branding/design-system.md for the rationale.
//
// Requires IBM Plex Sans/Serif/Mono to be installed (Arch: `ttf-ibm-plex`).

#import "@preview/touying:0.7.4": *

// ---- Palette ----------------------------------------------------------

#let bonham-light = (
  bg: rgb("#FAF7F0"),
  surface: rgb("#F0EAD9"),
  border: rgb("#E2D9C2"),
  text: rgb("#1C1F26"),
  text-muted: rgb("#6E665A"),
  primary: rgb("#002E6D"),
  accent: rgb("#3E8EDE"),
  secondary: rgb("#5C7A45"),
)

#let bonham-dark = (
  bg: rgb("#181B22"),
  surface: rgb("#20242D"),
  border: rgb("#2C313B"),
  text: rgb("#E6E2D3"),
  text-muted: rgb("#97917F"),
  primary: rgb("#6F9CEB"),
  accent: rgb("#7E9CD8"),
  secondary: rgb("#8FB26A"),
)

#let font-heading = "IBM Plex Serif"
#let font-body = "IBM Plex Sans"
#let font-mono = "IBM Plex Mono"

// Style used to display a heading's body with no numbering/size override —
// gives full control over the eyebrow line's typography.
#let plain-heading-style = (setting: body => body, numbered: false, current-heading) => current-heading.body

// ---- Small content helpers ---------------------------------------------

/// Micro-mono badge for literal data labels (16S, WGS, ML, OSS, ...).
/// Mirrors the site's `.tag` component — always shown, not part of the
/// hint-level system.
#let tag(body) = box(
  outset: (y: 0.25em),
  inset: (x: 0.5em, y: 0.25em),
  radius: 2pt,
  stroke: 0.5pt + bonham-light.border,
  fill: bonham-light.surface,
  text(
    font: font-mono,
    size: 0.62em,
    weight: "medium",
    tracking: 0.05em,
    fill: bonham-light.text-muted,
    upper(body),
  ),
)

/// Mono "eyebrow" label (`// like this`), matching the site's hero eyebrow
/// and hint-system nav styling.
#let eyebrow(body, fill: bonham-light.text-muted) = text(
  font: font-mono,
  size: 0.62em,
  weight: "medium",
  tracking: 0.05em,
  fill: fill,
)[#"// "#upper(body)]

// ---- Slide ---------------------------------------------------------------

/// Default slide function: a "paper" page with a title/eyebrow header and a
/// footer bar, bordered like the site's header/footer chrome.
///
/// - title (content, auto): Slide title. Defaults to the current level-2 heading.
/// - config (dictionary): Slide configuration, via `config-xxx` helpers.
/// - repeat (int, string): Number of subslides. See Touying docs.
/// - setting (function): Extra set/show rules for the slide body.
/// - composer (function, array): Layout of the slide body.
#let slide(
  title: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }

  let header(self) = {
    set std.align(top)
    show: components.cell.with(
      fill: self.colors.neutral-lighter,
      inset: (x: 2.2em, top: 0.85em, bottom: 0.7em),
      stroke: (bottom: 0.6pt + self.colors.neutral-light),
    )
    set std.align(left + horizon)
    stack(
      dir: ttb,
      spacing: 0.3em,
      text(
        font: font-mono,
        size: 0.75em,
        weight: "medium",
        tracking: 0.05em,
        fill: self.colors.neutral,
      )[#"// "#upper(utils.display-current-heading(level: 1, depth: self.slide-level, style: plain-heading-style))],
      text(font: font-heading, size: 1.15em, weight: "bold", fill: self.colors.neutral-darkest,
        if title != auto {
          utils.fit-to-width(grow: false, 100%, title)
        } else {
          utils.display-current-heading(level: 2, depth: self.slide-level)
        }),
    )
  }

  let footer(self) = {
    set std.align(bottom)
    show: components.cell.with(
      fill: self.colors.neutral-lighter,
      inset: (x: 2.2em, y: 0.55em),
      stroke: (top: 0.6pt + self.colors.neutral-light),
    )
    set std.align(horizon)
    set text(size: 0.62em, fill: self.colors.neutral)
    components.left-and-right(
      text(font: font-body, utils.call-or-display(self, self.store.footer)),
      text(font: font-mono, context utils.slide-counter.display() + " / " + utils.last-slide-number),
    )
    if self.store.footer-progress {
      place(bottom, components.progress-bar(
        height: 1.5pt,
        self.colors.primary,
        self.colors.primary-light,
      ))
    }
  }

  let self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      header: header,
      footer: footer,
    ),
  )
  let new-setting = body => {
    show: std.align.with(self.store.align)
    set text(fill: self.colors.neutral-darkest)
    show: setting
    body
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: new-setting,
    composer: composer,
    ..bodies,
  )
})

// ---- Title slide -----------------------------------------------------

/// Title slide. Reads `config-info(...)` fields, plus an optional extra
/// `eyebrow` field (e.g. `title-slide(eyebrow: [computational microbiome
/// research])`), matching the site's hero eyebrow line.
#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest, header: none, footer: none),
    config,
  )
  let info = self.info + args.named()
  let logo = info.at("logo", default: none)
  let hero-eyebrow = info.at("eyebrow", default: none)

  let body = {
    set text(fill: self.colors.neutral-darkest)
    set std.align(horizon)
    if logo != none {
      place(top + right, utils.call-or-display(self, logo))
    }
    block(
      width: 100%,
      inset: (x: 2.6em),
      {
        if hero-eyebrow != none {
          eyebrow(hero-eyebrow, fill: self.colors.neutral)
          v(0.7em, weak: true)
        }
        text(font: font-heading, size: 2.1em, weight: "bold", fill: self.colors.neutral-darkest)[
          #info.title #text(fill: self.colors.primary-light)[\_]
        ]
        if info.subtitle != none {
          v(0.3em, weak: true)
          block(text(font: font-body, size: 1.05em, fill: self.colors.neutral, info.subtitle))
        }
        v(0.8em, weak: true)
        line(length: 40%, stroke: 1.2pt + self.colors.primary)
        v(0.8em, weak: true)
        set text(font: font-body, size: 0.75em, fill: self.colors.neutral)
        if info.author != none {
          block(spacing: 0.6em, info.author)
        }
        if info.date != none or info.institution != none {
          block(spacing: 0.6em, text(font: font-mono, size: 0.95em, tracking: 0.04em)[
            #if info.date != none [#utils.display-info-date(self)]
            #if info.date != none and info.institution != none [ · ]
            #if info.institution != none [#upper(info.institution)]
          ])
        }
        if info.contact != none {
          block(spacing: 0.6em, info.contact)
        }
        if extra != none {
          block(spacing: 0.6em, extra)
        }
      },
    )
  }
  touying-slide(self: self, body)
})

// ---- Outline slide -----------------------------------------------------

/// Outline slide, styled to match the section/slide typography.
#let outline-slide(
  config: (:),
  level: auto,
  title: [Outline],
  spacing: 2em,
  ..args,
) = slide(title: title, config: config, self => {
  let named-args = args.named()
  let indent = if not "indent" in named-args.keys() { (1em,) } else {
    named-args.remove("indent")
  }
  if type(indent) != array {
    indent = (indent,)
  }
  let vspace = if not "vspace" in named-args.keys() {
    (spacing, spacing / 3, spacing / 3, spacing / 3)
  } else { named-args.remove("vspace") }
  let numbered = if not "numbered" in named-args.keys() { (true,) } else {
    named-args.remove("numbered")
  }
  let numbering = if not "numbering" in named-args.keys() { ("1.",) } else {
    named-args.remove("numbering")
  }
  components.custom-progressive-outline(
    title: none,
    depth: if level != auto { level } else { self.slide-level },
    level: level,
    indent: indent,
    vspace: vspace,
    numbered: numbered,
    numbering: numbering,
    ..args.pos(),
    ..named-args,
  )
})

// ---- Section slide -----------------------------------------------------

/// Section slide, shown automatically for level-1 headings.
#let new-section-slide(
  config: (:),
  level: 1,
  numbered: true,
  body,
) = touying-slide-wrapper(self => {
  let slide-body = {
    set std.align(horizon)
    show: pad.with(20%)
    stack(
      dir: ttb,
      spacing: 0.9em,
      eyebrow(fill: self.colors.neutral)[section], // upper() turns this into "// SECTION"
      text(font: font-heading, size: 1.7em, weight: "bold", fill: self.colors.neutral-darkest,
        utils.display-current-heading(level: level, numbered: numbered, style: auto)),
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        components.progress-bar(
          height: 2pt,
          self.colors.primary,
          self.colors.primary-light,
        ),
      ),
    )
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(self: self, config: config, slide-body)
})

// ---- Focus slide (dark "terminal" mode) ---------------------------------

/// Focus slide. Flips to the site's dark/terminal palette to signal a change
/// of register — the one place in a deck that intentionally leaves "paper"
/// for "terminal". Mono type throughout carries that shift.
#let focus-slide(
  config: (:),
  align: horizon + center,
  body,
) = touying-slide-wrapper(self => {
  let dc = self.store.dark-colors
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: dc.bg, margin: 2em, header: none, footer: none),
  )
  set text(fill: dc.text, font: font-mono, size: 1.5em)
  touying-slide(self: self, config: config, std.align(align, body))
})

// ---- Theme entry point ---------------------------------------------------

/// Bonham Lab Touying theme.
///
/// Example:
/// ```typst
/// #show: bonham-theme.with(
///   aspect-ratio: "16-9",
///   footer: self => self.info.institution,
///   config-info(title: [Title], author: [Author]),
/// )
/// ```
///
/// - aspect-ratio (string): Slide aspect ratio. Default `"16-9"`.
/// - align (alignment): Default slide-body alignment. Default `horizon`.
/// - footer (content, function): Left-hand footer content (e.g. institution name).
/// - footer-progress (boolean): Show the thin primary/accent progress bar. Default `true`.
/// - bg, surface, border, text-color, text-muted, primary, accent, secondary (color):
///   Light "paper" palette overrides. Default to the Bonham Lab tokens.
/// - dark-bg, dark-surface, dark-border, dark-text, dark-text-muted,
///   dark-primary, dark-accent, dark-secondary (color): Dark "terminal"
///   palette overrides, used only by `focus-slide`.
#let bonham-theme(
  aspect-ratio: "16-9",
  align: horizon,
  footer: none,
  footer-progress: true,
  bg: bonham-light.bg,
  surface: bonham-light.surface,
  border: bonham-light.border,
  text-color: bonham-light.text,
  text-muted: bonham-light.text-muted,
  primary: bonham-light.primary,
  accent: bonham-light.accent,
  secondary: bonham-light.secondary,
  dark-bg: bonham-dark.bg,
  dark-surface: bonham-dark.surface,
  dark-border: bonham-dark.border,
  dark-text: bonham-dark.text,
  dark-text-muted: bonham-dark.text-muted,
  dark-primary: bonham-dark.primary,
  dark-accent: bonham-dark.accent,
  dark-secondary: bonham-dark.secondary,
  ..args,
  body,
) = {
  set text(font: font-body, size: 20pt, fill: text-color)
  show heading: set text(font: font-heading)
  show raw: set text(font: font-mono)

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      header-ascent: 0%,
      footer-descent: 0%,
      margin: (top: 4.6em, bottom: 2.3em, x: 2.2em),
      fill: bg,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      neutral-lightest: bg,
      neutral-lighter: surface,
      neutral-light: border,
      neutral: text-muted,
      neutral-dark: text-color,
      neutral-darkest: text-color,
      primary: primary,
      primary-light: accent,
      secondary: secondary,
    ),
    config-store(
      align: align,
      footer: footer,
      footer-progress: footer-progress,
      dark-colors: (
        bg: dark-bg,
        surface: dark-surface,
        border: dark-border,
        text: dark-text,
        text-muted: dark-text-muted,
        primary: dark-primary,
        accent: dark-accent,
        secondary: dark-secondary,
      ),
    ),
    ..args,
  )

  body
}
