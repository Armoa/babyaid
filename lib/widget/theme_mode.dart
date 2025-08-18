import 'package:bebito/model/colors.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.transparent,
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    elevation: 0.0,
    backgroundColor: AppColors.secundario,
    surfaceTintColor: Colors.transparent,
    toolbarHeight: 80,
    centerTitle: true,
    titleTextStyle: TextStyle(color: AppColors.primario, fontSize: 20),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.secundario),
);

ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.primario,
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    surfaceTintColor: Colors.transparent,
    backgroundColor: Colors.black,
    centerTitle: true,

    iconTheme: IconThemeData(color: AppColors.primario),

    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
);
