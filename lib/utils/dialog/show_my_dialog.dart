import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class ShowMyDialog {
  final String? title;
  final String? text;
  final String? confirmLabel;
  final String? cancelLabel;
  Color? confirmColor;
  Color? cancelColor;

  ShowMyDialog({this.title, this.text, this.confirmLabel, this.confirmColor, this.cancelLabel});

  Future<bool?> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: ((BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title ?? "Confirmation",
            style: const TextStyle(
              fontFamily: '--apple-system',
            ),
          ),
          content: Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              text ?? "Are you sure?",
              style: const TextStyle(
                fontFamily: '--apple-system',
              ),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: (() {
                Navigator.pop(context, true);
              }),
              child: Text(
                confirmLabel ?? "Confirm",
                style: TextStyle(
                  fontFamily: '--apple-system',
                  color: (confirmColor ?? textPrimary)
                ),
              ),
            ),
            CupertinoDialogAction(
              onPressed: (() {
                Navigator.pop(context, false);
              }),
              child: Text(
                cancelLabel ?? "Cancel",
                style: TextStyle(
                  fontFamily: '--apple-system',
                  color: (cancelColor ?? textPrimary),
                ),
              ),
            ),
          ],
        );
      })
    );
  }
}