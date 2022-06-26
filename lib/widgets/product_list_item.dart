import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/format_currency.dart';

class ProductListItem extends StatelessWidget {
  final Color bgColor;
  final String title;
  final String? subTitle;
  final double value;
  final double cost;
  final double total;
  final VoidCallback? onTap;

  const ProductListItem({Key? key, required this.bgColor, required this.title, this.subTitle, required this.value, required this.cost, required this.total, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? itemPercentage;
    double gain = value - cost;
    Color trendColor = Colors.white;
    IconData trendIcon = Ionicons.remove;

    // if we got total then we can compute the percentage, otherwise we should avoid divisio by zero
    if (total > 0) {
      itemPercentage = (value / total);
    }

    // check if gain if more than 0 or not?
    if (gain > 0) {
      trendColor = Colors.green;
      trendIcon = Ionicons.trending_up;
    }
    else if(gain < 0) {
      trendColor = secondaryColor;
      trendIcon = Ionicons.trending_down;
    }
    
    return InkWell(
      onTap: (() {
        // check if we can tap the widget or not?
        if (onTap != null) {
          onTap!();
        }
      }),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: const Border(
            bottom: BorderSide(
              color: primaryLight,
              style: BorderStyle.solid,
              width: 1.0,
            )
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 10,),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                color: primaryColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5,),
                          Text(
                            "${formatDecimalWithNull(itemPercentage, 100, 2)}% ${subTitle ?? ''}",
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            formatCurrencyWithNull(value, false, false, false),
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(
                                trendIcon,
                                color: trendColor,
                                size: 15,
                              ),
                              const SizedBox(width: 5,),
                              Text(
                                formatCurrencyWithNull(gain, false, false, false),
                                style: TextStyle(
                                  color: trendColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: (onTap != null),
                      child: const SizedBox(
                        width: 20,
                        child: Icon(
                          Ionicons.chevron_forward,
                          color: primaryLight,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}