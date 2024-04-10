import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';

class CompanyInfoBox extends StatelessWidget {
  final String header;
  final Color? headerColor;
  final MainAxisAlignment? headerAlign;
  final Widget child;
  final VoidCallback? onTap;
  
  const CompanyInfoBox({super.key, required this.header, this.headerColor, this.headerAlign, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color currentHeaderColor = (headerColor ?? textPrimary);
    MainAxisAlignment currentHeaderAlign = (headerAlign ?? MainAxisAlignment.end);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (() {
              if(onTap != null) {
                onTap!();
              }
            }),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: primaryLight,
                    width: 1.0,
                    style: BorderStyle.solid,
                  )
                )
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: currentHeaderAlign,
                children: [
                  Expanded(
                    child: Text(
                      header,
                      style: TextStyle(
                        color: currentHeaderColor,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Visibility(
                    visible: (onTap != null),
                    child: const SizedBox(width: 5,),
                  ),
                  Visibility(
                    visible: (onTap != null),
                    child: const Icon(
                      Ionicons.information_circle,
                      color: accentLight,
                      size: 15,
                    )
                  ),
                ],
              )
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: child,
          ),
        ],
      ),
    );
  }
}
