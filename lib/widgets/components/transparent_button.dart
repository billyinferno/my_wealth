import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class TransparentButton extends StatelessWidget {
  final String text;
  final double textSize;
  final Color textColor;
  final IconData icon;
  final double iconSize;
  final VoidCallback callback;
  final bool active;
  final bool vertical;
  final Color activeColor;
  final Color bgColor;
  final Color borderColor;
  // TODO: to add enabled handling on the transparent button
  final bool enabled;
  const TransparentButton({
    super.key,
    this.text = "",
    this.textSize = 12,
    this.textColor = textPrimary,
    required this.icon,
    this.iconSize = 18,
    required this.callback,
    this.active = false,
    this.vertical = false,
    this.activeColor = secondaryColor,
    this.bgColor = Colors.transparent,
    this.borderColor = primaryLight,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: (() {
          callback();
        }),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          decoration: BoxDecoration(
            color: (active ? activeColor : bgColor),
            border: Border.all(
              color: borderColor,
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