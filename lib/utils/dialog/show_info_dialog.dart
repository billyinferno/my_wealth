import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class ShowInfoDialog {
  final String title;
  final String text;
  final String okayLabel;
  Color okayColor;

  ShowInfoDialog({
    this.title = "Information",
    required this.text,
    this.okayLabel = "Okay",
    this.okayColor = textPrimary
  });

  Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: ((BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
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
                okayLabel,
                style: TextStyle(
                  fontFamily: '--apple-system',
                  color: okayColor
                ),
              ),
            ),
          ],
        );
      })
    );
  }
}