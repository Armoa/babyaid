import 'package:flutter/material.dart';

class AppColors {
  static const Color primario = Color.fromARGB(255, 30, 200, 200);
  static const Color secundario = Color.fromARGB(255, 10, 130, 130);
  static const Color terciario = Color.fromARGB(255, 240, 190, 210);
  static const Color extra = Color.fromARGB(255, 30, 200, 200);
  static const Color black = Color.fromARGB(255, 25, 25, 25);
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
