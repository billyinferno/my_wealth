import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/extensions/decimal_formater.dart';

class WatchlistDetailCreateTextFields extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final int? decimal;
  final int? limit;

  const WatchlistDetailCreateTextFields({
    Key? key,
    required this.controller,
    required this.title,
    this.decimal,
    this.limit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int dec = (decimal ?? 4);
    int lim = (limit ?? 12);

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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: secondaryLight,
            ),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: TextFormField(
              controller: controller,
              showCursor: true,
              cursorColor: secondaryColor,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              keyboardAppearance: Brightness.dark,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusColor: secondaryColor,
                hintText: "0.00",
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(lim),
                DecimalTextInputFormatter(decimalRange: dec),
              ],
            ),
          ),
        ],
      ),
    );
  }
}