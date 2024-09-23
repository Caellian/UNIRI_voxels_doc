#import "../template.typ": formula

= Alternativne metode prikaza

Konkretno u računalnoj znanosti su česte primjene:
- diskretnih podataka (unaprijed određenih vrijednosti) u obliku
  - nizova točaka ili "oblaka točaka" (engl. _point could_), ili
  - polja točaka (engl. _voxel grid_)
- jednadžbi pohranjenih u shaderima koje se koriste u konjunkciji s algoritmima koračanja po zrakama svijetlosti (engl. _ray marching_).

Diskretni podaci imaju jednostavniju implementaciju i manju algoritamsku složenost, no zauzimaju značajno više prostora u memoriji i na uređajima za trajnu pohranu. Za ray marching algoritme vrijedi obratno pa se ponajviše koriste za jednostavnije volumene i primjene gdje su neizbježni.

Definicija za @volumen pruža korisno ograničenje jer pokazuje da možemo doći do volumetrijskih podataka i na druge načine. #linebreak() Primjer toga je česta primjena složenijih funkcija koje proceduralno generiraju nizove točaka za prikaz. Ovaj oblik uporabe je idealan za računalne igrice koje se ne koriste stvarnim podacima jer se oslanja na dobre karakteristike diskretnog oblika, a izbjegava nedostatak velikih prostornih zahtjeva na uređajima za trajnu pohranu.

== Ray tracing

- Osnove kako svijetlost putuje, što vidimo
- Konstruktivne i destruktivne boje
- Što je sjaj (engl. _radiance_)

Svijetlost se može odbijati i ne završiti u kameri @Pharr2023-ex:
#formula(caption: "osvjetljenje")[
$
L_0(p, omega_0) =
  underbrace(L_e (p, omega_0), "emitirani sjaj") +
  integral_(cal(S)^2)
    underbrace(f(p, omega_0, omega_i), "BDRF")
    underbrace(L_i (p,omega_i), "dolazeći sjaj")
    |cos(theta_i)|
    d omega_i
$
] <osvjetljenje>

gdje je:
- $p$ neka obasjana točka koju promatramo,
- $omega_0$ fazor koji označava smjer iz kojeg je točka $p$ promatrana,
- $L_0 (p, omega_0)$ ukupan sjaj koji napušta točku $p$ u smjeru $omega_0$ (engl. _outgoing radiance_),
- $L_e (p, omega_0)$ sjaj kojeg sam materijal emitira (engl. _emitted radiance_) u smjeru $-omega_0$ (npr. lampa),
- integral $integral_(cal(S)^2)..d omega_i$ djeluje kao *težinski zbroj vrijednosti podintegralnog umnoška* za sve smjerove $d omega_i$ iz kojih može doprijeti svijetlost. Integrira po površini jedinične 2-kugle $cal(S)^2$, te se sastoji od:
  - $f(p, omega_0, omega_i)$ je dvosmjerna funkcija distribucije refleksije (engl. _Bidirectional Reflectance Distribution Function_, BRDF), koja je kasnije objašnjena,
  - $L_i (p,omega_i)$ je sjaj koji dolazi u točku $p$ od drugih izvora svijetlosti (engl. _incoming radiance_), te odbijanjem od reflektivnih površina, te konačno
  - $|cos(theta_i)|$ je geometrijsko prigušenje (engl. _geometric attenuation_) koje osigurava da je svijetlost koja se reflektira u smjeru $-omega_0$ 

Koristi se jedinična 2-kugla $cal(S)^2 = {(x,y,z) | x^2 + y^2 + z^2 = 1}$ za integraciju jer su točke na njenoj površini uniformno raspoređene oko $p$ i podjednako udaljene od $p$.

#figure(caption: "prikaz modela osvjetljenja")[
  #set text(size: 10pt)
  #let width = 450pt
  #let height = 250pt
  #box(width: width, height: height)[
    #let center_x = width / 2
    #let center_y = height / -2

    #align(center+horizon, image("../figure/observed_light.png"))
    #place(top+end, table(
      columns: (auto, auto),
      align: center+horizon,
      stroke: 1pt+gray.lighten(10%),
      [vektor], image("../figure/vektor.png"),
      [skalar], image("../figure/skalar.png")
    ))

    #place(dx: center_x + 4pt, dy: center_y + 13pt, $p$)
    #place(dx: center_x - 68pt, dy: center_y - 65pt, $omega_0$)
    #place(dx: center_x + 44pt, dy: center_y - 26pt, text(fill: yellow, $omega_i$))
    #place(dx: center_x - 73pt, dy: center_y - 28pt, text(fill: blue, $L_e$))
    #place(dx: center_x - 95pt, dy: center_y, text(fill: purple, $L_i$))
    #place(dx: center_x + 28pt, dy: center_y + 58pt, $cal(S)^2$)
    #place(dx: center_x - 1.5pt, dy: center_y - 3pt, $theta$)
  ]
] <model_osvjetljenja>

TODO Koristi @model_osvjetljenja

Ako uzmemo u obzir samo $n$ izvora svijetlosti, integral možemo u potpunosti zamjeniti konačnim izrazom koji predstavlja njihov zbroj:

#formula(caption: "zbroj svijetla")[
  $
  sum^n_(i = 0)
    f(p, omega_0, omega_i)
    L_i (p,omega_i)
    |cos(theta_i)|
  $
] <zbroj_svijetlosti>

No velik udio svijetla koje obasjava površine dolazi do njih odbijanjem od drugih površina te @zbroj_svijetlosti ne daje rezultate koji su vjerodostojni stvarnosti. Rezultat oslanjanja na takvo pojednostavljenje je značajno tamniji prikaz dijelova scene koji nije direktno obasjan.

S druge strane, nije moguče izračunati stvarnu vrijednost integrala iz formule za @osvjetljenje, pa _ray tracing_ metode umjesto toga prilikom svakog prikaza uzmu nekoliko nasumičnih uzoraka $omega_i$.

Problem s tim pristupom je što proizvede rezultate koji imaju veliku količinu buke (engl. _noise_). Taj problem nije rješiv bez potpunog rješavanja integrala za @osvjetljenje te postoje samo metode njegove mitigacije.

Popularnih metoda za mitigaciju buke su @nvidia-denoising:
- prostorno filtriranje (engl. _spatial filtering_)
- temporalno prikupljanje uzoraka (engl. _temporal accumulation_), te
- rekonstrukcija metodama strojnog učenja (engl. _machine learning and deep learning reconstruction_).

Svaka od tih metoda ima prednosti i nedostatke, može te ih se može kombinirati.

TODO Denoizing može biti savršen za voksele: Per-voxel Lighting via Path Tracing, Voxel Engine Devlog \#19 https://www.youtube.com/watch?v=VPetAcm1heI

== Ray marching

TODO Koristimo neki jednostavan primitiv za testiranje kolizije zrake sa tijelom, obično kugla ili kocka. Koračamo za veličinu največeg takvog tijela unaprijed.

Iako se čini ograničavajuće što ray marching dozvoljava prikaz geometrije oslanjajući se samo na SDF, moguće je prijevremeno pretvoriti arbitrarne 3D modele izrađene u programima za modeliranje u SDF pomoću tehnika iz strojnog učenja (engl. _machine learning_, ML) @Park2019-vp.

TODO
- Dozvoljava fora efekte poput metaballs.
- Brže od raytraceanja (u nekim slučajevima, npr. vokseli), no ograničenije jer zahtjeva da su sva prikazana tijela izražena formulama i shader onda mora rješavati sustave jednadžbi
  - Je li doista brže za voksele (e.g. Nvidia SVO) ili samo za loše slučajeve? Slabo se koristi.

#pagebreak()