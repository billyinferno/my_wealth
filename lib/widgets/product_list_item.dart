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
  final double? realised;
  final VoidCallback? onTap;

  const ProductListItem({Key? key, required this.bgColor, required this.title, this.subTitle, required this.value, required this.cost, required this.total, this.realised, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? itemPercentage;
    double gain = value - cost;
    Color trendColor = Colors.white;
    Color realisedColor = Colors.white;
    IconData trendIcon = Ionicons.remove;
    double gainPercentage = 0;
    double? realisedPercentage;

    // if we got total then we can compute the percentage, otherwise we should avoid divisio by zero
    if (total > 0) {
      itemPercentage = (value / total);
    }

    // check if we got cost or not?
    if (cost > 0) {
      // calculate the gain percentage
      gainPercentage = gain / cost;
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

    if (realised != null) {
      // when calculate the realised percentage, check if we have cost or not?
      if (cost > 0) {
        realisedPercentage = realised! / cost;
      }
      else {
        // means we don't have this product anymore
        // so just set the realised as 100%
        realisedPercentage = null;
      }

      if (realised! < 0) {
        realisedColor = secondaryColor;
      }
      else if (realised! > 0) {
        realisedColor = Colors.green;
      }
    }

    return InkWell(
      onTap: (() {
        if (onTap != null) {
          onTap!();
        }
      }),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: primaryLight,
              width: 1.0,
              style: BorderStyle.solid,
            )
          )
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: bgColor,
                width: 10,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // main container
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            // this is the title
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5,),
                                Text(
                                  formatCurrencyWithNull(value, false, false, false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5,),
                            // this is the percentage
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "${formatDecimalWithNull(itemPercentage, 100, 2)}%",
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 5,),
                                Visibility(
                                  visible: (subTitle == null ? false : true),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      const Icon(
                                        Ionicons.ellipse,
                                        size: 5,
                                      ),
                                      const SizedBox(width: 5,),
                                      Text(
                                        subTitle ?? '',
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
                                      _productItem(
                                        icon: trendIcon,
                                        iconColor: trendColor,
                                        text: "${formatCurrencyWithNull(gain, false, false, false)} (${formatDecimalWithNull(gainPercentage, 100, 2)}%)",
                                        textColor: trendColor
                                      ),
                                      const SizedBox(height: 5,),
                                      _productItem(
                                        icon: Ionicons.wallet_outline,
                                        iconColor: realisedColor,
                                        text: "${formatCurrencyWithNull((realised ?? 0), false, false, false)} (${formatDecimalWithNull(realisedPercentage, 100, 2)}%)",
                                        textColor: realisedColor
                                      ),
                                    ],
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
                          child: Center(
                            child: Icon(
                              Ionicons.chevron_forward,
                              color: primaryLight,
                            ),
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
      ),
    );
  }

  Widget _productItem({required IconData icon, required Color iconColor, required String text, required Color textColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Icon(
          icon,
          color: iconColor,
          size: 15,
        ),
        const SizedBox(width: 5,),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}