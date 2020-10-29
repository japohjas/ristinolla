import 'dart:html';

/* 
9.10.2020 Jari Pohjasmäki japohjas@gmail.com
Koordinatit kahdessa Map taulussa on muodossa x:y, pelin vasen ylänurkka = 0:0.
Voittavarivi kerätään listaan tarkastuksen yhteydessä.
Tarkastuksessa skannataan pelilauta läpi, x, y, kaakko, lounas.
Pelin loputtua taulukot tyhjennetään.
14.10.2020 v2.0
*/

class Taulu {
  // pelilaudan koko
  final int _koko;
  // avain koordinaatit, arvo merkki. Alustuksessa arvot = ?
  final Map _taulukko = {};
  // pelin kuluessa tänne kerätään: avain koordinaatti arvo elementti
  final Map _paikkaElementti = {};
  // kuinka monta merkkiä pitää olla peräkkäin pelin päättymiseen voittoon
  final int _merkkiaPerakkain;
  bool _peliKaynnissa = true;

  Taulu(this._koko, this._merkkiaPerakkain);

  void alustaTaulu() {
    var merkki = 'X';
    querySelector('#vuoro').text = 'Vuoro - $merkki';
    querySelector('#taulu').children.clear();

    for (var y = 0; y < _koko; y++) {
      var rivi = Element.tag('tr');
      querySelector('#taulu').children.add(rivi);

      for (var x = 0; x < _koko; x++) {
        var elementti = Element.tag('td');
        var paikka = '$x:$y';
        _taulukko[paikka] = '?';
        querySelector('#taulu').children.add(elementti);

        elementti.onClick.listen((event) {
          if (_peliKaynnissa && (_taulukko[paikka] == '?')) {
            elementti.text = merkki;
            _taulukko[paikka] = merkki;
            // print('$paikka -> ${taulukko[paikka]}');
            _paikkaElementti[paikka] = elementti;
            // jos löytyy voittavarivi -> peliKaynnissa = false
            _pelitilanteenTarkastus(merkki);

            if (_peliKaynnissa) {
              merkki = _merkinVaihto(merkki);
              querySelector('#vuoro').text = 'Vuoro - $merkki';
            } else {
              querySelector('#vuoro').text = '$merkki voitti';
            }

            if (_peliKaynnissa && (!_taulukko.values.contains('?'))) {
              querySelector('#vuoro').text = 'tasapeli';
              _peliKaynnissa = false;
              _tyhjennaTaulukot();
            }
          }
        });
      }
    }
  }

  String _merkinVaihto(String merkki) {
    if (merkki == 'X') {
      return 'O';
    }
    return 'X';
  }

  void _naytaVoittavarivi(voittavarivi) {
    _peliKaynnissa = false;

    for (var paikka in voittavarivi) {
      var elementti = _paikkaElementti[paikka];
      elementti.style.backgroundColor = 'green';
      elementti.style.color = 'white';
    }
  }

  void _pelitilanteenTarkastus(merkki) {
    _tarkastusXY(merkki);
    _tarkastusKaakko(merkki);
    _tarkastusLounas(merkki);

    if (!_peliKaynnissa) {
      _tyhjennaTaulukot();
    }
  }

  void _tyhjennaTaulukot() {
    _taulukko.clear();
    _paikkaElementti.clear();
    // print('$taulukko $paikkaElementti');
  }

  // tarkastus x ja y tasossa
  void _tarkastusXY(String merkki) {
    var laskuKaynnissaX = false;
    var laskuKaynnissaY = false;
    var voittavariviX = [];
    var voittavariviY = [];

    for (var y = 0; y < _koko; y++) {
      for (var x = 0; x < _koko; x++) {
        // x-taso
        if (_taulukko['$x:$y'] == merkki) {
          voittavariviX.add('$x:$y');
          laskuKaynnissaX = true;
          // print('samojenmäärä X = $samojenMaaraX');
        } else if (laskuKaynnissaX) {
          voittavariviX.clear();
        }
        // y-taso
        if (_taulukko['$y:$x'] == merkki) {
          voittavariviY.add('$y:$x');
          laskuKaynnissaY = true;
          // print('samojenmäärä Y = $samojenMaaraY');
        } else if (laskuKaynnissaY) {
          voittavariviY.clear();
        }

        if (voittavariviX.length == _merkkiaPerakkain) {
          // print(voittavariviX);
          _naytaVoittavarivi(voittavariviX);
        }
        if (voittavariviY.length == _merkkiaPerakkain) {
          // print(voittavariviY);
          _naytaVoittavarivi(voittavariviY);
        }
      }

      voittavariviX.clear();
      voittavariviY.clear();
      laskuKaynnissaX = false;
      laskuKaynnissaY = false;
    }
  }

  void _tarkastusKaakko(String merkki) {
    var laskuKaynnissa = false;
    var voittavarivi = [];
    var i = 0;

    // 0:0 -> 8:8 keski + vasen kaakko \
    for (var j = 0; j < _koko; j++) {
      while (i < _koko - j) {
        var y = i + j;
        // print('$i:$y');
        if (_taulukko['$i:$y'] == merkki) {
          voittavarivi.add('$i:$y');
          laskuKaynnissa = true;
        } else if (laskuKaynnissa) {
          voittavarivi.clear();
        }

        if (voittavarivi.length == _merkkiaPerakkain) {
          _naytaVoittavarivi(voittavarivi);
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
    for (var j = 0; j < _koko; j++) {
      while (i < _koko) {
        y = i - 1 - j;
        //print('$i:$y');
        if (_taulukko['$i:$y'] == merkki) {
          voittavarivi.add('$i:$y');
          laskuKaynnissa = true;
        } else if (laskuKaynnissa) {
          voittavarivi.clear();
        }

        if (voittavarivi.length == _merkkiaPerakkain) {
          _naytaVoittavarivi(voittavarivi);
        }
        i++;
      }

      laskuKaynnissa = false;
      voittavarivi.clear();
      i = j + 2;
    }
  }

  void _tarkastusLounas(String merkki) {
    var laskuKaynnissa = false;
    var voittavarivi = [];

    // 8:0 7:1 6:2 5:3 4:4 3:5 2:6 1:7 0:8  //keskilinja -> alas asti
    // 8:1 7:2 6:3 5:4 4:5 3:6 2:7 1:8      // yksi alaspäin
    for (var j = 0; j < _koko; j++) {
      var i = _koko - 1;
      var y = j;
      while ((i - j) >= 0) {
        // print('$i:$y');
        if (_taulukko['$i:$y'] == merkki) {
          voittavarivi.add('$i:$y');
          laskuKaynnissa = true;
        } else if (laskuKaynnissa) {
          voittavarivi.clear();
        }

        if (voittavarivi.length == _merkkiaPerakkain) {
          _naytaVoittavarivi(voittavarivi);
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
    for (var j = 0; j < _koko; j++) {
      var i = _koko - 2 - j;
      var y = 0;
      while (i >= 0) {
        //print('$i:$y');
        if (_taulukko['$i:$y'] == merkki) {
          voittavarivi.add('$i:$y');
          laskuKaynnissa = true;
        } else if (laskuKaynnissa) {
          voittavarivi.clear();
        }

        if (voittavarivi.length == _merkkiaPerakkain) {
          _naytaVoittavarivi(voittavarivi);
        }
        i--;
        y++;
      }

      laskuKaynnissa = false;
      voittavarivi.clear();
    }
  }
}
