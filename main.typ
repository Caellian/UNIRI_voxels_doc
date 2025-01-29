#import "template/template.typ": config, figure-list, appendix

#show "TODO": box(fill: red, outset: 2pt, text(fill: white, weight: "black", "NEDOSTAJE SADRŽAJ"))

#show: config(
  "završni",
  "Metode prikaza volumetrijskih struktura u računalnoj grafici",
  "Tin Švagelj",
  attributions: [
    *Mentor:* doc. dr. sc., Miran Pobar
  ],
  summary: [
    #include "summary.typ"
  ],
  keywords: ("računalna grafika", "vokseli", "rasterizacija"),
  bibliography-columns: 2,
  bibliography-file: "references.bib",
  //print-version: true,
)

#include "./content/uvod.typ"
#include "./content/strukture.typ"
#include "./content/raytrace.typ"
#include "./content/prijevremeno.typ"
#include "./content/realno_vrijeme.typ"
#include "./content/generiranje.typ"
#include "./content/animacije.typ"
#include "./content/usporedba.typ"
#include "./content/zakljucak.typ"

#appendix[
  #include "./content/appendix/raytrace_papers.typ"
]
