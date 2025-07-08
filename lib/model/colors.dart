import 'package:flutter/material.dart';

class AppColors {
  static const Color blueLight = Color.fromARGB(255, 165, 189, 222);
  static const Color blueAcua = Color.fromARGB(255, 62, 189, 222);
  static const Color blueSky = Color.fromARGB(255, 0, 153, 255);
  static const Color blueDark = Color.fromARGB(255, 0, 33, 107);
  static const Color blueBlak = Color.fromARGB(255, 38, 48, 72);
  static const Color graySoft = Color.fromARGB(255, 79, 93, 128);
  static const Color grayLight = Color.fromARGB(255, 230, 231, 231);
  static const Color grayDark = Color.fromARGB(255, 35, 35, 35);
  static const Color white = Color.fromARGB(255, 255, 255, 255);
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
