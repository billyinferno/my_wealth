import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class ShowInfoDialog {
  final String? title;
  final String text;
  final String? okayLabel;
  Color? okayColor;

  ShowInfoDialog({this.title, required this.text, this.okayLabel, this.okayColor});

  Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: ((BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title ?? "Information",
            style: const TextStyle(
              fontFamily: '--apple-system',
            ),
          ),
          content: Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              text,
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
                okayLabel ?? "Okay",
                style: TextStyle(
                  fontFamily: '--apple-system',
                  color: (okayColor ?? textPrimary)
                ),
              ),
            ),
          ],
        );
      })
    );
  }
}