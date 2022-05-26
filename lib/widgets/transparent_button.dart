import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class TransparentButton extends StatelessWidget {
  final String? text;
  final IconData icon;
  final VoidCallback callback;
  final bool? active;
  final bool? vertical;
  const TransparentButton({ Key? key, this.text, required this.icon, required this.callback, this.active, this.vertical }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isActive = (active ?? false);
    String buttonText = (text ?? "");
    bool isVertical = (vertical ?? false);

    return Expanded(
      child: MaterialButton(
        onPressed: (() {
          callback();
        }),
        shape: const RoundedRectangleBorder(
          side: BorderSide(
            color: primaryLight,
            style: BorderStyle.solid,
            width: 1.0,
          ),
        ),
        color: (isActive ? secondaryColor : Colors.transparent),
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
                    size: 18,
                  ),
                  Visibility(visible: buttonText.isNotEmpty && !isVertical, child: const SizedBox(width: 10,)),
                  Visibility(
                    visible: buttonText.isNotEmpty && !isVertical,
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: textPrimary,
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
                  style: const TextStyle(
                    color: textPrimary,
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