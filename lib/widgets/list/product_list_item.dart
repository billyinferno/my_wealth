import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class ProductListItem extends StatelessWidget {
  final Color bgColor;
  final String title;
  final String? subTitle;
  final double value;
  final double cost;
  final double total;
  final double? realised;
  final double? unrealised;
  final double? dayGain;
  final double? netAssetValue;
  final double? oneDay;
  final VoidCallback? onTap;

  const ProductListItem({super.key, required this.bgColor, required this.title, this.subTitle, required this.value, required this.cost, required this.total, this.realised, this.unrealised, this.dayGain, this.netAssetValue, this.oneDay, this.onTap});

  @override
  Widget build(BuildContext context) {
    double? itemPercentage;
    double unrealisedGain = (unrealised ?? value - cost);
    Color unrealisedColor = Colors.white;
    Color realisedColor = Colors.white;
    Color dayColor = Colors.white;
    double gainPercentage = 0;

    // if we got total then we can compute the percentage, otherwise we should avoid divisio by zero
    if (total > 0) {
      itemPercentage = (value / total);
    }

    // check if we got cost or not?
    if (cost > 0) {
      // calculate the gain percentage
      gainPercentage = unrealisedGain / cost;
    }

    // check if gain if more than 0 or not?
    if (unrealisedGain > 0) {
      unrealisedColor = Colors.green;
    }
    else if(unrealisedGain < 0) {
      unrealisedColor = secondaryColor;
    }

    if (realised != null) {
      if (realised! < 0) {
        realisedColor = secondaryColor;
      }
      else if (realised! > 0) {
        realisedColor = Colors.green;
      }
    }

    if (dayGain != null) {
      if (dayGain! < 0) {
        dayColor = secondaryColor;
      }
      else if (dayGain! > 0) {
        dayColor = Colors.green;
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
                  padding: const EdgeInsets.fromLTRB(10, 10, 2, 10),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                formatCurrencyWithNull(
                                  value,
                                  showDecimal: false,
                                  shorten: false
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${
                              formatDecimalWithNull(
                                itemPercentage,
                                times: 100,
                                decimal: 2,
                              )
                            }%",
                            style: const TextStyle(
                              fontSize: 10,
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
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5,),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _priceItem(
                                netAssetValue: netAssetValue,
                                oneDay: oneDay
                              )
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                _subHeader(header: "UNREALISED GAIN"),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      formatCurrency(
                                        unrealisedGain,
                                        showDecimal: false,
                                        shorten: false
                                      ),
                                      style: TextStyle(
                                        color: unrealisedColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 2,),
                                    Text(
                                      "(${
                                        formatDecimalWithNull(
                                          (gainPercentage < 0 ? gainPercentage * -1 : gainPercentage),
                                          times: 100,
                                          decimal: 0,
                                        )
                                      }%)",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: unrealisedColor,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 15,),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                _subHeader(header: "REALISED GAIN"),
                                Text(
                                  formatCurrencyWithNull(
                                    (realised ?? 0),
                                    showDecimal: false,
                                    shorten: false
                                  ),
                                  style: TextStyle(
                                    color: realisedColor,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 15,),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                _subHeader(
                                  header: "DAY GAIN",
                                  align: Alignment.centerRight
                                ),
                                Text(
                                  formatCurrency(
                                    (dayGain ?? 0),
                                    showDecimal: false,
                                    shorten: false
                                  ),
                                  style: TextStyle(
                                    color: dayColor,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
              ),
              const SizedBox(width: 5,),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceItem({required double? netAssetValue, required double? oneDay}) {
    // if both netAssetValue and oneDay not null then return the widget otherwise
    // just return a SizedBox
    if (netAssetValue != null || oneDay != null) {
      IconData priceIcon = Ionicons.remove;
      Color priceColor = textPrimary;

      if (oneDay! < 0) {
        priceIcon = Ionicons.caret_down;
        priceColor = secondaryColor;
      }
      else {
        priceIcon = Ionicons.caret_up;
        priceColor = Colors.green;
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            priceIcon,
            color: priceColor,
            size: 13,
          ),
          const SizedBox(width: 5,),
          Text(
            formatCurrencyWithNull(
              netAssetValue,
              showDecimal: true,
              shorten: false,
              decimalNum: 2,
            ),
            style: const TextStyle(
              color: textPrimary,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 5,),
          Text(
            "(${
              formatDecimalWithNull(
                oneDay,
                times: 100,
                decimal: 2,
              )
            }%)",
            style: TextStyle(
              color: priceColor,
              fontSize: 10,
            ),
          ),
        ],
      );
    }

    // return SizedBox
    return const SizedBox.shrink();
  }

  Widget _subHeader({required String header, Alignment? align}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
      child: Align(
        alignment: (align ?? Alignment.centerLeft),
        child: Text(
          header,
          style: const TextStyle(
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}