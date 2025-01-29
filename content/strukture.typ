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

#include "diskretni_podaci.typ"
#include "podaci_zadani_pravilima.typ"
