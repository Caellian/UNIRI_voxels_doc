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

// Formule se obilježavaju rednim brojem pojavljivanja u tekstu u običnoj zagradi.
#let formula(body, caption: none, ..args) = figure(
  body,
  kind: "formula",
  supplement: none,
  caption: context {
    let index = counter(figure.where(kind: "formula")).get().at(0)
    [(#index)#metadata((formula: index, caption: caption))]
  },
  ..args,
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
    
    set heading(
      numbering: "1.1.",
      supplement: "dijelu"
    )
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

    set list(
      marker: "-",
    )

    show figure.caption: set text(
      font: ("Times New Roman", "Liberation Serif"),
      size: 10pt,
    )
    show figure.where(kind: table): set figure(supplement: "Tablica")
    show figure.where(kind: table): it => [
      #set figure.caption(position: top)
      #it
    ]
    show figure.where(kind: image): set figure(supplement: "Slika")
    show figure.where(kind: raw): set figure(supplement: "Kȏd")
    show figure.where(kind: raw): it => [
      #show raw: set text(
        font: ("Consolas", "Courier New", "Liberation Mono"),
        size: 9pt,
      )
      #set par(
        leading: 0.5em,
      )
      #set block(width: 100%)
      #set align(left)
      #it
    ]

    // Uključuje ascent i descent u veličinu znaka za računanje razmaka
    // Ascent i descent ovise o fontu, ali obično su 50% ukupne visine glifa
    show heading: set block(inset: (y: 0.25em))

    show ref: it => {
      let el = it.element
      if el == none {
        return it
      }
      let func = el.func()
      if func == figure and el.at("kind", default: none) == "formula" {
        let location = el.location()
        let index = counter(figure.where(kind: "formula")).at(location).at(0)
        let caption = query(metadata).find(it => {
          let value = it.at("value", default: none)
          if type(value) != dictionary {
            return false
          }
          return value.at("formula", default: none) == index
        })
        if caption != none {
          caption = caption.at("value").at("caption", default: none)
        }
        if caption == none {
          link(location)[(#index)]
        } else {
          link(location)[#caption (#index)]
        }
      } else if func == heading {
        let supplement = it.supplement
        if supplement == auto {
          supplement = el.supplement
        }
        link(el.location())[#numbering(el.numbering, ..counter(heading).at(el.location())) #supplement]
      } else {
        it
      }
    }

    // Popravlja outline za formule jer njihov caption ovisi o kontekstu pa se
    // krivo pokazuje u outlineu. Također, stvarni caption nije uključen.
    show outline.where(target: figure.where(kind: "formula")): it => {
      show outline.entry: entry => {
        let location = entry.element.location()
        let index = counter(figure.where(kind: "formula")).at(location).at(0)
        let caption = query(metadata).find(it => {
          let value = it.at("value", default: none)
          if type(value) != dictionary {
            return false
          }
          return value.at("formula", default: none) == index
        })
        if caption != none {
          caption = caption.at("value").at("caption", default: none)
        }
        if caption == none {
          link(location)[(#index) #box(width: 1fr, repeat[.]) #entry.page]
        } else {
          link(location)[(#index) #caption #box(width: 1fr, repeat[.]) #entry.page]
        }
      }
      it
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

#let figure-list() = context {
  if query(figure.where(kind: table)).len() > 0 {
    pagebreak()
    heading(numbering: none)[Popis tablica]
    outline(
      title: none,
      target: figure.where(kind: table)
    )
  }
  if query(figure.where(kind: image)).len() > 0 {
    pagebreak()
    heading(numbering: none)[Popis slika]
    outline(
      title: none,
      target: figure.where(kind: image)
    )
  }
  if query(figure.where(kind: raw)).len() > 0 {
    pagebreak()
    heading(numbering: none)[Popis priloga]
    outline(
      title: none,
      target: figure.where(kind: raw)
    )
  }
}
