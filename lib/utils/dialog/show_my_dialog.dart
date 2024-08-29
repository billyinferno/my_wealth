import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class ShowMyDialog {
  final String title;
  final String text;
  final String confirmLabel;
  final String cancelLabel;
  Color confirmColor;
  Color cancelColor;

  ShowMyDialog({
    this.title = "Confirmation",
    this.text = "Are you sure?",
    this.confirmLabel = "Confirm",
    this.confirmColor = textPrimary,
    this.cancelLabel = "Cancel",
    this.cancelColor = secondaryColor,
  });

  Future<bool?> show(BuildContext context) {
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
                confirmLabel,
                style: TextStyle(
                  fontFamily: '--apple-system',
                  color: confirmColor
                ),
              ),
            ),
            CupertinoDialogAction(
              onPressed: (() {
                Navigator.pop(context, false);
              }),
              child: Text(
                cancelLabel,
                style: TextStyle(
                  fontFamily: '--apple-system',
                  color: cancelColor,
                ),
              ),
            ),
          ],
        );
      })
    );
  }
}