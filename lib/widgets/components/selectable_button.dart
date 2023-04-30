import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class SelectableButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onPress;

  const SelectableButton({Key? key, required this.text, required this.selected, this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() {
        // check if not null
        if (onPress != null) {
          onPress!();
        }
      }),
      child: Container(
        height: 25,
        width: 25,
        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: (selected ? secondaryColor : Colors.transparent),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: (selected ? textPrimary : secondaryColor),
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}