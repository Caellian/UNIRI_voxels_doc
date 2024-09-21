= Alternativne metode prikaza


Konkretno u računalnoj znanosti su česte primjene:
- diskretnih podataka (unaprijed određenih vrijednosti) u obliku
  - nizova točaka ili "oblaka točaka" (engl. _point could_), ili
  - polja točaka (engl. _voxel grid_)
- jednadžbi pohranjenih u shaderima koje se koriste u konjunkciji s algoritmima koračanja po zrakama svijetlosti (engl. _ray marching_).

Diskretni podaci imaju jednostavniju implementaciju i manju algoritamsku složenost, no zauzimaju značajno više prostora u memoriji i na uređajima za trajnu pohranu. Za ray marching algoritme vrijedi obratno pa se ponajviše koriste za jednostavnije volumene i primjene gdje su neizbježni.

Definicija za @volumen pruža korisno ograničenje jer pokazuje da možemo doći do volumetrijskih podataka i na druge načine. #linebreak() Primjer toga je česta primjena složenijih funkcija koje proceduralno generiraju nizove točaka za prikaz. Ovaj oblik uporabe je idealan za računalne igrice koje se ne koriste stvarnim podacima jer se oslanja na dobre karakteristike diskretnog oblika, a izbjegava nedostatak velikih prostornih zahtjeva na uređajima za trajnu pohranu.

== Ray tracing

Svijetlost se može odbijati i ne završiti u kameri @Pharr2023-ex:
$
L_0(p, omega_0) = L_e (p, omega_0) + integral_(cal(S)^2) f(p, omega_0, omega_i) L_i (p,omega_i)|cos(theta_i)| d omega_i
$

Pojednostavljenje... promatramo zrake koje završe u kameri tako što simuliramo zrake _iz_ kamere i badabim, badapam zbrojimo konačan broj odskakanja, bla bla, itd.

Denoizing može biti savršen za voksele: Per-voxel Lighting via Path Tracing, Voxel Engine Devlog \#19 https://www.youtube.com/watch?v=VPetAcm1heI

== Ray marching

Koristimo neki jednostavan primitiv za testiranje kolizije zrake sa tijelom, obično kugla ili kocka. Koračamo za veličinu največeg takvog tijela unaprijed.

- Dozvoljava fora efekte poput metaballs.
- Brže od raytraceanja (u nekim slučajevima, npr. vokseli), no ograničenije jer zahtjeva da su sva prikazana tijela izražena formulama i shader onda mora rješavati sustave jednadžbi
  - Postoji negdje neki algoritam s kojim se može aproksimirati arbitrarni mesh ali daje dosta složene formule u mnogim slučajevima (koje su onda teške za predstaviti u kodu i spore za izračun).
    - Vidio sam ga prije 4/5 godina, treba to iskopati sada...
  - Je li doista brže za voksele (e.g. Nvidia SVO) ili samo za loše slučajeve? Slabo se koristi.

#pagebreak()