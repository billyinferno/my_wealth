import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class CompareFields extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String text;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final bool? showCompare;
  final double? isBigger;
  const CompareFields({
    super.key,
    required this.color,
    required this.borderColor,
    required this.text,
    this.fontWeight,
    this.textAlign,
    this.showCompare,
    this.isBigger
  });

  @override
  Widget build(BuildContext context) {
    bool currentShowCompare = (showCompare ?? false);
    double currentIsBigger = (isBigger ?? 0);

    IconData currentIcon = Ionicons.remove;
    Color currentColor = textPrimary;
    if (currentIsBigger < 0) {
      currentIcon = Ionicons.caret_down;
      currentColor = secondaryLight;
    }
    if (currentIsBigger > 0) {
      currentIcon = Ionicons.caret_up;
      currentColor = Colors.green;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.fromLTRB(2.5, 0, 2.5, 5),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: borderColor,
          width: 1.0,
          style: BorderStyle.solid,
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: (fontWeight ?? FontWeight.normal),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: (textAlign ?? TextAlign.start),
            ),
          ),
          Visibility(
            visible: currentShowCompare,
            child: Icon(
              currentIcon,
              size: 10,
              color: currentColor,
            )
          )
        ],
      ),
    );
  }
}