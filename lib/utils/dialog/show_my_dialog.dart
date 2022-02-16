import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowMyDialog {
  final String? title;
  final String? text;
  final String? confirmLabel;
  final String? cancelLabel;

  ShowMyDialog({this.title, this.text, this.confirmLabel, this.cancelLabel});

  Future<bool?> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: ((BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title ?? "Confirmation"),
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
              child: Text(
                confirmLabel ?? "Confirm",
                style: const TextStyle(
                  fontFamily: '--apple-system',
                ),
              ),
              isDefaultAction: true,
              onPressed: (() {
                Navigator.pop(context, true);
              }),
            ),
            CupertinoDialogAction(
              child: Text(
                cancelLabel ?? "Cancel",
                style: const TextStyle(
                  fontFamily: '--apple-system',
                ),
              ),
              onPressed: (() {
                Navigator.pop(context, false);
              }),
            ),
          ],
        );
      })
    );
  }
}