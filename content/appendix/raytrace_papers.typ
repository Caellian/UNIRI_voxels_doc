#import "../../template/template.typ": horizontal-page, appendix

#show: horizontal-page

= Značajni znanstveni radovi za ray tracing metodu <raytrace-works>

#let content = (
  [Godina], [Ime rada], [Autori], [DOI],
)
#let entries = csv("../../data/raytrace_papers.csv").map(row => {
  row.map(entry => {
    [#entry]
  })
}).flatten()
#{content = (..content, ..entries)}

#table(
  columns: (auto, 0.7fr, 0.3fr, auto),
  align: (center, left, left, right),
  ..content
)
