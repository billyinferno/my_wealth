import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';

class CompareFields extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String text;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final bool? showCompare;
  final bool? isBigger;
  const CompareFields({
    Key? key,
    required this.color,
    required this.borderColor,
    required this.text,
    this.fontWeight,
    this.textAlign,
    this.showCompare,
    this.isBigger
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool currentShowCompare = (showCompare ?? false);
    bool currentIsBigger = (isBigger ?? false);

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              (currentIsBigger ? Ionicons.caret_up : Ionicons.caret_down),
              size: 10,
              color: (currentIsBigger ? Colors.green : secondaryLight),
            )
          )
        ],
      ),
    );
  }
}