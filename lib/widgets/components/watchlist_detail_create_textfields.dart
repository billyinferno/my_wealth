import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistDetailCreateTextFields extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String? subTitle;
  final int? decimal;
  final int? limit;
  final String? hintText;
  final double? defaultPrice;

  const WatchlistDetailCreateTextFields({
    super.key,
    required this.controller,
    required this.title,
    this.subTitle,
    this.decimal,
    this.limit,
    this.hintText,
    this.defaultPrice,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: secondaryLight,
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Visibility(
                    visible: (defaultPrice != null),
                    child: InkWell(
                      onDoubleTap: (() {
                        controller.text = formatDecimal(defaultPrice ?? 0);
                      }),
                      child: Container(
                        width: 20,
                        height: 20,
                        color: Colors.transparent,
                        child: const Icon(
                          Ionicons.locate_outline,
                          size: 15,
                          color: primaryLight,
                        ),
                      ),
                    )
                  ),
                ],
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
                hintStyle: const TextStyle(
                  color: primaryLight,
                  fontStyle: FontStyle.italic,
                )
              ),
              inputFormatters: formatter,
            ),
          ),
        ],
      ),
    );
  }
}