import 'package:bebito/model/colors.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.grisOscuro,
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    elevation: 0.0,
    backgroundColor: AppColors.grisOscuro,
    surfaceTintColor: Colors.transparent,
    toolbarHeight: 80,
    centerTitle: true,
    titleTextStyle: TextStyle(color: AppColors.grisClaro, fontSize: 20),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.grisOscuro),
);

ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.grisClaro,
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    surfaceTintColor: Colors.transparent,
    backgroundColor: Colors.black,
    centerTitle: true,

    iconTheme: IconThemeData(color: AppColors.grisClaro),

    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
);
