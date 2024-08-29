import 'package:flutter/widgets.dart';
import 'package:my_wealth/_index.g.dart';

class ComputeWatchlistResult {
  final double totalShare;
  final double totalGain;
  final double totalDayGain;
  final double totalCost;
  final double totalValue;
  final double averagePrice;
  final int totalBuy;
  final int totalSell;
  final Color headerRiskColor;
  final Color subHeaderRiskColor;

  const ComputeWatchlistResult({
    required this.totalShare, required this.totalGain, required this.totalDayGain,
    required this.totalCost, required this.totalValue, required this.averagePrice,
    required this.totalBuy, required this.totalSell, required this.headerRiskColor,
    required this.subHeaderRiskColor,
  });
}

List<ComputeWatchlistResult> computeWatchlistDetail({
  required List<WatchlistListModel> watchlistList,
  required UserLoginInfoModel userInfo}
) {
  List<ComputeWatchlistResult> results = [];
  double totalShare;
  double totalGain;
  double totalDayGain;
  double totalCost;
  double totalValue;
  double averagePrice;
  int totalBuy;
  int totalSell;
  Color headerRiskColor;
  Color subHeaderRiskColor;

  DateTime checkDate;

  for (WatchlistListModel watchlist in watchlistList) {
    // loop thru the watchlist details and calculate the total share and total gain
    totalShare = 0;
    totalGain = 0;
    totalCost = 0;
    totalBuy = 0;
    totalSell = 0;
    totalDayGain = 0;
    totalValue = 0;
    averagePrice = 0;

    // get the check date for this watchlist
    checkDate = (watchlist.watchlistCompanyLastUpdate ?? DateTime.now());

    // for the calculation of the sell share's to avoid any average cost problem
    // we need to see how much is the average cost for each share that we buy
    for (WatchlistDetailListModel detail in watchlist.watchlistDetail.reversed) {
      // check if the date is before or same as companyDate
      // we will just perform the calculation only if the date is same or before
      // the company date (check date).
      if (isSameOrBefore(date: detail.watchlistDetailDate.toLocal(), checkDate: checkDate.toLocal())) {
        // check whether buy or sell
        if (detail.watchlistDetailShare > 0) {
          // if buy we add the total share
          totalShare += detail.watchlistDetailShare;
          // get the total cost
          totalCost += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
          // calculate the average price
          averagePrice = totalCost / totalShare;
          // and add _totalBuy
          totalBuy++;
        } else {
          // if sell we add the total share (since sell will always minus)
          totalShare += detail.watchlistDetailShare;
          // calculate the total cost based on the share sell multiply by average price
          totalCost += (detail.watchlistDetailShare * averagePrice);
          // and add _totalSell
          totalSell++;
        }
      }
    }

    // if we still have totalShare, just recalculate the average price
    // just to ensure, even though that by right this value shouldn't change
    if (totalShare > 0) {
      averagePrice = totalCost / totalShare;

      // now we can calculate the other total
      totalValue = (totalShare * watchlist.watchlistCompanyNetAssetValue!); 
      totalGain = totalValue - totalCost;
      
      // for total day gain, we need to ensure that the previous price is more than 0
      if (watchlist.watchlistCompanyPrevPrice! > 0) {
          totalDayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * totalShare;
      }
      else {
        // we don't have previous price yet, so we can just compute the day gain
        // based on the value - cost
        totalDayGain = totalValue - totalCost;
      }
    }
    else {
      // if we don't have share left, then we can assume that we don't have
      // any cost or value.
      averagePrice = 0;
      totalCost = 0;
      totalValue = 0;
      totalGain = 0;
      totalDayGain = 0;
    }
    
    headerRiskColor = riskColor(
      value: (totalShare * watchlist.watchlistCompanyNetAssetValue!),
      cost: totalCost,
      riskFactor: userInfo.risk
    );
    subHeaderRiskColor = riskColor(
      value: (totalDayGain + totalCost),
      cost: totalCost,
      riskFactor: userInfo.risk
    );

    ComputeWatchlistResult result = ComputeWatchlistResult(
      totalShare: totalShare, totalGain: totalGain, totalDayGain: totalDayGain,
      totalCost: totalCost, totalValue: totalValue, averagePrice: averagePrice,
      totalBuy: totalBuy, totalSell: totalSell, headerRiskColor: headerRiskColor,
      subHeaderRiskColor: subHeaderRiskColor,
    );

    // add result to the result lists
    results.add(result);
  }

  return results;
}