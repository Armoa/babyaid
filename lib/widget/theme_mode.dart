import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';

ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.green,
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    elevation: 0.0,
    backgroundColor: AppColors.green,
    surfaceTintColor: Colors.transparent,
    toolbarHeight: 80,
    centerTitle: true,
    titleTextStyle: TextStyle(color: AppColors.grayLight, fontSize: 20),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
);

ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.grayDark,
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    surfaceTintColor: Colors.transparent,
    backgroundColor: Colors.black,
    centerTitle: true,

    iconTheme: IconThemeData(color: AppColors.grayLight),

    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
);
