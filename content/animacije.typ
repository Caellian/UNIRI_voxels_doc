= Animacije

Animiranje volumetrijskih podataka je iznimno složen problem te je li ono uopće izvedivo ovisi o načinu pohrane podataka, tj. kako ih se dobavlja.

Podatke koji su zadani pravilom je jednostavnije animirati jer je lagano proizvesti nove podatke izmjenom paramatara pravila koje ih stvaraju. Velika prednost SDF zapisa je upravo to što je iznimno jednostavna animacija kompoziranih tijela.#linebreak()
U slučajevima kada proces prikaza koristi diskretne podatke, moguće ih je u toku izvođenja (engl. _in-flight_) GPU programa diskretizirati uzorkovanjem SDF vrijednosti što daje dobre rezultate ukliko je veličina uzorkovanja (engl. _sampling size_) dovoljno sitna (engl. _fine_).

- Ona metoda gdje se generira AABB za segmente koji međusobno ne colideaju i koristi skeleton
- Metoda sa deformacijom voksela
  - Nije "pravi" voxel renderer
- Metoda gdje se u compute shaderu samplea animirani triangle mesh svaki frame
  - Izgleda meh i relativno je zahtjevno
- Metoda gdje je definirana funkcija koja mapira deltatime na konfiguraciju voksela

- Opisati kako je DAG neprikladan za animiranje - ili spor ili jako potrošan glede memorije

#pagebreak()
