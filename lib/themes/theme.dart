import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

ThemeData themeData = ThemeData(
  fontFamily: '--apple-system',
  brightness: Brightness.dark,
  backgroundColor: primaryColor,
  appBarTheme: const AppBarTheme(backgroundColor: primaryDark),
  scaffoldBackgroundColor: primaryColor,
  primaryColor: primaryColor,
  //accentColor: accentColors[0],
  iconTheme: const IconThemeData().copyWith(color: textPrimary),
  // fontFamily: 'Roboto',
  textTheme: const TextTheme(
    headline2: TextStyle(
      color: textPrimary,
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
    ),
    headline4: TextStyle(
      color: textPrimary,
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 2.0,
    ),
    bodyText1: TextStyle(
      color: textPrimary,
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),
    bodyText2: TextStyle(
      color: textPrimary,
      letterSpacing: 1.0,
    ),
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