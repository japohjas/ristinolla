import 'dart:html';
import 'lib/Taulu.dart';
/*
8.10.2020 Jari Pohjasmäki japohjas@gmail.com
Taulun piirto ja tarkastus automaattinen.
Taulun koko valittavissa.
Kuinka monta merkkiä pitää saada peräkkäin valittavissa.
koko = taulun koko
merkit = kuinka monta merkkiä tarvitaan peräkkäin että peli päättyy
14.10.2020 v2.0
*/

void main() {
  final _peli = {
    'koko': ['3', '5', '7', '9', '11', '13', '15', '17', '19', '21', '23'],
    'merkit': ['3', '4', '5', '6', '7']
  };

  _aloita(_peli);
}

void _aloita(peli) {
  for (var i = 0; i < peli['koko'].length; i++) {
    OptionElement elementti = Element.option();
    elementti.text = 'Taulun koko: ${peli['koko'][i]}x${peli['koko'][i]}';
    elementti.value = peli['koko'][i];
    querySelector('#taulunKoko').children.add(elementti);
  }

  for (var i = 0; i < peli['merkit'].length; i++) {
    OptionElement elementti = Element.option();
    elementti.text = 'Merkkiä peräkkäin: ${peli['merkit'][i]}';
    elementti.value = peli['merkit'][i];
    querySelector('#merkkienmaara').children.add(elementti);
  }

  querySelector('#aloita').onClick.listen((event) {
    SelectElement taulunKoko = querySelector('#taulunKoko');
    var koko = int.parse(taulunKoko.value);

    SelectElement merkkienmaara = querySelector('#merkkienmaara');
    var merkkiaPerakkain = int.parse(merkkienmaara.value);

    var taulu = Taulu(koko, merkkiaPerakkain);
    taulu.alustaTaulu();
  });
}
