import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

SnackBar createSnackBar({required String message, Icon? icon, int? duration}) {
  Icon snackBarIcon = (icon ?? const Icon(Ionicons.alert_circle_outline, size: 20, color: secondaryDark,));
  int animationDuration = (duration ?? 3);

  SnackBar snackBar = SnackBar(
    duration: Duration(seconds: animationDuration),
    backgroundColor: primaryDark,
    content: Container(
      height: 25,
      color: primaryDark,
      child: Row(
        children: <Widget>[
          snackBarIcon,
          const SizedBox(width: 10,),
          Text(
            message,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 15,
              fontFamily: '--apple-system'
            ),
          ),
        ],
      ),
    ),
  );

  return snackBar;
}