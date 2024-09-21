#import "../util.typ": add-more, complexity
#import "../template.typ": formula
#import "@preview/tablex:0.0.8": *

= Uvod

Cilj računalne grafike je deterministički prikaz trodimenzionalnog (3D) sadržaja na zaslonu računala. Kako bi se to postiglo, primjenjuju različiti algoritmi na strukturama podataka koje su zavisne o području primjene i ciljevima softvera. Tradicionalni način prikaza 3D sadržaja je predstavljanje takvog sadržaja korištenjem jednostavnih matematičkih tijela (engl. _primitives_) poput trokuta, linearna transformacija njihovog prostora, projekcija na plohu koja je uzorkovana (engl. _sampled_) pravilnom rešetkom (engl. _grid_) piksela, te konačno prikazana na ekranu.

Nakon inicijalnog razvoja grafičkih kartica (engl. _graphics processing unit_, GPU) sa fiksiranim dijelovima procesa prikaza (engl. _fixed function pipeline_, FFP), kasnije je razvijena i sljedeća generacija GPUa sa programabilnim procesom prikaza (engl. _programmable pipeline_). Takve grafičke kartice dozvoljavaju uporabu različitih programa (engl. _shader_) za prikaz i izračun. Shaderi su konstantnim napretkom postajali sve fleksibilniji te se danas primjenjuju u mnoge svrhe koje nisu usko vezane za grafiku, ali zahtjevaju visoku razinu konkurentnih izračuna, poput:
- simulacije,
- analize podataka,
- neuralnih mreža,
- obrade multimedijskih podataka, te brojne druge.

Prikaz volumetrijskih struktura je jedna od takvih namjena za koje FFP često nije prikladan jer se oslanja na specijalizirane algoritme koji često ne rade s trokutima nego simuliraju zrake svijetlosti. #linebreak()
U svrhu unaprijeđenja performansi ovakvog pristupa su proizvođači grafičkih kartica od 2020. godine počeli uključivati specijaliziran hardver kako bi se postigla hardverska akceleracija prilikom rada s volumetrijskim podacima @rtx-launch.

Cilj ovog rada je prikazati načela rada s volumetrijskim podacima, kao i njihovih prednosti u različitim područjima primjene.

Razvoj grafike koja utilizira FFP je popratio razvoj i popularnost sukladnih formata za pohranu modela koji opisuju isključivo površinsku geometriju predmeta (engl. _mesh_). Za svrhe jednostavnog prikaza je taj oblik pohrane idealan, no nedostatan je za obradu trodimenzionalnih podataka. U mnogim primjenama takvo ograničenje dovodi koncesija koje negativno utječu na performanse aplikacija ili njihove sposobnosti.
Također je nedostatan i za primjene u simulacijama jer zahtjeva nadomještaj nedostatnih podataka o volumenu različitim aproksimacijama za koje traže sporu prethodnu obradu (engl. _preprocessing_). #linebreak()
Drugi cilj ovog rada je osvrnuti se na takve formate za pohranu trodimenzionalnih podataka i ukazati na uvedene neučinkovitosti zahtjevane njihovim nedostacima.

- https://www.sciencedirect.com/topics/computer-science/volumetric-dataset
- https://developer.nvidia.com/gpugems/gpugems/part-vi-beyond-triangles/chapter-39-volume-rendering-techniques
- https://web.cse.ohio-state.edu/~shen.94/788/Site/Reading_files/Leovy88.pdf

#pagebreak()

== Definicija volumetrijskih podataka

Volumentrijski podaci se mogu predstaviti na mnogo različih načina, no u osnovi se radi o skupu vrijednosti koje su pridružene koordinatama u nekom prostoru.

Memorijska ograničenja računala nalažu da su prostori u memoriji učinkovito *konačni*. Također su svi produktni prostori koje možmo stvoriti i *prebrojivi* neovisno o načinu na koji ih pohranjujemo u memoriji. To se odnosi i na decimalne tipove podataka jer za svaki postoji neki korak $epsilon$ između uzastopnih vrijednosti koje možemo pohraniti.#linebreak()
Konačno, svaka topologija koja se rasterizira se u nekom dijelu rasterizacijskog pipelinea *poprima prekide*: u krajnjem slučaju prilikom prikaza na zaslonu računala, no obično i ranije prilikom obrade.#linebreak()
U večini primjena je cilj izbječi vidljivost tih kvaliteta prilikom prikaza, no ta činjenica opušta mnogo problema (engl. _problem relaxation_) prilikom rada jer dozvoljava međukoracima algoritama za obradu da aproksimiraju rezultate s ciljem bržeg izvođenja.

Neko tijelo u 3D prostoru predstavljamo skupom uređenih trojki, tj. vektora koji zadovoljavaju neki:

#formula(caption: "volumen tijela")[
  $
  P: A^3 arrow.r {top, bot}\
  V :equiv  {(x,y,z) in A^3 | P(x,y,z)}
  $
] <volumen>

gdje je $(x, y, z)$ uređena trojka koordinata, a $P$ neki sud koji određuje uključuje li razmatrani volumen tu trojku/vektor. Tip suda $P$ zavisan o ulaznim vrijednostima, tj. tip vrijednosti ($A$) nije bitan za izraz te je zamjenjiv s $RR$ ili nekim drugim tipom poput ```rust f32``` ili ```rust u64``` - ovisno o namjeni.

U slučaju volumetrijskih podataka volumenu želimo pridružiti neku vrijednost pa ako vrijedi da

#formula(caption: "skup volumetrijskih podataka")[
  $
  exists f: (A^3 subset.eq V) arrow.r cal(C) \
  arrow.b.double\
  exists (D : A^3 times cal(C)).D :equiv {(x,y,z,f(x, y, z)) | (x,y,z) in V} equiv {(x,y,z,c)}
  $
] <volumen_podaci>

gdje je $c$ neka vrijednost tipa $cal(C)$ koju pridružujemo koordinatama, a $f$ preslikavanje kojim ju određujemo za sve koordinate prostora $V$.

Dakle, bilo koja funkcija čija je kodomena skup _uređenih trojki elemenata tipa $A^3$_ je prikladna za predstavljanje volumena (_oblika_ volumetrijskih podataka), te ako postoji neko preslikavanje tog volumena na neku željenu informaciju (npr. gustoču ili boju), imamo potpuno definirane volumetrijske podatke.

#pagebreak()

== Računalna primjena

Proces pretvorbe zapisa s uvjetima (sudom), odnosno određivanja vrijednosti funkcije u određenim točkama, zove se *diskretizacija* funckije.
Rezolucija diskretiziranih podataka ovisi o načinu na koji smo preslikali i pohranili funkciju u računalu s tipovima podataka ograničene veličine, te koji tip brojeva je korišten za pogranu (npr. ```rust u16```/```rust u32```).

Diskretizacija je željena jer značajno umanjuje potreban rad na grafičkim karticama, kao i u nekim slučajevima daljnju obradu, no kompozicija zapisa s uvjetima je manje algoritamski zahtjevna zbog čega se taj pristup češće primjenjuje za generiranje volumetrijskih podataka kao i kod generativnih metoda prikaza poput koračanja zrakama (engl. _ray marching_).

Stvaranje volumetrijskih podataka iz stvarnog prostora uporabom perifernih uređaja poput laserskih skenera se zove *uzorkovanje*. Isti naziv se ponekad koristi i za diskretizaciju, no u ovom radu će se koristiti preteći u svrhu jasnoće, iako imaju preklapanja u značenju.

Diskretne podatke je moguće predstaviti kao neuređeni niz točaka (tj. kao @volumen_podaci), no taj oblik pohrane ima najgoru složenost za pronalazak vrijednosti #complexity($n_x n_y n_z$, case: "same").#linebreak()Kako bismo odabrali optimalan način strukturiranja podataka, potrebo je znati odgovor na sljedeća pitanja @Samet2006-vg:
1. S kojim tipovima podataka baratamo?
2. Za kakve su operacije korišteni?
3. Trebamo li ih kako organizirati ili prostor u kojeg ih ugrađujemo (engl. _embedding space_)?
4. Jesu li statični ili dinamični (tj. može li broj točaka u volumenu porasti tokom rada aplikacije)?
5. Možemo li pretpostaviti da je volumen podataka dovoljno malen da ga u potpunosti smjestimo u radnu memoriju ili trebamo poduzeti mjere potrebne za pristup uređajima za trajnu pohrani?

Zbog različitih odgovora na ta pitanja ne postoji rješenje koje funkcionira približno dobro za sve namjene. U #link(<structures>)[poglavlju o strukturama] su podrobnije razjašnjene razlike između različitih načina pohrane volumetrijskih podataka.

== Primjene volumetrijskih podataka

- Medicina - https://www.sciencedirect.com/topics/computer-science/volumetric-data
  - Rendgenska tomografija
  - Elektronski mikroskopi
    - (engl. _Transmission Electron Microscopy_, TEM) i (engl. _Scanning Transmission Electron Microscopy_, STEM)
  - DICOM format
- Geoprostorna analiza
- Prozivodnja (doi: 10.1117/12.561181)
  - Brzina prototipiranja
- Simulacije
- Računalne igre

== Komercijalni primjeri

- C4, by Terathon http://www.terathon.com/
  - discontinued
- https://voxelfarm.com/index.html
- https://gareth.pw/web/picavoxel/
- Euclideon
  - Koristi point cloud mislim 
  - claim: "Ne koristi GPU pipeline"

#pagebreak()
