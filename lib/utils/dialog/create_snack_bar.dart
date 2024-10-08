import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

SnackBar createSnackBar({
  required String message,
  Icon icon = const Icon(
    Ionicons.alert_circle_outline,
    size: 20,
    color: secondaryDark,
  ),
  int duration = 3
}) {
  return SnackBar(
    duration: Duration(seconds: duration),
    backgroundColor: primaryDark,
    showCloseIcon: true,
    closeIconColor: primaryLight,
    behavior: SnackBarBehavior.floating,
    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
    content: Container(
      height: 25,
      color: primaryDark,
      child: Row(
        children: <Widget>[
          icon,
          const SizedBox(width: 10,),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontFamily: '--apple-system'
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}