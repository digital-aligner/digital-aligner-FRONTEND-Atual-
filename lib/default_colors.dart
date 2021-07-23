import 'package:flutter/material.dart';

class DefaultColors {
  static const Map<int, Color> digitalAlignBlueShades = {
    50: Color.fromRGBO(89, 203, 232, .1),
    100: Color.fromRGBO(89, 203, 232, .2),
    200: Color.fromRGBO(89, 203, 232, .3),
    300: Color.fromRGBO(89, 203, 232, .4),
    400: Color.fromRGBO(89, 203, 232, .5),
    500: Color.fromRGBO(89, 203, 232, .6),
    600: Color.fromRGBO(89, 203, 232, .7),
    700: Color.fromRGBO(89, 203, 232, .8),
    800: Color.fromRGBO(89, 203, 232, .9),
    900: Color.fromRGBO(89, 203, 232, 1),
  };
  static const MaterialColor digitalAlignBlue = MaterialColor(
    /*original-> 0xFF59cbe8*/ 0xFF54c2de,
    digitalAlignBlueShades,
  );
}
