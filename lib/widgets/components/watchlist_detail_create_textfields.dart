import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/extensions/decimal_formater.dart';

class WatchlistDetailCreateTextFields extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String? subTitle;
  final int? decimal;
  final int? limit;
  final String? hintText;

  const WatchlistDetailCreateTextFields({
    super.key,
    required this.controller,
    required this.title,
    this.subTitle,
    this.decimal,
    this.limit,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    int dec = (decimal ?? 4);
    int lim = (limit ?? 12);
    String? currHintText = (hintText ?? "0.00");
    String currSubTitle = (subTitle ?? "");
    bool isDecimal = (dec > 0 ? true : false);

    List<TextInputFormatter> formatter = [];
    formatter.add(LengthLimitingTextInputFormatter(lim));
    if (dec > 0) {
      formatter.add(DecimalTextInputFormatter(decimalRange: dec));
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: primaryLight,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: secondaryLight,
                ),
              ),
              Visibility(
                visible: currSubTitle.isNotEmpty,
                child: Text(
                  currSubTitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: primaryLight
                  ),
                )
              ),
            ],
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: TextFormField(
              controller: controller,
              showCursor: true,
              cursorColor: secondaryColor,
              keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
              keyboardAppearance: Brightness.dark,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusColor: secondaryColor,
                hintText: currHintText,
              ),
              inputFormatters: formatter,
            ),
          ),
        ],
      ),
    );
  }
}