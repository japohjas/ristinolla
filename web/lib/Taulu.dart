import 'dart:html';

// 9.10.2020 Jari Pohjasmäki japohjas@gmail.com
// koordinatit kahdessa Map taulussa on muodossa x:y, pelin vasen ylänurkka = 0:0
// voittavarivi kerätään listaan
// tarkastuksessa skannataan pelilauta läpi, x, y, kaakko, lounas

class Taulu {
  int koko; // pelilaudan koko
  var taulukko = {}; // avain koordinaatit, arvo merkki. Alustuksessa arvot = ?
  var paikkaElementti =
      {}; // pelin kuluessa tänne kerätään: avain koordinaatti arvo elementti
  int merkkiaPerakkain; // kuinka monta merkkiä pitää olla peräkkäin että peli päättyy
  bool peliKaynnissa = true;

  Taulu(this.koko, this.merkkiaPerakkain);

  void alustaTaulu() {
    var merkki = 'X';
    querySelector('#taulu').children.clear();
    querySelector('#vuoro').text = 'vuoro: $merkki';

    for (var y = 0; y < koko; y++) {
      var rivi = Element.tag('tr');
      querySelector('#taulu').children.add(rivi);

      for (var x = 0; x < koko; x++) {
        var elementti = Element.tag('td');
        var paikka = '$x:$y';
        taulukko[paikka] = '?';
        querySelector('#taulu').children.add(elementti);

        elementti.onClick.listen((event) {
          if ((taulukko[paikka] == '?') && peliKaynnissa) {
            elementti.text = merkki;
            taulukko[paikka] = merkki;
            // print('$paikka -> ${taulukko[paikka]}');
            paikkaElementti[paikka] = elementti;
            pelitilanteenTarkastus(merkki);

            if (peliKaynnissa) {
              merkki = merkinVaihto(merkki);
              querySelector('#vuoro').text = 'vuoro: $merkki';
            } else {
              querySelector('#vuoro').text = '$merkki voitti';
            }
            if ((!taulukko.values.contains('?')) && peliKaynnissa) {
              querySelector('#vuoro').text = 'tasapeli';
              peliKaynnissa = false;
            }
          }
        });
      }
    }
  }

  String merkinVaihto(String merkki) {
    if (merkki == 'X') {
      return 'O';
    }
    return 'X';
  }

  void naytaVoittavarivi(voittavarivi) {
    peliKaynnissa = false;

    for (var paikka in voittavarivi) {
      var elementti = paikkaElementti[paikka];
      elementti.style.backgroundColor = 'green';
      elementti.style.color = 'white';
    }
  }

  void pelitilanteenTarkastus(merkki) {
    tarkastusXY(merkki);
    tarkastusKaakko(merkki);
    tarkastusLounas(merkki);
  }

  // tarkastus x ja y tasossa
  void tarkastusXY(String merkki) {
    var laskuKaynnissaX = false;
    var laskuKaynnissaY = false;
    var voittavariviX = [];
    var voittavariviY = [];

    for (var y = 0; y < koko; y++) {
      for (var x = 0; x < koko; x++) {
        // x-taso
        if (taulukko['$x:$y'] == merkki) {
          voittavariviX.add('$x:$y');
          laskuKaynnissaX = true;
          // print('samojenmäärä X = $samojenMaaraX');
        } else if (laskuKaynnissaX) {
          voittavariviX.clear();
        }
        // y-taso
        if (taulukko['$y:$x'] == merkki) {
          voittavariviY.add('$y:$x');
          laskuKaynnissaY = true;
          // print('samojenmäärä Y = $samojenMaaraY');
        } else if (laskuKaynnissaY) {
          voittavariviY.clear();
        }

        if (voittavariviX.length == merkkiaPerakkain) {
          // print(voittavariviX);
          naytaVoittavarivi(voittavariviX);
        }
        if (voittavariviY.length == merkkiaPerakkain) {
          // print(voittavariviY);
          naytaVoittavarivi(voittavariviY);
        }
      }

      voittavariviX.clear();
      voittavariviY.clear();
      laskuKaynnissaX = false;
      laskuKaynnissaY = false;
    }
  }

  void tarkastusKaakko(String merkki) {
    var laskuKaynnissa = false;
    var voittavarivi = [];
    var i = 0;

    // 0:0 -> 8:8 keski + vasen kaakko \
    for (var j = 0; j < koko; j++) {
      while (i < koko - j) {
        var y = i + j;
        // print('$i:$y');
        if (taulukko['$i:$y'] == merkki) {
          voittavarivi.add('$i:$y');
          laskuKaynnissa = true;
        } else if (laskuKaynnissa) {
          voittavarivi.clear();
        }

        if (voittavarivi.length == merkkiaPerakkain) {
          naytaVoittavarivi(voittavarivi);
        }

        i++;
      }

      laskuKaynnissa = false;
      voittavarivi.clear();
      i = 0;
    }

    // oikea kaakko \
    // 1:0 2:1 3:2 4:3 5:4 6:5 7:6 8:7
    // 2:0
    i = 1;
    var y = 0;
    for (var j = 0; j < koko; j++) {
      while (i < koko) {
        y = i - 1 - j;
        //print('$i:$y');
        if (taulukko['$i:$y'] == merkki) {
          voittavarivi.add('$i:$y');
          laskuKaynnissa = true;
        } else if (laskuKaynnissa) {
          voittavarivi.clear();
        }

        if (voittavarivi.length == merkkiaPerakkain) {
          naytaVoittavarivi(voittavarivi);
        }
        i++;
      }

      laskuKaynnissa = false;
      voittavarivi.clear();
      i = j + 2;
    }
  }

  void tarkastusLounas(String merkki) {
    var laskuKaynnissa = false;
    var voittavarivi = [];

    // 8:0 7:1 6:2 5:3 4:4 3:5 2:6 1:7 0:8  //keskilinja -> alas asti
    // 8:1 7:2 6:3 5:4 4:5 3:6 2:7 1:8      // yksi alaspäin
    for (var j = 0; j < koko; j++) {
      var i = koko - 1;
      var y = j;
      while ((i - j) >= 0) {
        // print('$i:$y');
        if (taulukko['$i:$y'] == merkki) {
          voittavarivi.add('$i:$y');
          laskuKaynnissa = true;
        } else if (laskuKaynnissa) {
          voittavarivi.clear();
        }

        if (voittavarivi.length == merkkiaPerakkain) {
          naytaVoittavarivi(voittavarivi);
        }
        i--;
        y++;
      }

      laskuKaynnissa = false;
      voittavarivi.clear();
    }

    laskuKaynnissa = false;
    voittavarivi.clear();

    // 7:0 6:1 5:2 4:3 3:4 2:5 1:6 0:7  // yksi ylöspäin -> ylös asti
    // 6:0 5:1 4:2 3:3 2:4 1:5 0:6
    for (var j = 0; j < koko; j++) {
      var i = koko - 2 - j;
      var y = 0;
      while (i >= 0) {
        //print('$i:$y');
        if (taulukko['$i:$y'] == merkki) {
          voittavarivi.add('$i:$y');
          laskuKaynnissa = true;
        } else if (laskuKaynnissa) {
          voittavarivi.clear();
        }

        if (voittavarivi.length == merkkiaPerakkain) {
          naytaVoittavarivi(voittavarivi);
        }
        i--;
        y++;
      }

      laskuKaynnissa = false;
      voittavarivi.clear();
    }
  }
}
