#import "../util.typ": complexity
#import "@preview/fletcher:0.4.2": *
#import "@preview/tablex:0.0.9": *

== Diskretni prodaci

TODO myb reference @Samet2006-vg

#figure(
  kind: table,
  caption: [usporedba karakteristika struktura diskretnih volumetrijskih podataka],
  context {
    let columns = (
      "access": ([*Pristup*],),
      "insert": ([*Umetanje*],),
      "advantage": ([*Prednost*], 1fr, left+horizon),
    )
    let rows = ()
    let datas = query(
      <discrete-data-info>
    ).map(it => {
      let title = query(
        heading.where().before(it.location())
      ).last()

      (title, it)
    })
    let max-depth = datas.fold(1, (prev, (title, _)) => {
      calc.max(prev, title.level - 2)
    })

    let last-indent = 0
    for (i, (title, meta)) in datas.enumerate() {
      let indent = title.level - 3
      let name = title.body
      rows.push(hlinex(start: calc.min(indent, last-indent)))
      rows.push(vlinex(
        start: 1 + i,
        end: 2 + i,
        x: indent,
        stroke: 1pt * (indent + 1)
      ))
      for i in range(0, indent) {
        rows.push([])
      }
      rows.push(colspanx(max-depth - indent, link(title.location(), title.body)))
      for (key, _) in columns {
        rows.push(meta.value.at(key, default: []))
      }
      last-indent = indent
    }
    
    tablex(
      columns: (
        ..((2em,) * (max-depth - 1)),
        auto,
        ..columns.values().map(it => it.at(1, default: auto))
      ),
      align: (
        ..((right+horizon,) * max-depth),
        ..columns.values().map(it => it.at(2, default: center+horizon))
      ),
      auto-lines: false,
      hlinex(start: max-depth),
      colspanx(max-depth, align(center)[*Ime strukture*]), vlinex(),
      ..(
        columns.values().map(it => (align(center, it.at(0)), vlinex()))
      ).flatten(),
      ..rows,
      hlinex(start: last-indent)
    )
  }
)

=== 3D polje

#metadata((
  access: complexity($1$),
  insert: "N/A",
  advantage: [
    Jednostavna implementacija, pristup u konstantom vremenu
  ]
)) <discrete-data-info>

#figure(
  caption: "struktura 3D polja"
)[
```rust
const CHUNK_SIZE: usize = 32;
type EntryID = u16;

struct Chunk<T> {
  data: [[[EntryID; CHUNK_SIZE]; CHUNK_SIZE]; CHUNK_SIZE],
  values: Vec<T>
}
```
] <3d-struct>

- Jednostavna i najčešća implementacija za real time render
- Postoji relativno puno primjera, alogritama, ...

- https://www.aliza-dicom-viewer.com/download/datasets [NOTE: some of the files only contains the DataSet without the headers so they must be completed to be opened :/]
- https://medimodel.com/sample-dicom-files/


=== Oktalno stablo

#metadata((
  access: complexity($log n$),
  write: $1$
)) <discrete-data-info>

Oktalna stabla (engl. _octree_) su jedna od vrsta stabla koja imaju iznimno čestu uporabu u 3D grafici za ubrzavanje prikaza dijeljenjem prostora. Strukturirana podjela prostora dozvoljava značajna ubrzanja u ray tracing algoritmima jer zrake svijetlosti mogu preskočiti velike korake.

Koriste se i u simulaciji fizike jer olakšavaju brzu segmentaciju prostora čime se postiže brzo isključivanje dalekih tijela iz izračuna kolizija.

#grid(
  columns: (1fr, 1fr)
)[
#figure(
  caption: "struktura oktalnog stabla s pokazivačima"
)[
```rust
enum Octree<T> {
  Leaf(T),
  Node {
    children: [Box<Octree>; 8],
  }
}
```
]
][
#figure(
  caption: [
    struktura oktalnog stabla koje je sekvencijalno u memoriji
    #footnote[
      ova struktura ima pojednostavljen prikaz koji nije točan u svrhu preglednosti - polje `children` za `Octree::Node` varijantu je beskonačne veličine jer ```rust DEPTH``` nije nikako ograničen. Stvarna implementacija ovakve strukture je na poveznici #link("https://github.com/Caellian/flat-octree")[github.com/Caellian/flat-octree], koja dozvoljava samo `Octree::Leaf` za ```rust DEPTH = 0```.
    ]
  ]
)[
```rust
enum Octree<T, const DEPTH: usize> {
  Leaf(T),
  Node {
    children: [Octree<T, {DEPTH - 1}>; 8],
  }
}
```
]
]

==== Raštrkana stabla voksela

#metadata((
  read: $1$,
  write: $1$
)) <discrete-data-info>

Raštrkana stabla voksela (engl. _sparse voxel octree_, SVO) su vrsta stablastih struktura koja pohranjuje susjedne čvorove u nelinearnim segmentima memorije te zbog toga dozvoljava "prazne" čvorove.

```rust
enum Octree<T> {
  Leaf(Option<T>),
  Node {
    children: [Box<Octree>; 8],
  }
}
```

Prednost ovakvih struktura je što prazni dijelovi strukture ne zauzimaju prostor u memoriji, te ih nije potrebno kopirati u memoriju grafičkih kartica prilikom prikaza.

No iako rješavaju problem velike potrošnje memorije, čine izmjene podataka iznimno sporima te se zbog toga primjenjuju skoro isključivo za podatke koji se ne mijenjaju tokom provođenja programa.
Izvor loših performansi izmjena su potreba za premještanjem (kopiranjem) postojećih podataka kako bi se postigla njihova bolja lokalnost u međuspremniku (engl. _cache locality_) na grafičkoj kartici.

- Komplicirana implementacija
  - Postoji već gotov shader kod za ovo u par shading jezika negdje

- https://research.nvidia.com/sites/default/files/pubs/2010-02_Efficient-Sparse-Voxel/laine2010tr1_paper.pdf

==== DAG

#metadata((
  read: $1$,
  write: $1$
)) <discrete-data-info>

- Varijanta SVOa, navesti razlike.

- Grozne karakteristike izmjena (po defaultu)
  - https://github.com/Phyronnaz/HashDAG

=== Jednodimenzionalna uređenja

#metadata((
  access: complexity($1$),
  insert: complexity($n$),
)) <discrete-data-info>

=== Range Tree

#metadata((
  read: $1$,
  write: $1$
)) <discrete-data-info>

=== Priority Search Tree

#metadata((
  read: $1$,
  write: $1$
)) <discrete-data-info>

=== K-d Stablo

#metadata((
  read: $1$,
  write: $1$
)) <discrete-data-info>

=== Bucket Methods

#metadata((
  read: $1$,
  write: $1$
)) <discrete-data-info>

=== PK-Stablo

#metadata((
  read: $1$,
  write: $1$
)) <discrete-data-info>

=== Point-cloud data?

Spremljeno u Octreeu zapravo?

Laserski skeneri ju generiraju, česta primjena u geoprostornoj analizi.
- Dronovi ju koriste za navigaciju.

#pagebreak()
