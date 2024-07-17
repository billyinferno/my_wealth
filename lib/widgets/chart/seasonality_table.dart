import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/model/company/company_seasonality_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';

class SeasonalityTableResult {
  final double averageDiffPrice;
  final double minAveragePrice;
  final double averageMinDiffPrice;
  final double maxAveragePrice;
  final double averageMaxDiffPrice;
  final double minLastPrice;
  final double averageMinLastPrice;
  final double maxLastPrice;
  final double averageMaxLastPrice;

  const SeasonalityTableResult({
    required this.averageDiffPrice,
    required this.minAveragePrice, required this.averageMinDiffPrice,
    required this.maxAveragePrice, required this.averageMaxDiffPrice,
    required this.minLastPrice, required this.averageMinLastPrice,
    required this.maxLastPrice, required this.averageMaxLastPrice,
  });
}

class SeasonalityTable extends StatelessWidget {
  final ScrollController? controllerVertical;
  final ScrollController? controllerHorizontal;
  final ScrollController? controller;
  final List<SeasonalityModel> data;
  final int? risk;
  const SeasonalityTable({
    super.key,
    this.controllerVertical,
    this.controllerHorizontal,
    this.controller,
    required this.data,
    this.risk,
  });

  @override
  Widget build(BuildContext context) {
    // first we will need to rearrange the data to Map<String, SeasonalityModel>
    Map<String, List<SeasonalityModel>> seasonalityData = _filterSeasonality();

    // now calculate the year average for each year we have
    Map<String, SeasonalityTableResult> seasonalityAverage = _computeSeasonalityAverage(seasonalityData);

    // generate the widget based on the seasonalityData
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _rowItem(
                      width: 65,
                      height: 50,
                      child: const Center(
                        child: Text(
                          "Month",
                        ),
                      ),
                    ),
                    ..._generateYearMenu(data: seasonalityData),
                  ],
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _generateMonthHeader(),
                        ..._generateSeasonalityItem(data: seasonalityData, average: seasonalityAverage),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _generateYearMenu({required Map<String, List<SeasonalityModel>> data}) {
    List<Widget> result = [];

    data.forEach((key, value) {
      result.add(
        _rowItem(
          width: 65,
          child: Center(
            child: Text(
              key,
            ),
          )
        )
      );
    });

    return result;
  }

  Widget _generateMonthHeader() {
    final DateFormat df = DateFormat("MMM");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ...List<Widget>.generate(12, (index) {
          return _rowItem(
            height: 50,
            child: Center(
              child: Text(
                df.format(DateTime(DateTime.now().year, (index + 1), 1)),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
        _rowItem(
          height: 50,
          child: const Center(
            child: Text(
              "Avg",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: accentColor
              ),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _generateSeasonalityItem({required Map<String, List<SeasonalityModel>> data, required Map<String, SeasonalityTableResult> average}) {
    List<Widget> result = [];
    
    // loop thru all the seasonality data
    data.forEach((key, value) {
      // create a _rowItem based on the length of the value
      result.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ..._generateSeasonlityYearlyItem(data: value),
            _rowItem(
              child: _seasonilityItem(
                diffPrice: average[key]!.averageDiffPrice,
                minDiffPrice: average[key]!.averageMinDiffPrice,
                minLastPrice: average[key]!.averageMinLastPrice,
                maxDiffPrice: average[key]!.averageMaxDiffPrice,
                maxLastPrice: average[key]!.averageMaxLastPrice),
              color: (
                average[key]!.averageDiffPrice == 0 ? Colors.black : riskColor(((average[key]!.averageMaxDiffPrice - average[key]!.averageMinDiffPrice) + average[key]!.averageDiffPrice), (average[key]!.averageMaxDiffPrice - average[key]!.averageMinDiffPrice), (risk ?? 10))),
            ),
          ],
        )
      );
    });
    
    return result;
  }

  List<Widget> _generateSeasonlityYearlyItem({required List<SeasonalityModel> data}) {
    List<Widget> result = [];

    // loop for 1 to 12 and check if the month is exists or not?
    int index = 0;
    int? currMonth;
    double minMaxPrice;

    for(int m=1; m <= 12; m++) {
      if (index >= data.length) {
        // if index already passed the data length then just add _rowItem with blank data
        result.add(
          _rowItem(
            child: const SizedBox.shrink(),
            color: primaryDark,
          )
        );
      }
      else {
        // get the current month
        currMonth = int.tryParse(data[index].month);

        // check if current month same as the one currently processed on the loop (month should be 1-12 only)
        if (currMonth == m) {
          // calculate the minMaxPrice
          minMaxPrice = data[index].maxDiffPrice - data[index].minDiffPrice;

          // add the box
          result.add(
            _rowItem(
              child: _seasonilityItem(
                diffPrice: data[index].averageDiffPrice,
                minDiffPrice: data[index].minDiffPrice,
                minLastPrice: data[index].minLastPrice,
                maxDiffPrice: data[index].maxDiffPrice,
                maxLastPrice: data[index].maxLastPrice,
                minPrevPrice: data[index].minPrevPrice,
                maxPrevPrice: data[index].maxPrevPrice,
              ),
              color: (data[index].averageDiffPrice == 0 ? Colors.black : riskColor((minMaxPrice + data[index].averageDiffPrice), minMaxPrice, (risk ?? 10))),
            )
          );

          // go to next index
          index = index + 1;
        }
        else {
          // if not then just add _rowItem with blank data
          result.add(
            _rowItem(
              child: const SizedBox.shrink(),
              color: primaryLight,
            )
          );
        }
      }
    }

    // return the widget result
    return result;
  }

  Widget _seasonilityItem({
    required double diffPrice,
    required double? minDiffPrice,
    required double? minLastPrice,
    required double? maxDiffPrice,
    required double? maxLastPrice,
    double? minPrevPrice,
    double? maxPrevPrice,
  }) {
    double totalPercentageDiff = 0;
    double cost = 0;
    double range = 0;
    Color textColor = textPrimary;
    List<int> colorValue = [];

    // ensure all data is available
    if (minLastPrice != null && maxLastPrice != null && minDiffPrice != null && maxDiffPrice != null) {
      // get the total percentage diff
      totalPercentageDiff = (maxDiffPrice - minDiffPrice) / ((minLastPrice + maxLastPrice) / 2);
      // calculate the text color
      if (diffPrice != 0) {
        cost = (minDiffPrice + maxDiffPrice);
        range = (minDiffPrice < 0 ? minDiffPrice * (-1) : minDiffPrice) + (maxDiffPrice < 0 ? maxDiffPrice * (-1) : maxDiffPrice);
        cost = cost / range;

        // if the user risk is < 30 then make it lighter color instead
        colorValue.clear();
        if ((risk ?? 10) <= 15) {
          colorValue.add(100);
          colorValue.add(300);
          colorValue.add(500);
        }
        
        textColor = riskColor2(
          percentage: cost,
          diff: diffPrice,
          colorNumber: colorValue,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          formatDecimalWithNull(diffPrice, 1, 2),
          style: TextStyle(
            color: textColor,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  formatDecimalWithNull(minDiffPrice, 1, 2),
                  style: TextStyle(
                    fontSize: 9,
                    color: textColor,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _getArrowIcon(
                      value1: minPrevPrice,
                      value2: minLastPrice,
                    ),
                    Text(
                      formatDecimalWithNull(minLastPrice, 1, 2),
                      style: TextStyle(
                        fontSize: 9,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 5,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  formatDecimalWithNull(maxDiffPrice, 1, 2),
                  style: TextStyle(
                    fontSize: 9,
                    color: textColor,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      formatDecimalWithNull(maxLastPrice, 1, 2),
                      style: TextStyle(
                        fontSize: 9,
                        color: textColor,
                      )
                    ),
                    _getArrowIcon(
                      value1: maxPrevPrice,
                      value2: maxLastPrice,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5,),
        Text(
          "${formatDecimalWithNull(totalPercentageDiff, 100, 2)}%",
          style: TextStyle(
            fontSize: 10,
            color: textColor
          ),
        ),
      ],
    );
  }

  Widget _getArrowIcon({
    double? value1,
    double? value2,
    Color? color,
    double? size
  }) {
    if (value1 == null || value2 == null) {
      return Icon(
        Ionicons.remove,
        size: (size ?? 15),
        color: (color ?? Colors.white),
      );
    }
    if (value1 == value2) {
      return Icon(
        Ionicons.remove,
        size: (size ?? 15),
        color: (color ?? Colors.white),
      );
    }
    else if (value1 < value2) {
      return Icon(
        Ionicons.caret_up,
        size: (size ?? 15),
        color: (color ?? Colors.green),
      );
    }
    else {
      return Icon(
        Ionicons.caret_down,
        size: (size ?? 15),
        color: (color ?? Colors.red),
      );
    }
  }

  Widget _rowItem({
    Color? color,
    required Widget child,
    double? width,
    double? height
  }) {
    return Container(
      padding: const EdgeInsets.all(5),
      color: (color ?? Colors.transparent),
      width: (width ?? 145),
      height: (height ?? 85),
      child: child,
    );
  }

  Map<String, List<SeasonalityModel>> _filterSeasonality() {
    // create the result variable
    Map<String, List<SeasonalityModel>> result = {};

    SeasonalityModel? prevSeasonality;
    SeasonalityModel? currentSeasonility;

    // loop thru data
    for(SeasonalityModel current in data) {
      // check if prev seasonality is null or not?
      if (prevSeasonality == null) {
        currentSeasonility = current;
        prevSeasonality = current;
      }
      else {
        // if prev seasonality is not null then we can give the information
        // of the previous min and max price
        currentSeasonility = SeasonalityModel(
          year: current.year,
          month: current.month,
          averageDiffPrice: current.averageDiffPrice,
          minDiffPrice: current.minDiffPrice,
          maxDiffPrice: current.maxDiffPrice,
          minLastPrice: current.minLastPrice,
          maxLastPrice: current.maxLastPrice,
          minPrevPrice: prevSeasonality.minLastPrice,
          maxPrevPrice: prevSeasonality.maxLastPrice,
        );
        // set prev seasonality as current
        prevSeasonality = current;
      }

      // check if current year already exists on the result or not?
      if (result.containsKey(currentSeasonility.year)) {
        // just add on the list
        result[currentSeasonility.year]?.add(currentSeasonility);
      }
      else {
        result[currentSeasonility.year] = [];
        result[currentSeasonility.year]?.add(currentSeasonility);
      }
    }

    // once finished can result result
    return result;
  }

  Map<String, SeasonalityTableResult> _computeSeasonalityAverage(Map<String, List<SeasonalityModel>> data) {
    Map<String, SeasonalityTableResult> result = {};

    // loop thru the keys
    data.forEach((key, value) {
      // compute the average on value
      double averageDiffPrice = 0;
      double minAveragePrice = double.infinity;
      double averageMinDiffPrice = 0;
      double maxAveragePrice = double.infinity * (-1);
      double averageMaxDiffPrice = 0;
      double minLastPrice = double.infinity;
      double averageMinLastPrice = 0;
      double maxLastPrice = double.infinity * (-1);
      double averageMaxLastPrice = 0;
      int num = 0;

      for(SeasonalityModel curr in value) {
        // compute all the data
        averageDiffPrice += curr.averageDiffPrice;
        
        if (minAveragePrice > curr.minDiffPrice) {
          minAveragePrice = curr.minDiffPrice;
        }
        averageMinDiffPrice += curr.minDiffPrice;

        if (maxAveragePrice < curr.maxDiffPrice) {
          maxAveragePrice = curr.maxDiffPrice;
        }
        averageMaxDiffPrice += curr.maxDiffPrice;

        if (minLastPrice > curr.minLastPrice) {
          minLastPrice = curr.minLastPrice;
        }
        averageMinLastPrice += curr.minLastPrice;

        if (maxLastPrice < curr.maxLastPrice) {
          maxLastPrice = curr.maxLastPrice;
        }
        averageMaxLastPrice += curr.maxLastPrice;

        // add num
        num = num + 1;
      }

      // once finished divide all the average data with num
      averageDiffPrice = averageDiffPrice / num;
      averageMinDiffPrice = averageMinDiffPrice / num;
      averageMaxDiffPrice = averageMaxDiffPrice / num;
      averageMinLastPrice = averageMinLastPrice / num;
      averageMaxLastPrice = averageMaxLastPrice / num;

      // put the result on the seasonality table result
      SeasonalityTableResult compResult = SeasonalityTableResult(
        averageDiffPrice: averageDiffPrice,
        minAveragePrice: minAveragePrice, averageMinDiffPrice: averageMinDiffPrice,
        maxAveragePrice: maxAveragePrice, averageMaxDiffPrice: averageMaxDiffPrice,
        minLastPrice: minLastPrice, averageMinLastPrice: averageMinLastPrice,
        maxLastPrice: maxLastPrice, averageMaxLastPrice: averageMaxLastPrice
      );

      // add the computation result to the map
      result[key] = compResult;
    });
    return result;
  }
}