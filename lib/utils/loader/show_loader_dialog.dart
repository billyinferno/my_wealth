import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_wealth/themes/colors.dart';

void showLoaderDialog(BuildContext context) {
  AlertDialog _alert = const AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Center(
      child: SpinKitCubeGrid(
        color: secondaryColor,
        size: 25,
      ),
    ),
  );

  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return _alert;
      }
  );
}