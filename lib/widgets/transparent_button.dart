import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class TransparentButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback callback;
  final bool? active;
  const TransparentButton({ Key? key, required this.text, required this.icon, required this.callback, this.active }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _active = (active ?? false);

    return Expanded(
      child: MaterialButton(
        onPressed: (() {
          callback();
        }),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 18,
              ),
              const SizedBox(width: 10,),
              Text(
                text,
                style: const TextStyle(
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          side: BorderSide(
            color: primaryLight,
            style: BorderStyle.solid,
            width: 1.0,
          ),
        ),
        color: (_active ? secondaryColor : Colors.transparent),
      ),
    );
  }
}