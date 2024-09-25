import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class UserButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String text;
  final String? subText;
  final Function? onTap;
  final Widget trailing;

  const UserButton({
    super.key,
    required this.icon,
    this.iconColor = secondaryColor,
    this.iconSize = 20,
    required this.text,
    this.subText,
    this.onTap,
    this.trailing = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: primaryColor,
      onTap: (() {
        if (onTap != null) {
          onTap!();
        }
      }),
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: primaryLight,
              width: 1.0,
              style: BorderStyle.solid,
            ),
          )
        ),
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        icon,
                        color: iconColor,
                        size: iconSize,
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              text,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Visibility(
                              visible: (subText != null),
                              child: Text(
                                (subText ?? ''),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: primaryLight,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10,),
                      trailing,
                    ],
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}