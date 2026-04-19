import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:my_wealth/utils/icon/my_ionicons.dart';

SnackBar createSnackBar({
  required String message,
  Icon? icon,
  int duration = 3
}) {
  Icon currentIcon = (icon ?? Icon(MyIonicons(MyIoniconsData.information_circle_outline).data, color: primaryLight, size: 20,));
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
          currentIcon,
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