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

    if (realised != null) {
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
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${formatDecimalWithNull(itemPercentage, 100, 2)}%",
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 5,),
                                Visibility(
                                  visible: (subTitle == null ? false : true),
                                  child: const Icon(
                                    Ionicons.ellipse,
                                    size: 5,
                                  )
                                ),
                                const SizedBox(width: 5,),
                                Visibility(
                                  visible: (subTitle == null ? false : true),
                                  child: Text(
                                    subTitle ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Expanded(
                        flex: 2,
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
                            Visibility(
                              visible: (realised == null ? false : true),
                              child: const SizedBox(height: 5,)
                            ),
                            Visibility(
                              visible: (realised == null ? false : true),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(
                                    Ionicons.wallet_outline,
                                    color: realisedColor,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5,),
                                  Text(
                                    formatCurrencyWithNull(realised, false, false, false),
                                    style: TextStyle(
                                      color: realisedColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
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
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}