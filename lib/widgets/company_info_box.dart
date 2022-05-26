import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';

class CompanyInfoBox extends StatelessWidget {
  final String header;
  final Color? headerColor;
  final TextAlign? headerAlign;
  final Widget child;
  
  const CompanyInfoBox({Key? key, required this.header, this.headerColor, this.headerAlign, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color currentHeaderColor = (headerColor ?? textPrimary);
    TextAlign currentHeaderAlign = (headerAlign ?? TextAlign.left);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
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
            child: Text(
              header,
              textAlign: currentHeaderAlign,
              style: TextStyle(
                color: currentHeaderColor,
                fontWeight: FontWeight.bold,
              ),
            )
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
