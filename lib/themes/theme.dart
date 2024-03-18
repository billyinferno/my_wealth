import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

ThemeData themeData = ThemeData(
  fontFamily: '--apple-system',
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(backgroundColor: primaryDark),
  scaffoldBackgroundColor: primaryColor,
  splashColor: primaryColor,
  primaryColor: primaryColor,
  dividerColor: primaryLight,
  //accentColor: accentColors[0],
  iconTheme: const IconThemeData().copyWith(color: textPrimary),
  // fontFamily: 'Roboto',
  textTheme: const TextTheme(
    displayMedium: TextStyle(
      color: textPrimary,
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: textPrimary,
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 2.0,
    ),
    bodyLarge: TextStyle(
      color: textPrimary,
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),
    bodyMedium: TextStyle(
      color: textPrimary,
      letterSpacing: 1.0,
    ),
  ), colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    error: secondaryColor,
    onError: textPrimary,
    onPrimary: textPrimary,
    onSecondary: textPrimary,
    onSurface: textPrimary,
    primary: secondaryColor,
    secondary: secondaryDark,
    surface: primaryColor,
  ),
);

CupertinoThemeData cupertinoThemeData = const CupertinoThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  primaryContrastingColor: primaryDark,
  textTheme: CupertinoTextThemeData(
    textStyle: TextStyle(
      fontFamily: '--apple-system',
      color: textPrimary,
    ),
    actionTextStyle: TextStyle(
      fontFamily: '--apple-system',
      color: textPrimary,
    ),
  )
);