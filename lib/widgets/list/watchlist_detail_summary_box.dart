import 'package:flutter/material.dart';

class WatchlistDetailSummaryBox extends StatelessWidget {
  final String title;
  final String text;
  const WatchlistDetailSummaryBox({ Key? key, required this.title, required this.text }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
          Text(text),
        ],
      )
    );
  }
}