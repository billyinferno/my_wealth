import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';

SnackBar createSnackBar({required String message, Icon? icon, int? duration}) {
  Icon _snackBarIcon = (icon ?? const Icon(Ionicons.alert_circle_outline, size: 20, color: secondaryDark,));
  int _duration = (duration ?? 3);

  SnackBar snackBar = SnackBar(
    duration: Duration(seconds: _duration),
    backgroundColor: primaryDark,
    content: Container(
      height: 25,
      color: primaryDark,
      child: Row(
        children: <Widget>[
          _snackBarIcon,
          const SizedBox(width: 10,),
          Text(
            message,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  );

  return snackBar;
}