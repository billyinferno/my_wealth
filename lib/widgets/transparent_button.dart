import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class TransparentButton extends StatelessWidget {
  final String? text;
  final double? textSize;
  final Color? textColor;
  final IconData icon;
  final double? iconSize;
  final VoidCallback callback;
  final bool? active;
  final bool? vertical;
  final Color? activeColor;
  final Color? bgColor;
  final Color? borderColor;
  const TransparentButton({ Key? key, this.text, this.textSize, this.textColor, required this.icon, this.iconSize, required this.callback, this.active, this.vertical, this.activeColor, this.bgColor, this.borderColor }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double currentTextSize = (textSize ?? 12);
    double currentIconSize = (iconSize ?? 18);
    bool isActive = (active ?? false);
    String buttonText = (text ?? "");
    bool isVertical = (vertical ?? false);
    Color currentActiveColor = (activeColor ?? secondaryColor);
    Color currentBgColor = (bgColor ?? Colors.transparent);
    Color currentTextColor = (textColor ?? textPrimary);
    Color currentBorderColor = (borderColor ?? primaryLight);

    return Expanded(
      child: MaterialButton(
        onPressed: (() {
          callback();
        }),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: currentBorderColor,
            style: BorderStyle.solid,
            width: 1.0,
          ),
        ),
        color: (isActive ? currentActiveColor : currentBgColor),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                    size: currentIconSize,
                    color: currentTextColor,
                  ),
                  Visibility(visible: buttonText.isNotEmpty && !isVertical, child: const SizedBox(width: 10,)),
                  Visibility(
                    visible: buttonText.isNotEmpty && !isVertical,
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: currentTextColor,
                        fontSize: currentTextSize,
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: buttonText.isNotEmpty && isVertical,
                child: const SizedBox(height: 5,),
              ),
              Visibility(
                visible: buttonText.isNotEmpty && isVertical,
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: currentTextColor,
                    fontSize: currentTextSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}