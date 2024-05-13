import 'package:flutter/material.dart';
import 'package:my_wealth/model/watchlist/watchlist_performance_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/globals.dart';

class WatchlistBuilder extends StatelessWidget {
  final List<WatchlistPerformanceModel> data;
  final double min;
  final double max;
  final double minPL;
  final double maxPL;
  final String graphSelection;
  const WatchlistBuilder({
    super.key,
    required this.data,
    required this.min,
    required this.max,
    required this.minPL,
    required this.maxPL,
    required this.graphSelection,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle smallFont = TextStyle(fontSize: 10, color: textPrimary,);

    // ensure we have data there
    if (data.isEmpty) {
      return const Center(child: Text("No data"),);
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: ((context, index) {
        if (data[index].buyTotal == 0) {
          return const SizedBox.shrink();
        }

        double pl = (data[index].buyTotal * data[index].currentPrice) - (data[index].buyTotal * data[index].buyAvg);
        
        double? plDiff;
        Color plDiffColor = textPrimary;
        if (index > 0) {
          // get the pl diff with pl before and now
          plDiff = (data[index - 1].buyTotal * data[index - 1].currentPrice) - (data[index - 1].buyTotal * data[index - 1].buyAvg);
          plDiff = pl - plDiff;

          // set the correct plDiffColor
          if (plDiff > 0) plDiffColor = Colors.green;
          if (plDiff < 0) plDiffColor = secondaryColor;
        }

        // check if this data is the same as _max or _min?
        Color plColor = (pl == 0 ? textPrimary : (pl < 0 ? secondaryColor : Colors.green));
        
        bool isMinMax = false;
        if (pl == max || pl == min) {
          // means for this we will need to put color on the container instead of the text
          isMinMax = true;
          plColor = (pl == 0 ? textPrimary : (pl < 0 ? secondaryDark : Colors.green[900]!));
        }

        bool isPLMinMax = false;
        if (plDiff == maxPL || plDiff == minPL) {
          // means for this we will need to put color on the container instead of the text
          isPLMinMax = true;
          plDiffColor = (plDiff == 0 ? textPrimary : (plDiff! < 0 ? secondaryDark : Colors.green[900]!));
        }

        String dateText = Globals.dfddMM.format(data[index].buyDate);
        if (graphSelection == "m" || graphSelection == "y") {
          dateText = Globals.dfMMyy.format(data[index].buyDate);
        }


        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(5),
              width: 50,
              child: Text(
                dateText,
                textAlign: TextAlign.center,
                style: smallFont,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Text(
                  formatDecimal(data[index].buyTotal, 2),
                  textAlign: TextAlign.center,
                  style: smallFont,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Text(
                  formatCurrency(data[index].buyAvg, false, false, true, 0),
                  textAlign: TextAlign.center,
                  style: smallFont,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Text(
                  formatCurrency(data[index].currentPrice, false, false, true, 0),
                  textAlign: TextAlign.center,
                  style: smallFont,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: (isMinMax ? plColor : Colors.transparent),
                child: Text(
                  formatCurrency(pl, false, false, true, 0),
                  textAlign: TextAlign.center,
                  style: smallFont.copyWith(
                    color: (isMinMax ? Colors.white : plColor),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: (isPLMinMax ? plDiffColor : Colors.transparent),
                child: Text(
                  formatCurrencyWithNull(plDiff, false, false, true, 0),
                  textAlign: TextAlign.center,
                  style: smallFont.copyWith(
                    color: (isPLMinMax ? Colors.white : plDiffColor),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}