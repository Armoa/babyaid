import 'package:flutter/material.dart';

class AppColors {
  static const Color grisOscuro = Color.fromARGB(255, 88, 111, 125);
  static const Color grisClaro = Color.fromARGB(255, 168, 178, 180);
  static const Color rosadoPastel = Color.fromARGB(255, 240, 213, 204);
  static const Color blancoLight = Color.fromARGB(255, 250, 250, 250);

  static const Color blueLight = Color.fromARGB(255, 165, 189, 222);
  static const Color blueAcua = Color.fromARGB(255, 62, 189, 222);
  static const Color blueSky = Color.fromARGB(255, 0, 153, 255);
  static const Color blueDark = Color.fromARGB(255, 0, 33, 107);
  static const Color blueBlak = Color.fromARGB(255, 38, 48, 72);
  static const Color graySoft = Color.fromARGB(255, 79, 93, 128);
  static const Color grayLight = Color.fromARGB(255, 230, 231, 231);
  static const Color grayDark = Color.fromARGB(255, 55, 55, 55);
  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color green = Color.fromARGB(255, 82, 182, 141);
  static const Color greenDark = Color.fromARGB(255, 2, 82, 6);
  static const Color greenLight = Color.fromARGB(255, 215, 247, 232);
  static const Color greenStandar = Color.fromARGB(255, 50, 186, 120);
}

List<Color> backgroundColors = [
  const Color.fromARGB(255, 224, 238, 241),
  const Color.fromARGB(255, 245, 224, 185),
  const Color.fromARGB(255, 255, 196, 152),
  const Color.fromARGB(255, 203, 220, 168),
  const Color.fromARGB(255, 240, 174, 175),
  const Color.fromARGB(255, 244, 226, 124),
  const Color.fromARGB(255, 234, 245, 211),
];

Color getSequentialColor(int index) {
  return backgroundColors[index % backgroundColors.length];
}
