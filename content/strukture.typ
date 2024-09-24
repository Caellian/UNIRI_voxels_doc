#import "../util.typ": complexity
#import "@preview/fletcher:0.4.2": *
#import "@preview/tablex:0.0.8": *

= Pohrana volumetrijskih podataka <structures>

Volumetrijke podatke možemo spremiti u:
- diskretnom obliku, i u
- obliku pravila ili funkcija.

Dva pristupa značajno utječu na arhitekturu i zahtjeve aplikacija kao i na zahtjeve strojne opreme potrebne za izvođenje algoritama nad njima. Memorijski zahtjevi diskretnog oblika su generalno manji od zahtjeva oblika pohrane pravilima.

Oblik podataka zadan pravilima se iznimno lagano (i učinkovito) diskretizira, no obrnuta pretvorba je znatno kompliciranija i nije egzaktna jer su neophodne pretpostavke o podacima kojih nema (regresija).

Teško je usporediti algoritamsku složenost dvaju pristupa jer ona zavisi o potrebama aplikacije. Generalno, rasterizacija diskretnog pristupa je brža jer dozvoljava veču paralelizaciju. #linebreak()
Rasterizacija oblika zadanog pravilima uzrokuje veču divergenciju osnovnih grupacija niti (engl. _warp_) koje provode instrukcije zbog čega GPU mora više puta provesti isti skup instrukcija (engl. _wavefront_) @nv-cuda-guide[4.1. SIMT arhitektura]. Dakle u slučajevima gdje je raznolikost prikazanih volumena mala, prikaz SDFa se može provesti brže nego prikaz slične geometrije uporabom diskretnih podataka. 

Definicija za @volumen pruža korisno ograničenje jer pokazuje da možemo doći do volumetrijskih podataka i na druge načine. #linebreak()
Primjer toga je česta primjena složenijih funkcija koje proceduralno generiraju nizove točaka za prikaz (više o tome u @pcg). Za algoritme koračanja po zrakama (engl. _ray marching_) vrijedi obratno pa se ponajviše koriste za jednostavnije volumene, kao i primjene gdje je željena konstruktiva geometrija.


TODO myb reference @Samet2006-vg

#figure(
  kind: table,
  caption: [usporedba karakteristika struktura diskretnih volumetrijskih podataka],
  context {
    let columns = (
      "read": [*Čitanje*],
      "write": [*Pisanje*],
      "advantage": [*Prednost*],
    )
    let rows = ()
    let datas = query(
      <volume-data-type-metadata>
    ).map(it => {
      let title = query(
        heading.where().before(it.location())
      ).last()

      (title, it)
    })
    let max-depth = datas.fold(1, (prev, (title, _)) => {
      calc.max(prev, title.level - 1)
    })

    let last-indent = 0
    for (i, (title, meta)) in datas.enumerate() {
      let indent = title.level - 2
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
      columns: (..((2em,) * (max-depth - 1)), auto, ..((auto,) * columns.len())),
      align: (..((right,) * max-depth), ..((center,) * columns.len())),
      auto-lines: false,
      hlinex(start: max-depth),
      colspanx(max-depth, align(center)[*Ime strukture*]), vlinex(), ..(columns.values().map(it => (it, vlinex()))).flatten(),
      ..rows,
      hlinex(start: last-indent)
    )
  }
)


== Jednodimenzionalna uređenja

#metadata((
  read: complexity($1$, case: "best"),
  write: $1$
)) <volume-data-type-metadata>

== 3D polje

#metadata((
  read: $1$,
  write: $1$
)) <volume-data-type-metadata>

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

== Range Tree

#metadata((
  read: $1$,
  write: $1$
)) <volume-data-type-metadata>

== Priority Search Tree

#metadata((
  read: $1$,
  write: $1$
)) <volume-data-type-metadata>

== Oktalno stablo

#metadata((
  read: $1$,
  write: $1$
)) <volume-data-type-metadata>

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
  caption: "struktura oktalnog stabla koje je sekvencijalno u memoriji"
)[
```rust
enum OctreeNode<T, const DEPTH: usize> {
  Leaf(T),
  Node {
    children: [Octree<T, {DEPTH - 1}>; 8],
  }
}
```
]
]

=== Raštrkana stabla voksela

#metadata((
  read: $1$,
  write: $1$
)) <volume-data-type-metadata>

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

=== DAG

#metadata((
  read: $1$,
  write: $1$
)) <volume-data-type-metadata>

- Varijanta SVOa, navesti razlike.

- Grozne karakteristike izmjena (po defaultu)
  - https://github.com/Phyronnaz/HashDAG

== K-d Stablo

#metadata((
  read: $1$,
  write: $1$
)) <volume-data-type-metadata>

== Bucket Methods

#metadata((
  read: $1$,
  write: $1$
)) <volume-data-type-metadata>

== PK-Stablo

#metadata((
  read: $1$,
  write: $1$
)) <volume-data-type-metadata>

== Point-cloud data?

Spremljeno u Octreeu zapravo?

Laserski skeneri ju generiraju, česta primjena u geoprostornoj analizi.
- Dronovi ju koriste za navigaciju.

#pagebreak()
