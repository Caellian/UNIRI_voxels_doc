= Egzaktne metode prikaza

== Ray tracing


Svijetlost se može odbijati i ne završiti u kameri @Pharr2023-ex:
#figure(caption: "osvjetljenje")[
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
- $L_e (p, omega_0)$ sjaj kojeg sam materijal emitira (engl. _emitted radiance_) u smjeru $omega_0$,
- integral $integral_(cal(S)^2)..d omega_i$ djeluje kao *težinski zbroj vrijednosti podintegralnog umnoška* za sve smjerove $d omega_i$ iz kojih može doprijeti svijetlost. Integrira po površini jedinične 2-kugle $cal(S)^2$, te se sastoji od:
  - $f(p, omega_0, omega_i)$ je dvosmjerna funkcija distribucije refleksije (engl. _Bidirectional Reflectance Distribution Function_, BRDF), koja je kasnije objašnjena,
  - $L_i (p,omega_i)$ je sjaj koji dolazi u točku $p$ od drugih izvora svijetlosti (engl. _incoming radiance_), te odbijanjem od reflektivnih površina, te konačno
  - $|cos(theta_i)|$ je geometrijsko prigušenje (engl. _geometric attenuation_) koje osigurava da je svijetlost koja se reflektira u smjeru $omega_0$ najizraženija za savršeni kut refleksije a smanjuje se za pliće kuteve

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
] <model-osvjetljenja>

TODO Koristi @model-osvjetljenja

Ako uzmemo u obzir samo $n$ izvora svijetlosti, integral možemo u potpunosti zamjeniti konačnim izrazom koji predstavlja njihov zbroj:

#figure(caption: "zbroj svijetla")[
  $
  sum^n_(i = 0)
    f(p, omega_0, omega_i)
    L_i (p,omega_i)
    |cos(theta_i)|
  $
] <zbroj-svijetlosti>

No velik udio svijetla koje obasjava površine dolazi do njih odbijanjem od drugih površina te @zbroj-svijetlosti ne daje rezultate koji su vjerodostojni stvarnosti. Rezultat oslanjanja na takvo pojednostavljenje je značajno tamniji prikaz dijelova scene koji nije direktno obasjan.

S druge strane, nije moguče izračunati stvarnu vrijednost integrala iz formule za @osvjetljenje, pa _ray tracing_ metode uz @zbroj-svijetlosti koriste i Monte Carlo metodu gdje prilikom svakog prikaza uzmu nekoliko nasumičnih uzoraka $omega_i$ pa te vrijednosti uključe u težinski zbroj.

Problem s tim pristupom je što proizvede rezultate koji imaju veliku količinu buke (engl. _noise_). Taj problem nije rješiv bez potpunog rješavanja integrala za @osvjetljenje te postoje samo metode njegove mitigacije, ali primjetnost buke zavisi o broju nasumičnih uzoraka koji su uzeti kao i načinu odabira uzorkovanih $omega_i$.

Popularne metode za mitigaciju buke su @nvidia-denoising:
- prostorno filtriranje (engl. _spatial filtering_)
- temporalno prikupljanje uzoraka (engl. _temporal accumulation_), te
- rekonstrukcija metodama strojnog učenja (engl. _machine learning and deep learning reconstruction_).

Svaka od tehnika mitigacije buke ima prednosti i nedostatke, te ih se može kombinirati za postizanje željenog rezultata.

U slučaju rasterizacije uniformno osvjetljenih voksela koji zauzimaju više piksela u krajnjem prikazu, prostorno filtriranje (korištenjem prosjeka sjaja uzoraka na površini istog voksela) pruža iznimno kvalitetno uklanjanje buke @douglas-voxel-denoising[#link("https://youtu.be/VPetAcm1heI&t=393")[6:33]], kao što je vidljivo na @denoising[slici], jer takav prosjek djeluje kao uvečavanje broja nasumičnih uzoraka onoliko puta koliko neka stranica voksela zauzima piksela bez troška koje bi stvarni dodatni uzorci zahtjevali.

#figure(
  caption: [prikaz prije i nakon uklanjanja buke prostornim filtriranjem @douglas-voxel-denoising],
  kind: image,
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: none,
    image("../figure/big_voxel_noise.png", fit: "contain"),
    image("../figure/big_voxel_denoise.png", fit: "contain"),
  )
) <denoising>
