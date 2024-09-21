import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class TransparentButton extends StatelessWidget {
  final String text;
  final double textSize;
  final Color textColor;
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;
  final Color color;
  final Color activeColor;
  final Color? borderColor;
  final Color disabledColor;
  final bool active;
  final bool vertical;
  final bool enabled;
  const TransparentButton({
    super.key,
    this.text = "",
    this.textSize = 12,
    this.textColor = textPrimary,
    required this.icon,
    this.iconSize = 18,
    required this.onTap,
    this.color = Colors.transparent,
    this.activeColor = secondaryColor,
    this.borderColor,
    this.disabledColor = primaryLight,
    this.active = false,
    this.vertical = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: (() {
          // check whether the button is enabled or not
          if (enabled) {
            // call the callback if enabled
            onTap();
          }
        }),
        splashColor: activeColor,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          decoration: BoxDecoration(
            color: (enabled ? (active ? activeColor : color) : disabledColor),
            border: Border.all(
              color: (borderColor ?? color),
              style: BorderStyle.solid,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    size: iconSize,
                    color: textColor,
                  ),
                  Visibility(
                    visible: text.isNotEmpty && !vertical,
                    child: const SizedBox(width: 10,)
                  ),
                  Visibility(
                    visible: text.isNotEmpty && !vertical,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: textSize,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: text.isNotEmpty && vertical,
                child: const SizedBox(height: 5,),
              ),
              Visibility(
                visible: text.isNotEmpty && vertical,
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: textSize,
                    overflow: TextOverflow.ellipsis,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}