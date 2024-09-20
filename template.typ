#import "util.typ": locale-date-format

#let logo = image(
  "./FIDIT-logo.png",
  height: 15.15mm
)

#let title-page = (
  study,
  kind,
  title,
  author,
  attributions,
  logo,
  location,
  locale: "hr"
) => [
#set text(size: 16pt)
#set align(center)

#grid(
  rows: (auto, 1fr, 1fr, auto),
  columns: 1fr,

  stack(
    spacing: 20pt,
    logo,
    study
  ),

  align(bottom, stack(
    spacing: 20pt,
    text(size: 18pt, author),
    text(size: 28pt, title),
    text(size: 18pt, kind)
  )),

  align(horizon+left, attributions),

  align(center)[
    #location, #locale-date-format(locale, datetime.today())
  ]
)]

#let footer-format = (loc) => {
  let doc-start = locate(<first-page>).position()
  if loc.page() < doc-start.page {
    return
  }
  align(right, text(
    weight: "regular",
    size: 12pt,
    counter(page).display()
  ))
}

#let _formula_counter = counter("formula")
#let _formula_names = state("formula-names", (:))
#let formula(body, caption: none, ..args) = figure(
  body,
  kind: "formula",
  supplement: none,
  caption: _formula_counter.display(i => {
    let display = "(" + str(i+1) + ")"
    _formula_names.update(it => {
      it.insert(display, caption)
      it
    })
    [
      #display
    ]
  }),
  ..args
)

#let config = (
  study: [Sveučilišni prijediplomski studij Informatika],
  kind,
  title,
  author,
  attributions: [],
  logo: logo,
  location: [Rijeka],
  locale: "hr",
  inserts: [],
) => {
  return doc => {
    set page(
      paper: "a4",
      margin: 2.5cm,
    )
    set text(lang: locale)

    title-page(
      study,
      kind,
      title,
      author,
      attributions,
      logo,
      location,
      locale: locale,
    )

    set page(
      numbering: "1",
      footer: locate(footer-format)
    )
    
    set text(
      font: ("Times New Roman", "Liberation Serif"),
      size: 12pt,
    )

    set par(
      justify: true,
      leading: 0.15em + 1em * 0.25, // line height 1.15em - 0.15em + descent
    )
    show par: set block(
      spacing: 6pt + 1em * 0.25
    )
    
    set heading(numbering: "1.1.")
    show heading: set text(
      font: ("Arial", "Liberation Sans"),
    )
    show heading.where(level: 1): set text(size: 16pt)
    show heading.where(level: 1): it => {
      block(
        above: 0pt,
        below: 12pt,
        it
      )
    }
    show heading.where(level: 2): set text(size: 14pt)
    show heading.where(level: 2): it => block(
      above: 18pt,
      below: 6pt,
      it
    )
    show heading.where(level: 3): set text(size: 12pt)
    show heading.where(level: 3): it => block(
      above: 6pt,
      below: 6pt,
      it
    )
    show heading.where(level: 4): set text(size: 12pt)
    show heading.where(level: 4): it => block(
      above: 6pt,
      below: 6pt,
      it
    )
    
    show raw.line: set text(
      font: ("Consolas", "Courier New", "Liberation Mono"),
      size: 9pt,
    )

    set list(
      marker: "-",
    )

    show figure: set text(
      font: ("Times New Roman", "Liberation Serif"),
      size: 10pt,
    )
    show figure.where(kind: table): {
      set figure(supplement: "Tablica")
      set figure.caption(position: top)
    }
    show figure.where(kind: image): set figure(supplement: "Slika")
    show figure.where(kind: raw): set figure(supplement: "Kȏd")

    // Uključuje ascent i descent u veličinu znaka za računanje razmaka
    // Ascent i descent ovise o fontu, ali obično su 50% ukupne visine glifa
    show heading: set block(inset: (y: 0.25em))
    show raw: set par(
      leading: 0.5em,
    )

    show ref: it => {
      let el = it.element
      if el != none and el.func() == figure and el.at("kind", default: none) == "formula" {
        let location = el.location()
        let value = _formula_counter.at(location).at(0) + 1
        let dpy = "(" + str(value) + ")"
        let name = _formula_names.get().at(dpy, default: none)
        link(el.location())[#name #dpy]
      } else {
        it
      }
    }

    inserts

    outline(
      title: "SADRŽAJ",
      indent: auto
    )

    pagebreak()
    counter(page).update(1)

    [#metadata((tag: "location-marker")) <first-page>]

    doc
  }
}

#let figure-list() = {
  heading(numbering: none)[Popis priloga]
  show outline.entry: it => context {
    if it.at("element", default: (kind: none)).at("kind", default: none) == "formula" {
      let location = it.at("element").location()
      let value = _formula_counter.at(location).at(0) + 1
      let dpy = "(" + str(value) + ")"
      let name = _formula_names.get().at(dpy, default: none)
      if name != none {
        link(it.at("element").location())[
          Formula #value: #name #box(width: 1fr, repeat[.]) #it.page
        ]
      } else {
        link(it.at("element").location())[
          Formula #it.body #box(width: 1fr, repeat[.]) #it.page
        ]
      }
    } else {
      it
    }
  }
  outline(
    title: none,
    target: figure
  )
}
