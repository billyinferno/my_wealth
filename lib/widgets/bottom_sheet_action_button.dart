import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class BottomSheetActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const BottomSheetActionButton({ Key? key, required this.child, required this.onTap }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() {
        onTap();
      }),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1.0,
              color: primaryLight,
              style: BorderStyle.solid,
            )
          )
        ),
        width: double.infinity,
        child: Align(
          alignment: Alignment.center,
          child: child
        ),
      ),
    );
  }
}